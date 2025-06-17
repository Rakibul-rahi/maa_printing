import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'stock_record_model.dart';

// Define stock items globally
const List<String> kStockItems = [
  'LDP', 'LLD', 'D Dana', 'HDP', 'WD', 'Calcium', 'color',
  '1 no T', '2 no T', '3 no T', 'Bosta', 'Rope', 'Dov'
];

class StockRecord {
  double value;
  String description;

  StockRecord({this.value = 0.0, this.description = ''});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: HomeStockView(),
  ));
}

class HomeStockView extends StatefulWidget {
  const HomeStockView({super.key});

  @override
  State<HomeStockView> createState() => _HomeStockViewState();
}

class _HomeStockViewState extends State<HomeStockView> {
  Map<String, double> currentStock = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStock();
  }

  Future<void> _loadCurrentStock() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('current_stock')
          .doc('summary')
          .get();

      setState(() {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          currentStock = {};
          for (var item in kStockItems) {
            currentStock[item] = (data[item] ?? 0.0).toDouble();
          }
        } else {
          // Initialize with zeros if no data
          currentStock = { for (var item in kStockItems) item: 0.0 };
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading current stock: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            MaterialPageRoute(
              builder: (context) => StockHishab(currentStock: currentStock),
            ),
          );
        },
        child: const Icon(Icons.table_chart),
        tooltip: 'Go to Spreadsheet',
      ),
    );
  }
}

class StockHishab extends StatefulWidget {
  final Map<String, double> currentStock;

  const StockHishab({super.key, required this.currentStock});

  @override
  State<StockHishab> createState() => _StockHishabState();
}

class _StockHishabState extends State<StockHishab> {
  final Map<DateTime, Map<String, StockRecord>> records = {};
  DateTime selectedDate = DateTime.now();
  final Map<String, TextEditingController> valueControllers = {};
  final Map<String, TextEditingController> descControllers = {};
  bool hasUnsavedChanges = false;
  late Map<String, double> currentStock;

  // Check if selected date is in the future
  bool get _isFutureDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return selectedDate.isAfter(today);
  }

  @override
  void initState() {
    super.initState();
    currentStock = {...widget.currentStock};
    for (var item in kStockItems) {
      valueControllers[item] = TextEditingController();
      descControllers[item] = TextEditingController();
    }
    _loadDateData();
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
    if (_isFutureDate) return; // Block updates for future dates

    setState(() {
      hasUnsavedChanges = true;
      final currentValue = double.tryParse(valueControllers[item]!.text) ?? 0.0;
      valueControllers[item]!.text = (currentValue + delta).toStringAsFixed(1);
    });
  }

  void _saveAllChanges() {
    if (_isFutureDate) return; // Block saves for future dates

    setState(() {
      records.putIfAbsent(selectedDate, () =>
      {for (var e in kStockItems) e: StockRecord()});

      for (var item in kStockItems) {
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
      lastDate: DateTime.now(), // Only allow dates up to today
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
    for (var item in kStockItems) {
      final record = records[selectedDate]?[item] ?? StockRecord();
      valueControllers[item]!.text = record.value.toStringAsFixed(1);
      descControllers[item]!.text = record.description;
    }
  }

  void _showDescriptionDialog(String item) {
    if (_isFutureDate) return; // Block descriptions for future dates

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
    if (_isFutureDate) { // Block submission for future dates
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot submit data for future dates'),
            backgroundColor: Colors.red,
          )
      );
      return;
    }

    try {
      _saveAllChanges();

      final dateString = _formatDate(selectedDate);
      final batch = FirebaseFirestore.instance.batch();
      final dailyCollection = FirebaseFirestore.instance.collection('daily_stock_records');
      final currentStockRef = FirebaseFirestore.instance.collection('current_stock').doc('summary');

      Map<String, double> updatedStock = {...currentStock};
      bool hasChanges = false;

      for (var item in kStockItems) {
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
        builder: (context) => const HomeStockView(),
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
                  onPressed: _isFutureDate ? null : () => setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                    _loadDateData();
                  }),
                ),
              ],
            ),
          ),

          // Future date warning
          if (_isFutureDate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Editing disabled for future dates',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
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
                  rows: kStockItems.map((item) {
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
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.all(6),
                              filled: _isFutureDate,
                              fillColor: _isFutureDate
                                  ? Colors.grey[200]
                                  : null,
                            ),
                            enabled: !_isFutureDate,
                            onChanged: (_) => hasUnsavedChanges = true,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add,
                                size: 20,
                                color: _isFutureDate ? Colors.grey : null,
                              ),
                              onPressed: _isFutureDate
                                  ? null
                                  : () => _updateItem(item, 1.0),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove,
                                size: 20,
                                color: _isFutureDate ? Colors.grey : null,
                              ),
                              onPressed: _isFutureDate
                                  ? null
                                  : () => _updateItem(item, -1.0),
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
                            color: _isFutureDate
                                ? Colors.grey
                                : record.description.isNotEmpty
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: _isFutureDate
                              ? null
                              : () => _showDescriptionDialog(item),
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
              onPressed: _isFutureDate ? null : _submitToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFutureDate ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isFutureDate ? null : _saveAllChanges,
        tooltip: 'Save Changes',
        backgroundColor: _isFutureDate ? Colors.grey : Colors.blue,
        child: Icon(Icons.save, color: _isFutureDate ? Colors.grey[400] : Colors.white),
      ),
    );
  }
}