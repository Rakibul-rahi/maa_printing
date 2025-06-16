import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'party_transaction.dart';
class PartyTransactionScreen extends StatefulWidget {
  final String partyId;
  final String partyName;

  const PartyTransactionScreen({
    Key? key,
    required this.partyId,
    required this.partyName,
  }) : super(key: key);

  @override
  State<PartyTransactionScreen> createState() => _PartyTransactionScreenState();
}

class _PartyTransactionScreenState extends State<PartyTransactionScreen> {
  late final CollectionReference transactionsRef;

  @override
  void initState() {
    super.initState();
    transactionsRef = FirebaseFirestore.instance
        .collection('partyAccounts')
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

          double totalAmount = 0;
          double totalPaid = 0;

          final transactions = docs.map((doc) {
            final tx = PartyTransaction.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            totalAmount += tx.amount;
            totalPaid += tx.paid;
            return tx;
          }).toList();

          final balance = totalPaid - totalAmount;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Bill: ৳${totalAmount.toStringAsFixed(2)}'),
                    Text('Total Paid: ৳${totalPaid.toStringAsFixed(2)}'),
                    Text(
                      balance < 0
                          ? 'Due: ৳${(balance.abs()).toStringAsFixed(2)}'
                          : 'Advance: ৳${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balance < 0 ? Colors.red : Colors.green,
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
                      title: Text('Amount: ৳${tx.amount}, Paid: ৳${tx.paid}'),
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
    double amount = 0;
    double paid = 0;
    String description = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => amount = double.parse(value!),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Paid'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => paid = double.parse(value!),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                // Add transaction
                await transactionsRef.add({
                  'amount': amount,
                  'paid': paid,
                  'description': description,
                  'date': selectedDate,
                });

                // Update summary in partyAccounts
                final partyRef = FirebaseFirestore.instance.collection('partyAccounts').doc(widget.partyId);

                await FirebaseFirestore.instance.runTransaction((tx) async {
                  final snapshot = await tx.get(partyRef);
                  final data = snapshot.data()!;
                  final prevBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
                  final prevPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;

                  tx.update(partyRef, {
                    'totalBill': prevBill + amount,
                    'totalPaid': prevPaid + paid,
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
