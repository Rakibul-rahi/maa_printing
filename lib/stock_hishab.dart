import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stock_record_model.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';
import 'theme/app_widgets.dart';

// Define stock items globally
const List<String> kStockItems = [
  'LDP', 'LLD', 'D Dana', 'HDP', 'WD', 'Calcium', 'color',
  '1 no T', '2 no T', '3 no T', 'Bosta', 'Rope', 'Dov'
];

class StockRecord {
  double value;
  String description;

  StockRecord({this.value = 0.0 , this.description = ''});
}

class HomeStockView extends StatefulWidget {
  const HomeStockView({super.key});

  @override
  State<HomeStockView> createState() => _HomeStockViewState();
}

class _HomeStockViewState extends State<HomeStockView> {
  Map<String, double> currentStock = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStock();
  }

  Future<void> _loadCurrentStock() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('current_stock')
          .doc('summary')
          .get();

      setState(() {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          currentStock = {};
          for (var item in kStockItems) {
            currentStock[item] = (data[item] ?? 0.0).toDouble();
          }
        } else {
          currentStock = { for (var item in kStockItems) item: 0.0 };
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading current stock: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.currentStockSummary)),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisExtent: 92,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: currentStock.length,
        itemBuilder: (context, index) {
          final item = currentStock.keys.elementAt(index);
          final value = currentStock[item] ?? 0.0;
          final low = value <= 0;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text(
                    context.number(value, 1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: low ? context.dangerColor : scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockHishab(currentStock: currentStock),
            ),
          );
        },
        icon: const Icon(Icons.edit_note),
        label: Text(context.l10n.newEntry),
      ),
    );
  }
}

class StockHishab extends StatefulWidget {
  final Map<String, double> currentStock;

  const StockHishab({super.key, required this.currentStock});

  @override
  State<StockHishab> createState() => _StockHishabState();
}

class _StockHishabState extends State<StockHishab> {
  final Map<DateTime, Map<String, StockRecord>> records = {};
  DateTime selectedDate = _dateOnly(DateTime.now());
  final Map<String, TextEditingController> valueControllers = {};
  final Map<String, TextEditingController> descControllers = {};
  late Map<String, double> currentStock;
  bool _submitting = false;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _isToday => selectedDate == _dateOnly(DateTime.now());
  bool get _isFutureDate => selectedDate.isAfter(_dateOnly(DateTime.now()));

  @override
  void initState() {
    super.initState();
    currentStock = {...widget.currentStock};
    for (var item in kStockItems) {
      valueControllers[item] = TextEditingController();
      descControllers[item] = TextEditingController();
    }
    _loadDateData();
  }

  @override
  void dispose() {
    for (var controller in valueControllers.values) {
      controller.dispose();
    }
    for (var controller in descControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _entry(String item) => parseAmount(valueControllers[item]!.text) ?? 0.0;

  int get _changedCount => kStockItems.where((i) => _entry(i) != 0).length;

  /// Keeps what was typed for the current date so switching days never loses it.
  void _stashCurrent() {
    final day = records.putIfAbsent(selectedDate, () => {for (var e in kStockItems) e: StockRecord()});
    for (var item in kStockItems) {
      day[item]!.value = _entry(item);
      day[item]!.description = descControllers[item]!.text;
    }
  }

  void _loadDateData() {
    for (var item in kStockItems) {
      final record = records[selectedDate]?[item] ?? StockRecord();
      valueControllers[item]!.text = record.value == 0 ? '' : compactNumber(record.value);
      descControllers[item]!.text = record.description;
    }
  }

  void _goToDate(DateTime date) {
    _stashCurrent();
    setState(() {
      selectedDate = _dateOnly(date);
      _loadDateData();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) _goToDate(picked);
  }

  Future<void> _editNote(String item) async {
    await showEntrySheet<void>(context, (ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ctx.l10n.descriptionFor(item), style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: descControllers[item],
            maxLines: 4,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: ctx.l10n.enterDescription),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.save)),
          ),
        ],
      );
    });
    if (mounted) setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _snack(String message, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _submitToFirestore() async {
    if (_isFutureDate) {
      _snack(context.l10n.cannotSubmitFuture, color: Colors.red);
      return;
    }
    if (_changedCount == 0) {
      _snack(context.l10n.nothingEntered);
      return;
    }

    setState(() => _submitting = true);
    try {
      _stashCurrent();

      final dateString = _formatDate(selectedDate);
      final batch = FirebaseFirestore.instance.batch();
      final dailyCollection = FirebaseFirestore.instance.collection('daily_stock_records');
      final currentStockRef = FirebaseFirestore.instance.collection('current_stock').doc('summary');

      final updatedStock = {...currentStock};

      for (var item in kStockItems) {
        final record = records[selectedDate]![item]!;
        if (record.value != 0) {
          final model = StockRecordModel(
            item: item,
            value: record.value,
            description: record.description,
            date: dateString,
          );
          batch.set(dailyCollection.doc(), model.toMap());
          updatedStock[item] = (updatedStock[item] ?? 0) + record.value;
        }
      }

      batch.set(currentStockRef, updatedStock);
      await batch.commit();

      if (!mounted) return;
      // Entries are now part of the stock; clear them so they can't be submitted twice.
      records.remove(selectedDate);
      setState(() {
        currentStock = updatedStock;
        _loadDateData();
      });
      _snack(context.l10n.stockSubmittedFor(context.date(selectedDate)), color: Colors.green);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _snack(
        e.code == 'permission-denied' ? context.l10n.permissionDenied : context.l10n.firestoreError(e.message ?? e.code),
        color: Colors.red,
      );
    } catch (e) {
      if (!mounted) return;
      _snack(context.l10n.unexpectedErrorWith(e), color: Colors.red);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _navigateToHomeView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeStockView()),
    );
  }

  Widget _dateHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _goToDate(selectedDate.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        context.date(selectedDate),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _isToday ? context.l10n.today : context.l10n.selectDate,
                        style: TextStyle(fontSize: 12, color: scheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _isToday || _isFutureDate
                  ? null
                  : () => _goToDate(selectedDate.add(const Duration(days: 1))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(BuildContext context, String item) {
    final scheme = Theme.of(context).colorScheme;
    final stock = currentStock[item] ?? 0.0;
    final entry = _entry(item);
    final hasEntry = entry != 0;
    final note = descControllers[item]!.text;
    final newTotal = stock + entry;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasEntry ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.6),
          width: hasEntry ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(
                        '${context.l10n.inStock}: ${context.number(stock, 1)}',
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (hasEntry)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: newTotal < 0 ? context.dangerContainer : context.successContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.l10n.newTotal(context.number(newTotal, 1)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: newTotal < 0 ? context.dangerColor : context.successColor,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: context.l10n.noteLabel,
                  onPressed: _isFutureDate ? null : () => _editNote(item),
                  icon: Icon(
                    note.isNotEmpty ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
                    color: note.isNotEmpty ? scheme.primary : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: AmountStepper(
                controller: valueControllers[item]!,
                enabled: !_isFutureDate,
                onChanged: () => setState(() {}),
              ),
            ),
            if (note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 6),
                child: Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: scheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.stockAccounting),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHomeView,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _dateHeader(context),
                if (_isFutureDate)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      context.l10n.editingDisabledFuture,
                      style: TextStyle(color: context.dangerColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 12),
                for (final item in kStockItems) ...[
                  _itemCard(context, item),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          Material(
            elevation: 8,
            color: scheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.itemsChanged(_changedCount),
                        style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _isFutureDate || _submitting ? null : _submitToFirestore,
                      icon: _submitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(context.l10n.submit),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
