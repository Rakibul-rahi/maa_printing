import 'package:cloud_firestore/cloud_firestore.dart';
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

  String formatDate() {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}