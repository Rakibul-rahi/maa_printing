import 'package:cloud_firestore/cloud_firestore.dart';
class ReadyGoodsItem {
  final String id;
  final String type;
  final String category;
  final double amount;
  final String unit;
  final String lastShift;
  final DateTime? lastUpdated;

  ReadyGoodsItem({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.unit,
    required this.lastShift,
    this.lastUpdated,
  });

  factory ReadyGoodsItem.fromFirestore(String id, Map<String, dynamic> data) {
    final split = id.split('-');
    return ReadyGoodsItem(
      id: id,
      type: split[0],
      category: split[1],
      amount: (data['amount'] ?? 0).toDouble(),
      unit: data['unit'] ?? (split[1] == 'Boro' ? 'KG' : 'Bundle'),
      lastShift: data['lastShift'] ?? '-',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'unit': unit,
      'lastShift': lastShift,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
    };
  }
}
