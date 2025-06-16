// lib/models/stock_record_model.dart

class StockRecordModel {
  final String item;
  final double value;
  final String description;
  final String date; // Format: 'dd-MM-yyyy'

  StockRecordModel({
    required this.item,
    required this.value,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'value': value,
      'description': description,
      'date': date,
    };
  }

  factory StockRecordModel.fromMap(Map<String, dynamic> map) {
    return StockRecordModel(
      item: map['item'] ?? '',
      value: (map['value'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: map['date'] ?? '',
    );
  }
}
