import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'party_transaction.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

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
  final Set<String> _selectedTransactionIds = {};
  bool _isSelectionMode = false;

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
      appBar: AppBar(
        title: Text(context.l10n.transactionsTitle(widget.partyName)),
        actions: _isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteSelected,
          ),
        ]
            : null,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactionsRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.errorLoadingTransactions));
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
                    Text(context.l10n.totalBill(context.money(totalAmount))),
                    Text(context.l10n.totalPaid(context.money(totalPaid))),
                    Text(
                      balance < 0
                          ? context.l10n.dueAmount(context.money(balance.abs()))
                          : context.l10n.advanceAmount(context.money(balance)),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balance < 0 ? context.dangerColor : context.successColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: transactions.isEmpty
                    ? Center(child: Text(context.l10n.noTransactions))
                    : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      leading: _isSelectionMode
                          ? Checkbox(
                        value: _selectedTransactionIds.contains(tx.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedTransactionIds.add(tx.id);
                            } else {
                              _selectedTransactionIds.remove(tx.id);
                            }
                            _isSelectionMode = _selectedTransactionIds.isNotEmpty;
                          });
                        },
                      )
                          : null,
                      onLongPress: () {
                        setState(() {
                          _isSelectionMode = true;
                          _selectedTransactionIds.add(tx.id);
                        });
                      },
                      onTap: _isSelectionMode
                          ? () {
                        setState(() {
                          if (_selectedTransactionIds.contains(tx.id)) {
                            _selectedTransactionIds.remove(tx.id);
                            _isSelectionMode = _selectedTransactionIds.isNotEmpty;
                          } else {
                            _selectedTransactionIds.add(tx.id);
                          }
                        });
                      }
                          : null,
                      title: Text(context.l10n.amountPaidLine(context.money(tx.amount), context.money(tx.paid))),
                      subtitle: Text(tx.description),
                      trailing: Text(
                        context.date(tx.date),
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

  void _confirmDeleteSelected() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteSelectedTransactions),
        content: Text(context.l10n.deleteTransactionsConfirm(_selectedTransactionIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              for (var id in _selectedTransactionIds) {
                await transactionsRef.doc(id).delete();
              }
              setState(() {
                _selectedTransactionIds.clear();
                _isSelectionMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.transactionsDeleted)),
              );
            },
            child: Text(context.l10n.delete),
          ),
        ],
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
        title: Text(context.l10n.addTransaction),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: context.l10n.amount),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => amount = double.parse(value!),
                  validator: (value) =>
                  value == null || value.isEmpty ? context.l10n.requiredField : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: context.l10n.paid),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => paid = double.parse(value!),
                  validator: (value) =>
                  value == null || value.isEmpty ? context.l10n.requiredField : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: context.l10n.description),
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
                  child: Text(context.l10n.selectDate),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
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

                // Update summary
                final partyRef = FirebaseFirestore.instance
                    .collection('partyAccounts')
                    .doc(widget.partyId);

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
            child: Text(context.l10n.add),
          ),
        ],
      ),
    );
  }
}
