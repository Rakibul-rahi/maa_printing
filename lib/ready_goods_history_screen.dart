import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';
import 'theme/app_widgets.dart';

class ReadyGoodsHistoryScreen extends StatelessWidget {
  final String type;
  final String category;

  const ReadyGoodsHistoryScreen({
    super.key,
    required this.type,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final CollectionReference historyCollection = FirebaseFirestore.instance
        .collection('readyGoods')
        .doc('$type-$category')
        .collection('history');
    final unit = context.l10n.unit(category == 'Boro' ? 'KG' : 'Bundle');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyFor('${context.l10n.productType(type)} (${context.l10n.category(category)})')),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyCollection.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 56, color: scheme.outline),
                  const SizedBox(height: 8),
                  Text(context.l10n.noHistoryRecords, style: TextStyle(color: scheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final String? operation = data['operation'] as String?;
              final isAdd = operation == 'Add';
              final quantity = (data['quantity'] ?? 0).toDouble();
              final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
              final shift = data['shift'] ?? '-';
              final color = isAdd ? context.successColor : context.dangerColor;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      IconBadge(icon: isAdd ? Icons.arrow_downward : Icons.arrow_upward, color: color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              operation != null ? context.l10n.operation(operation) : context.l10n.unknown,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.shiftDateLine(context.l10n.shiftName(shift), context.date(date)),
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isAdd ? '+' : '−'}${context.number(quantity)} $unit',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
