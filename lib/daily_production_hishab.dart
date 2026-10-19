import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';
import 'theme/app_widgets.dart';

class ProductionEntry {
  final String id;
  final Timestamp timestamp;
  final String date; // YYYY-MM-DD format
  final String shift;
  final String type;
  final double amount;
  final String operation;

  ProductionEntry({
    required this.id,
    required this.timestamp,
    required this.date,
    required this.shift,
    required this.type,
    required this.amount,
    required this.operation,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'date': date,
      'shift': shift,
      'type': type,
      'amount': amount,
      'operation': operation,
    };
  }

  factory ProductionEntry.fromMap(String id, Map<String, dynamic> map) {
    return ProductionEntry(
      id: id,
      timestamp: map['timestamp'] as Timestamp,
      date: map['date'] as String,
      shift: map['shift'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      operation: map['operation'] as String,
    );
  }

  static String formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class DailyProductionHishab extends StatelessWidget {
  const DailyProductionHishab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dailyProductionHishab),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const ProductionOverview(),
    );
  }
}

class ProductionOverview extends StatefulWidget {
  const ProductionOverview({super.key});

  @override
  State<ProductionOverview> createState() => _ProductionOverviewState();
}

class _ProductionOverviewState extends State<ProductionOverview> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> _stock = {
    'Pani': 0.0,
    '1 No': 0.0,
    '2 No': 0.0,
    '3 No': 0.0,
  };
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadInitialStock();
  }

  Future<void> _loadInitialStock() async {
    try {
      final snapshot = await _firestore.collection('stock').get();
      final updatedStock = Map<String, double>.from(_stock);

      for (var doc in snapshot.docs) {
        if (updatedStock.containsKey(doc.id)) {
          updatedStock[doc.id] = (doc.data()['quantity'] as num).toDouble();
        }
      }

      setState(() {
        _stock = updatedStock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = context.l10n.failedToLoadStock(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStock(
      String type,
      double amount,
      String operation,
      String shift,
      DateTime date,
      ) async {
    final now = Timestamp.now();
    final dateString = ProductionEntry.formatDateString(date);

    final newEntry = ProductionEntry(
      id: '',
      timestamp: now,
      date: dateString,
      shift: shift,
      type: type,
      amount: amount,
      operation: operation,
    );

    final currentAmount = _stock[type] ?? 0.0;
    final newAmount = operation == 'Blowing'
        ? currentAmount + amount
        : currentAmount - amount;

    try {
      await _firestore.runTransaction((transaction) async {
        // Add production entry
        final entryRef = _firestore.collection('production_entries').doc();
        transaction.set(entryRef, newEntry.toMap());

        // Update stock
        final stockRef = _firestore.collection('stock').doc(type);
        transaction.set(stockRef, {
          'quantity': newAmount,
          'last_updated': Timestamp.now(),
        });
      });

      setState(() {
        _stock = Map<String, double>.from(_stock);
        _stock[type] = newAmount;
      });
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithMessage(e))),
      );
    }
  }

  void _showEntryDialog(String shift) {
    showEntrySheet<void>(
      context,
      (_) => ProductionEntryDialog(
        shift: shift,
        onSubmit: (type, amount, operation, date) {
          _updateStock(type, amount, operation, shift, date);
        },
      ),
    );
  }

  void _setInitialStock() {
    final controllers = {
      for (var key in _stock.keys)
        key: TextEditingController(text: _stock[key]!.toStringAsFixed(2)),
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.setInitialStock),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries
                .map((e) => _buildTextField(context.l10n.productType(e.key), e.value))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = <String, double>{};
              for (var e in controllers.entries) {
                updated[e.key] = double.tryParse(e.value.text) ?? 0.0;
              }
              setState(() => _stock = updated);
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  void _viewHistory() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected == null || !context.mounted) return;

    final dateString = ProductionEntry.formatDateString(selected);

    try {
      final snapshot = await _firestore
          .collection('production_entries')
          .where('date', isEqualTo: dateString)
          .orderBy('timestamp', descending: true)
          .get();

      final entries = snapshot.docs
          .map((doc) => ProductionEntry.fromMap(doc.id, doc.data()))
          .toList();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.historyFor(context.date(selected))),
          content: SizedBox(
            width: double.maxFinite,
            child: entries.isEmpty
                ? Text(context.l10n.noHistory)
                : ListView(
              shrinkWrap: true,
              children: entries.map((entry) {
                return ListTile(
                  title: Text('${context.l10n.productType(entry.type)} - ${context.l10n.operation(entry.operation)}'),
                  subtitle: Text(
                      '${context.l10n.kgAmount(context.number(entry.amount))}\n'
                      '${context.dateTime(entry.timestamp.toDate())} (${context.l10n.shiftName(entry.shift)})'),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text(context.l10n.errorWithMessage(_error)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.currentStock,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: _setInitialStock,
              icon: const Icon(Icons.tune),
              tooltip: context.l10n.setStock,
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: _stock.entries.map((e) {
            final c = productColor(e.key);
            return Card(
              color: c.withValues(alpha: context.isDark ? 0.22 : 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: c.withValues(alpha: 0.7), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.productType(e.key),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.kgAmount(context.number(e.value)),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _showEntryDialog('Day'),
                icon: const Icon(Icons.wb_sunny_outlined),
                label: Text(context.l10n.dayShift),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
                onPressed: () => _showEntryDialog('Night'),
                icon: const Icon(Icons.nightlight_outlined),
                label: Text(context.l10n.nightShift),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _viewHistory,
          icon: const Icon(Icons.history),
          label: Text(context.l10n.viewHistory),
        ),
      ],
    );
  }
}

class ProductionEntryDialog extends StatefulWidget {
  final void Function(String, double, String, DateTime) onSubmit;
  final String shift;

  const ProductionEntryDialog({
    required this.onSubmit,
    required this.shift,
    super.key,
  });

  @override
  State<ProductionEntryDialog> createState() => _ProductionEntryDialogState();
}

class _ProductionEntryDialogState extends State<ProductionEntryDialog> {
  String _type = 'Pani';
  String _operation = 'Blowing';
  DateTime _date = DateTime.now();
  final _amountCtrl = TextEditingController();

  static const _types = ['Pani', '1 No', '2 No', '3 No'];
  static const _operations = ['Blowing', 'Cutting', 'Wastage'];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.shiftEntry(context.l10n.shiftName(widget.shift)),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            for (final t in _types)
              ChoiceChip(
                label: Text(context.l10n.productType(t)),
                selected: _type == t,
                selectedColor: productColor(t).withValues(alpha: 0.35),
                side: BorderSide(color: productColor(t)),
                onSelected: (_) => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final op in _operations)
              ChoiceChip(
                label: Text(context.l10n.operation(op)),
                selected: _operation == op,
                onSelected: (_) => setState(() => _operation = op),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AmountStepper(controller: _amountCtrl, step: 5, allowNegative: false, autofocus: true),
        const SizedBox(height: 4),
        Text(
          context.l10n.amountIn(context.l10n.unitKg),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: DateChip(date: _date, onChanged: (d) => setState(() => _date = d)),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: Text(context.l10n.submit),
          onPressed: () {
            final amount = parseAmount(_amountCtrl.text) ?? 0;
            if (amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.enterValidAmount)),
              );
              return;
            }
            widget.onSubmit(_type, amount, _operation, _date);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
