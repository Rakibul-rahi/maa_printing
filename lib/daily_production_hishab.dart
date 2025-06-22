import 'package:flutter/material.dart';
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

class DailyProductionHishab extends StatelessWidget {
  const DailyProductionHishab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Production Hishab'),
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
        _error = 'Failed to load stock: $e';
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
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showEntryDialog(String shift) {
    showDialog(
      context: context,
      builder: (_) => ProductionEntryDialog(
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
        title: const Text('Set Initial Stock'),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries
                .map((e) => _buildTextField(e.key, e.value))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Save'),
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
          title: Text('History for ${_formatDate(selected)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: entries.isEmpty
                ? const Text('No history found')
                : ListView(
              shrinkWrap: true,
              children: entries.map((entry) {
                return ListTile(
                  title: Text('${entry.type} - ${entry.operation}'),
                  subtitle: Text(
                      '${entry.amount.toStringAsFixed(2)} KG\n${entry.formatDate()} (${entry.shift})'),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text('Error: $_error'));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Current Stock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: _setInitialStock,
              icon: const Icon(Icons.settings),
              tooltip: 'Set Stock',
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: _stock.entries.map((e) {
              return ListTile(
                title: Text(e.key),
                trailing: Text('${e.value.toStringAsFixed(2)} KG'),
              );
            }).toList(),
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showEntryDialog('Day'),
              child: const Text('Day Shift'),
            ),
            ElevatedButton(
              onPressed: () => _showEntryDialog('Night'),
              child: const Text('Night Shift'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _viewHistory,
          child: const Text('View History'),
        ),
        const SizedBox(height: 20),
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
  double _amount = 0.0;
  String _operation = 'Blowing';
  DateTime _date = DateTime.now();

  final _types = ['Pani', '1 No', '2 No', '3 No'];
  final _operations = ['Blowing', 'Cutting', 'Wastage'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.shift} Shift Entry'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Text("Date: "),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${_date.day}/${_date.month}/${_date.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              onChanged: (val) => setState(() => _type = val!),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => _amount = double.tryParse(val) ?? 0.0,
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _operation,
              isExpanded: true,
              onChanged: (val) => setState(() => _operation = val!),
              items: _operations
                  .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid amount')),
              );
              return;
            }

            widget.onSubmit(_type, _amount, _operation, _date);
            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}