import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReadyGoodsHistoryScreen extends StatelessWidget {
  final String type;
  final String category;

  const ReadyGoodsHistoryScreen({
    Key? key,
    required this.type,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference historyCollection = FirebaseFirestore.instance
        .collection('readyGoods')
        .doc('$type-$category')
        .collection('history');

    return Scaffold(
      appBar: AppBar(
        title: Text('History for $type ($category)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyCollection.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No history records found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final String? operation = data['operation'] as String?;
              final quantity = (data['quantity'] ?? 0).toDouble();
              final dateTimestamp = data['date'] as Timestamp?;
              final date = dateTimestamp?.toDate() ?? DateTime.now();
              final shift = data['shift'] ?? '-';

              return ListTile(
                leading: Icon(
                  operation == 'Add' ? Icons.add_circle : Icons.remove_circle,
                  color: operation == 'Add' ? Colors.green : Colors.red,
                ),
                title: Text('${operation ?? 'Unknown'} ${quantity.toStringAsFixed(2)}'),
                subtitle: Text('Shift: $shift | Date: ${date.day}/${date.month}/${date.year}'),
              );
            },
          );
        },
      ),
    );
  }
}
