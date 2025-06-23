import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ready_goods_model.dart';
import 'ready_goods_history_screen.dart'; // Import your history screen here

class ReadyGoodsInventoryScreen extends StatefulWidget {
  const ReadyGoodsInventoryScreen({Key? key}) : super(key: key);

  @override
  State<ReadyGoodsInventoryScreen> createState() => _ReadyGoodsInventoryScreenState();
}

class _ReadyGoodsInventoryScreenState extends State<ReadyGoodsInventoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> productTypes = ['Pani', '1 No', '2 No', '3 No'];
  final List<String> categories = ['Boro', 'Choto'];

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text('Are you sure you want to reset the entire inventory? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              await _resetInitialAmounts(); // Then reset inventory
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetInitialAmounts() async {
    for (var type in productTypes) {
      for (var cat in categories) {
        await _firestore.collection('readyGoods').doc('$type-$cat').set({
          'amount': 0,
          'unit': cat == 'Boro' ? 'KG' : 'Bundle',
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastShift': '-',
        });

        // Optional: Clear history for reset (uncomment if desired)
        /*
        final historyCollection = _firestore.collection('readyGoods').doc('$type-$cat').collection('history');
        final snapshots = await historyCollection.get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
        */
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory reset.')),
      );
    }
  }

  void _showUpdateDialog(String type, String category) {
    final formKey = GlobalKey<FormState>();
    double quantity = 0.0;
    String shift = 'Day';
    DateTime selectedDate = DateTime.now();
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update $type ($category)'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: category == 'Boro' ? 'Amount in KG' : 'Amount in Bundle',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => quantity = double.parse(value!),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: shift,
                items: ['Day', 'Night']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => shift = val!,
                decoration: const InputDecoration(labelText: 'Shift'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: const Text('Pick Date'),
              ),
              Row(
                children: [
                  const Text('Operation:'),
                  const SizedBox(width: 10),
                  DropdownButton<bool>(
                    value: isAddition,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Add')),
                      DropdownMenuItem(value: false, child: Text('Subtract')),
                    ],
                    onChanged: (val) => setState(() => isAddition = val!),
                  )
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final docRef = _firestore.collection('readyGoods').doc('$type-$category');

                await _firestore.runTransaction((tx) async {
                  final snapshot = await tx.get(docRef);
                  final prevAmount = (snapshot.data()?['amount'] as num?)?.toDouble() ?? 0.0;

                  final updatedAmount = isAddition ? prevAmount + quantity : prevAmount - quantity;
                  tx.update(docRef, {
                    'amount': updatedAmount,
                    'lastUpdated': Timestamp.fromDate(selectedDate),
                    'lastShift': shift,
                  });

                  // Add history record
                  final historyRef = docRef.collection('history').doc();
                  tx.set(historyRef, {
                    'operation': isAddition ? 'Add' : 'Subtract',
                    'quantity': quantity,
                    'date': Timestamp.fromDate(selectedDate),
                    'shift': shift,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                });

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready Goods Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Inventory',
            onPressed: () => _showResetConfirmationDialog(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('readyGoods').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView(
            children: productTypes.expand((type) {
              return categories.map((cat) {
                QueryDocumentSnapshot? doc;
                try {
                  doc = docs.firstWhere((d) => d.id == '$type-$cat');
                } catch (e) {
                  doc = null;
                }

                ReadyGoodsItem? item;
                if (doc != null) {
                  item = ReadyGoodsItem.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('$type ($cat)'),
                    subtitle: Text(
                      'Amount: ${item?.amount ?? 0} ${item?.unit ?? (cat == 'Boro' ? 'KG' : 'Bundle')} • '
                          'Shift: ${item?.lastShift ?? '-'} • '
                          'Date: ${item?.lastUpdated != null ? "${item!.lastUpdated!.day}/${item.lastUpdated!.month}/${item.lastUpdated!.year}" : "-"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.history),
                          tooltip: 'View History',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadyGoodsHistoryScreen(type: type, category: cat),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Quantity',
                          onPressed: () => _showUpdateDialog(type, cat),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          );
        },
      ),
    );
  }
}
