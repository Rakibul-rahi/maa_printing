import 'package:cloud_firestore/cloud_firestore.dart';

class PartyTransaction {
  final String id;
  final double amount;
  final double paid;
  final DateTime date;
  final String description;

  PartyTransaction({
    this.id = '',
    required this.amount,
    required this.paid,
    required this.date,
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'paid': paid,
    'date': date, // Let Firestore handle it
    'description': description,
  };

  factory PartyTransaction.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsedDate;

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate(); // ✅ correct for Firestore
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now(); // fallback
    }

    return PartyTransaction(
      id: id,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paid: (map['paid'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      description: map['description'] ?? '',
    );
  }
}
