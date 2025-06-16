import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'stock_record_model.dart';

class StockRecord {
  double value;
  String description;

  StockRecord({this.value = 0.0, this.description = ''});
}

class HomeStockView extends StatelessWidget {
  final Map<String, double> currentStock;

  const HomeStockView({super.key, required this.currentStock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Stock Summary'),
      ),
      body: ListView.builder(
        itemCount: currentStock.length,
        itemBuilder: (context, index) {
          final item = currentStock.keys.elementAt(index);
          final value = currentStock[item] ?? 0.0;
          return ListTile(
            title: Text(item),
            trailing: Text(value.toStringAsFixed(1)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockHishab()),
          );
        },
        child: const Icon(Icons.table_chart),
        tooltip: 'Go to Spreadsheet',
      ),
    );
  }
}

class StockHishab extends StatefulWidget {
  const StockHishab({super.key});

  @override
  State<StockHishab> createState() => _StockHishabState();
}

class _StockHishabState extends State<StockHishab> {
  final List<String> items = [
    'LDP', 'LLD', 'D Dana', 'HDP', 'WD', 'Calcium', 'color',
    '1 no T', '2 no T', '3 no T', 'Bosta', 'Rope', 'Dov'
  ];

  final Map<DateTime, Map<String, StockRecord>> records = {};
  DateTime selectedDate = DateTime.now();
  final Map<String, TextEditingController> valueControllers = {};
  final Map<String, TextEditingController> descControllers = {};
  bool hasUnsavedChanges = false;
  Map<String, double> currentStock = {};

  @override
  void initState() {
    super.initState();
    for (var item in items) {
      valueControllers[item] = TextEditingController();
      descControllers[item] = TextEditingController();
      currentStock[item] = 0.0;
    }
    _loadCurrentStock();
    _loadDateData();
  }

  Future<void> _loadCurrentStock() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('current_stock')
          .doc('summary')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          for (var item in items) {
            currentStock[item] = (data[item] ?? 0.0).toDouble();
          }
        });
      }
    } catch (e) {
      print('Error loading current stock: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in valueControllers.values) {
      controller.dispose();
    }
    for (var controller in descControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateItem(String item, double delta) {
    setState(() {
      hasUnsavedChanges = true;
      final currentValue = double.tryParse(valueControllers[item]!.text) ?? 0.0;
      valueControllers[item]!.text = (currentValue + delta).toStringAsFixed(1);
    });
  }

  void _saveAllChanges() {
    setState(() {
      records.putIfAbsent(selectedDate, () =>
      {for (var e in items) e: StockRecord()});

      for (var item in items) {
        final value = double.tryParse(valueControllers[item]!.text) ?? 0.0;
        records[selectedDate]![item]!.value = value;
        records[selectedDate]![item]!.description = descControllers[item]!.text;
      }

      hasUnsavedChanges = false;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved locally'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          )
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (hasUnsavedChanges) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Save before switching date?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        _saveAllChanges();
      } else if (confirm == null) {
        return;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        hasUnsavedChanges = false;
        _loadDateData();
      });
    }
  }

  void _loadDateData() {
    for (var item in items) {
      final record = records[selectedDate]?[item] ?? StockRecord();
      valueControllers[item]!.text = record.value.toStringAsFixed(1);
      descControllers[item]!.text = record.description;
    }
  }

  void _showDescriptionDialog(String item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Description for $item'),
          content: TextField(
            controller: descControllers[item],
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter description...',
            ),
            onChanged: (_) => hasUnsavedChanges = true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() => hasUnsavedChanges = true);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _submitToFirestore() async {
    try {
      _saveAllChanges();

      final dateString = _formatDate(selectedDate);
      final batch = FirebaseFirestore.instance.batch();
      final dailyCollection = FirebaseFirestore.instance.collection('daily_stock_records');
      final currentStockRef = FirebaseFirestore.instance.collection('current_stock').doc('summary');

      Map<String, double> updatedStock = {...currentStock};
      bool hasChanges = false;

      for (var item in items) {
        final record = records[selectedDate]?[item];
        if (record != null && record.value != 0) {
          hasChanges = true;
          // Save daily record
          final model = StockRecordModel(
            item: item,
            value: record.value,
            description: record.description,
            date: dateString,
          );
          batch.set(dailyCollection.doc(), model.toMap());

          // Update current stock
          updatedStock[item] = (updatedStock[item] ?? 0) + record.value;
        }
      }

      if (hasChanges) {
        // Update current stock in Firestore
        batch.set(currentStockRef, updatedStock);

        await batch.commit();

        setState(() {
          currentStock = updatedStock;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stock data submitted for $dateString'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes to submit'),
              backgroundColor: Colors.blue,
            )
        );
      }
    } on FirebaseException catch (e) {
      String errorMessage = 'Firestore Error: ${e.message}';
      if (e.code == 'permission-denied') {
        errorMessage = 'Permission denied. Check security rules';
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          )
      );
    }
  }

  void _navigateToHomeView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeStockView(currentStock: currentStock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Accounting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHomeView,
        ),
        actions: [
          if (hasUnsavedChanges)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.warning_amber, color: Colors.amber),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHomeView,
            tooltip: 'Stock Summary',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    selectedDate = selectedDate.subtract(const Duration(days: 1));
                    _loadDateData();
                  }),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                    _loadDateData();
                  }),
                ),
              ],
            ),
          ),

          // Spreadsheet
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12,
                  columns: const [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Value')),
                    DataColumn(label: Text('Add/Sub')),
                    DataColumn(label: Text('Desc')),
                  ],
                  rows: items.map((item) {
                    final record = records[selectedDate]?[item] ?? StockRecord();
                    return DataRow(cells: [
                      DataCell(SizedBox(width: 80, child: Text(item))),
                      DataCell(
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: valueControllers[item],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(6),
                            ),
                            onChanged: (_) => hasUnsavedChanges = true,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => _updateItem(item, 1.0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () => _updateItem(item, -1.0),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(
                            record.description.isNotEmpty
                                ? Icons.description
                                : Icons.description_outlined,
                            color: record.description.isNotEmpty
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: () => _showDescriptionDialog(item),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),

          // Submit button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Submit to Firestore'),
              onPressed: _submitToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAllChanges,
        tooltip: 'Save Changes',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}