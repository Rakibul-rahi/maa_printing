// customer_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'party_transaction.dart';

class CustomerTransactionScreen extends StatefulWidget {
  final String partyId;
  final String partyName;

  const CustomerTransactionScreen({
    Key? key,
    required this.partyId,
    required this.partyName,
  }) : super(key: key);

  @override
  State<CustomerTransactionScreen> createState() => _CustomerTransactionScreenState();
}

class _CustomerTransactionScreenState extends State<CustomerTransactionScreen> {
  late final CollectionReference transactionsRef;

  @override
  void initState() {
    super.initState();
    // Changed to customerAccounts collection
    transactionsRef = FirebaseFirestore.instance
        .collection('customerAccounts')
        .doc(widget.partyId)
        .collection('transactions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.partyName} Transactions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactionsRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading transactions."));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          double totalSales = 0;  // Renamed from totalAmount
          double totalReceived = 0;  // Renamed from totalPaid

          final transactions = docs.map((doc) {
            final tx = PartyTransaction.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            totalSales += tx.amount;
            totalReceived += tx.paid;
            return tx;
          }).toList();

          final balance = totalSales - totalReceived;  // Inverted calculation

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Sales: ৳${totalSales.toStringAsFixed(2)}'),
                    Text('Total Received: ৳${totalReceived.toStringAsFixed(2)}'),
                    Text(
                      balance > 0
                          ? 'Due: ৳${balance.toStringAsFixed(2)}'
                          : 'Advance: ৳${balance.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balance > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text("No transactions yet."))
                    : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      title: Text('Sale: ৳${tx.amount}, Received: ৳${tx.paid}'),
                      subtitle: Text(tx.description),
                      trailing: Text(
                        '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    double saleAmount = 0;
    double receivedAmount = 0;
    String description = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Customer Transaction'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Sale Amount'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => saleAmount = double.parse(value!),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Received Amount'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => receivedAmount = double.parse(value!),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => description = value ?? '',
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                // Add transaction to customer collection
                await transactionsRef.add({
                  'amount': saleAmount,
                  'paid': receivedAmount,
                  'description': description,
                  'date': selectedDate,
                });

                // Update customer account summary
                final customerRef = FirebaseFirestore.instance
                    .collection('customerAccounts')
                    .doc(widget.partyId);

                await FirebaseFirestore.instance.runTransaction((tx) async {
                  final snapshot = await tx.get(customerRef);
                  final data = snapshot.data()!;
                  final prevSales = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
                  final prevReceived = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;

                  tx.update(customerRef, {
                    'totalBill': prevSales + saleAmount,
                    'totalPaid': prevReceived + receivedAmount,
                    'lastTransactionDate': selectedDate,
                    'updatedAt': DateTime.now(),
                  });
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}