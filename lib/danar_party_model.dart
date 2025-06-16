
import 'package:cloud_firestore/cloud_firestore.dart';

class DanarPartyAccount {
  final String id;
  final String partyName;
  final String contactPerson;
  final String phone;
  final double totalBill;
  final double totalPaid;
  final DateTime lastTransactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  DanarPartyAccount({
    this.id = '',
    required this.partyName,
    required this.contactPerson,
    required this.phone,
    this.totalBill = 0.0,
    this.totalPaid = 0.0,
    required this.lastTransactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ➕ Calculated due amount (if you owe them)
  double get dueAmount => (totalBill - totalPaid) > 0 ? totalBill - totalPaid : 0;

  /// ➕ Calculated advance amount (if you paid extra)
  double get advanceAmount => (totalPaid - totalBill) > 0 ? totalPaid - totalBill : 0;

  /// 🔄 Convert model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'partyName': partyName,
      'contactPerson': contactPerson,
      'phone': phone,
      'totalBill': totalBill,
      'totalPaid': totalPaid,
      'lastTransactionDate': lastTransactionDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 🔄 Create model from Firestore map
  factory DanarPartyAccount.fromMap(String id, Map<String, dynamic> map) {
    return DanarPartyAccount(
      id: id,
      partyName: map['partyName'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      phone: map['phone'] ?? '',
      totalBill: (map['totalBill'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (map['totalPaid'] as num?)?.toDouble() ?? 0.0,
      lastTransactionDate: _parseTimestamp(map['lastTransactionDate']),
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  /// ⏱ Timestamp helper
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }

  /// 📤 Copy object with updates (immutability support)
  DanarPartyAccount copyWith({
    String? partyName,
    String? contactPerson,
    String? phone,
    double? totalBill,
    double? totalPaid,
    DateTime? lastTransactionDate,
    DateTime? updatedAt,
  }) {
    return DanarPartyAccount(
      id: id,
      partyName: partyName ?? this.partyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      totalBill: totalBill ?? this.totalBill,
      totalPaid: totalPaid ?? this.totalPaid,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
