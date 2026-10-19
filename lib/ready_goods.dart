import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ready_goods_model.dart';
import 'ready_goods_history_screen.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';
import 'theme/app_widgets.dart';

class ReadyGoodsInventoryScreen extends StatefulWidget {
  const ReadyGoodsInventoryScreen({super.key});

  @override
  State<ReadyGoodsInventoryScreen> createState() => _ReadyGoodsInventoryScreenState();
}

class _ReadyGoodsInventoryScreenState extends State<ReadyGoodsInventoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> productTypes = ['Pani', '1 No', '2 No', '3 No'];
  final List<String> categories = ['Boro', 'Choto'];

  String _unitFor(String category) => category == 'Boro' ? 'KG' : 'Bundle';

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: context.dangerColor, size: 36),
        title: Text(context.l10n.confirmReset),
        content: Text(context.l10n.confirmResetInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetInitialAmounts();
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _resetInitialAmounts() async {
    for (var type in productTypes) {
      for (var cat in categories) {
        await _firestore.collection('readyGoods').doc('$type-$cat').set({
          'amount': 0,
          'unit': _unitFor(cat),
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastShift': '-',
        });
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inventoryReset)),
      );
    }
  }

  Future<void> _showUpdateSheet(String type, String category, double current, {required bool add}) async {
    final amountCtrl = TextEditingController();
    String shift = DateTime.now().hour >= 18 || DateTime.now().hour < 6 ? 'Night' : 'Day';
    DateTime date = DateTime.now();
    bool isAddition = add;
    bool saving = false;
    final unit = _unitFor(category);
    final quick = category == 'Boro' ? [10, 25, 50, 100] : [5, 10, 20, 50];

    await showEntrySheet<void>(context, (sheetCtx) {
      return StatefulBuilder(builder: (ctx, setSheet) {
        final scheme = Theme.of(ctx).colorScheme;
        final qty = parseAmount(amountCtrl.text) ?? 0;
        final newTotal = isAddition ? current + qty : current - qty;
        final accent = isAddition ? ctx.successColor : ctx.dangerColor;

        Future<void> save() async {
          if (qty <= 0) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(ctx.l10n.enterValidAmount)));
            return;
          }
          setSheet(() => saving = true);
          final nav = Navigator.of(sheetCtx);
          final messenger = ScaffoldMessenger.of(context);
          final errorText = ctx.l10n;
          try {
            final docRef = _firestore.collection('readyGoods').doc('$type-$category');
            await _firestore.runTransaction((tx) async {
              final snapshot = await tx.get(docRef);
              final prev = (snapshot.data()?['amount'] as num?)?.toDouble() ?? 0.0;
              tx.set(
                docRef,
                {
                  'amount': isAddition ? prev + qty : prev - qty,
                  'unit': unit,
                  'lastUpdated': Timestamp.fromDate(date),
                  'lastShift': shift,
                },
                SetOptions(merge: true),
              );
              tx.set(docRef.collection('history').doc(), {
                'operation': isAddition ? 'Add' : 'Subtract',
                'quantity': qty,
                'date': Timestamp.fromDate(date),
                'shift': shift,
                'timestamp': FieldValue.serverTimestamp(),
              });
            });
            nav.pop();
          } catch (e) {
            if (sheetCtx.mounted) setSheet(() => saving = false);
            messenger.showSnackBar(SnackBar(content: Text(errorText.errorWithMessage(e))));
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${ctx.l10n.productType(type)} • ${ctx.l10n.category(category)}',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: productColor(type)),
            ),
            const SizedBox(height: 2),
            Text(
              '${ctx.l10n.inStock}: ${ctx.number(current)} ${ctx.l10n.unit(unit)}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: true, icon: const Icon(Icons.add), label: Text(ctx.l10n.opAdd)),
                ButtonSegment(value: false, icon: const Icon(Icons.remove), label: Text(ctx.l10n.opSubtract)),
              ],
              selected: {isAddition},
              onSelectionChanged: (s) => setSheet(() => isAddition = s.first),
            ),
            const SizedBox(height: 16),
            AmountStepper(
              controller: amountCtrl,
              allowNegative: false,
              autofocus: true,
              onChanged: () => setSheet(() {}),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                for (final q in quick)
                  ActionChip(
                    label: Text('+$q'),
                    onPressed: () {
                      final v = (parseAmount(amountCtrl.text) ?? 0) + q;
                      amountCtrl.text = compactNumber(v);
                      setSheet(() {});
                    },
                  ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: qty > 0
                    ? (newTotal < 0 ? ctx.dangerContainer : accent.withValues(alpha: 0.12))
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                qty > 0
                    ? '${ctx.l10n.newTotal(ctx.number(newTotal))} ${ctx.l10n.unit(unit)}'
                    : '${ctx.l10n.amountIn(ctx.l10n.unit(unit))}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: qty > 0 ? (newTotal < 0 ? ctx.dangerColor : accent) : scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ShiftSelector(value: shift, onChanged: (v) => setSheet(() => shift = v)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: DateChip(date: date, onChanged: (d) => setSheet(() => date = d)),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: scheme.surface),
              onPressed: saving ? null : save,
              icon: saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(ctx.l10n.save),
            ),
          ],
        );
      });
    });
    amountCtrl.dispose();
  }

  Widget _summaryHeader(BuildContext context, double totalKg, double totalBundles) {
    final scheme = Theme.of(context).colorScheme;
    Widget cell(String label, double v, String unit) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8), fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                context.number(v),
                style: TextStyle(color: scheme.onPrimary, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              Text(unit, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primary, Color.lerp(scheme.primary, Colors.purple, 0.35)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          cell('${context.l10n.totalLabel} • ${context.l10n.catBoro}', totalKg, context.l10n.unitKg),
          Container(width: 1, height: 52, color: scheme.onPrimary.withValues(alpha: 0.3)),
          const SizedBox(width: 18),
          cell('${context.l10n.totalLabel} • ${context.l10n.catChoto}', totalBundles, context.l10n.unitBundle),
        ],
      ),
    );
  }

  Widget _categoryRow(BuildContext context, String type, String cat, ReadyGoodsItem? item) {
    final scheme = Theme.of(context).colorScheme;
    final unit = _unitFor(cat);
    final amount = item?.amount ?? 0.0;
    final last = item?.lastUpdated;
    final lastText = last == null
        ? '-'
        : '${context.l10n.shiftName(item!.lastShift)} • ${context.date(last)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: cat == 'Boro' ? Icons.scale_outlined : Icons.inventory_2_outlined,
                color: cat == 'Boro' ? Colors.indigo : Colors.teal,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.category(cat), style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(lastText, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.number(amount),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: amount < 0 ? context.dangerColor : scheme.onSurface,
                    ),
                  ),
                  Text(context.l10n.unit(unit), style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: context.l10n.viewHistory,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReadyGoodsHistoryScreen(type: type, category: cat)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: context.successContainer,
                    foregroundColor: context.successColor,
                  ),
                  onPressed: () => _showUpdateSheet(type, cat, amount, add: true),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(context.l10n.opAdd),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: context.dangerContainer,
                    foregroundColor: context.dangerColor,
                  ),
                  onPressed: () => _showUpdateSheet(type, cat, amount, add: false),
                  icon: const Icon(Icons.remove, size: 20),
                  label: Text(context.l10n.opSubtract),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.readyGoodsInventory),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: context.l10n.resetInventory,
            onPressed: _showResetConfirmationDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('readyGoods').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.errorWithMessage(snapshot.error!)));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = <String, ReadyGoodsItem>{};
          for (final d in snapshot.data!.docs) {
            if (!d.id.contains('-')) continue;
            items[d.id] = ReadyGoodsItem.fromFirestore(d.id, d.data() as Map<String, dynamic>);
          }

          double totalKg = 0, totalBundles = 0;
          for (final type in productTypes) {
            totalKg += items['$type-Boro']?.amount ?? 0;
            totalBundles += items['$type-Choto']?.amount ?? 0;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryHeader(context, totalKg, totalBundles),
              const SizedBox(height: 16),
              for (final type in productTypes) ...[
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: productColor(type).withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: productColor(type),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.productType(type),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        for (var i = 0; i < categories.length; i++) ...[
                          if (i > 0) const Divider(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _categoryRow(context, type, categories[i], items['$type-${categories[i]}']),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}
