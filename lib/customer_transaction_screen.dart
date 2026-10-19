import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'party_transaction.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

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
  final Set<String> _selectedTransactionIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    transactionsRef = FirebaseFirestore.instance
        .collection('customerAccounts')
        .doc(widget.partyId)
        .collection('transactions');
  }

  Future<void> _recalculateBalance() async {
    final querySnapshot = await transactionsRef.get();
    double totalSales = 0;
    double totalReceived = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalSales += (data['amount'] as num?)?.toDouble() ?? 0;
      totalReceived += (data['paid'] as num?)?.toDouble() ?? 0;
    }

    await FirebaseFirestore.instance.collection('customerAccounts').doc(widget.partyId).update({
      'totalBill': totalSales,
      'totalPaid': totalReceived,
      'updatedAt': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.balanceRecalculated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.transactionsTitle(widget.partyName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.recalculate,
            onPressed: _recalculateBalance,
          ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteSelectedTransactions,
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactionsRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          double totalSales = 0, totalReceived = 0;

          final transactions = docs.map((doc) {
            final tx = PartyTransaction.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            totalSales += tx.amount;
            totalReceived += tx.paid;
            return tx;
          }).toList();

          final balance = totalSales - totalReceived;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.totalSales(context.money(totalSales))),
                    Text(context.l10n.totalReceived(context.money(totalReceived))),
                    Text(
                      balance > 0
                          ? context.l10n.dueAmount(context.money(balance))
                          : context.l10n.advanceAmount(context.money(balance.abs())),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balance > 0 ? context.dangerColor : context.successColor,
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
                        onChanged: (selected) {
                          setState(() {
                            selected == true
                                ? _selectedTransactionIds.add(tx.id)
                                : _selectedTransactionIds.remove(tx.id);
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
                          _selectedTransactionIds.contains(tx.id)
                              ? _selectedTransactionIds.remove(tx.id)
                              : _selectedTransactionIds.add(tx.id);
                          _isSelectionMode = _selectedTransactionIds.isNotEmpty;
                        });
                      }
                          : null,
                      title: Text(context.l10n.saleReceivedLine(context.money(tx.amount), context.money(tx.paid))),
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

  void _confirmDeleteSelectedTransactions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteSelectedTransactions),
        content: Text(context.l10n.deleteTransactionsConfirm(_selectedTransactionIds.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              for (var id in _selectedTransactionIds) {
                await transactionsRef.doc(id).delete();
              }
              _recalculateBalance();
              setState(() {
                _selectedTransactionIds.clear();
                _isSelectionMode = false;
              });
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    double saleAmount = 0, receivedAmount = 0;
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
                  decoration: InputDecoration(labelText: context.l10n.saleAmount),
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                  onSaved: (value) => saleAmount = double.parse(value!),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: context.l10n.receivedAmount),
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                  onSaved: (value) => receivedAmount = double.parse(value!),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                await transactionsRef.add({
                  'amount': saleAmount,
                  'paid': receivedAmount,
                  'description': description,
                  'date': selectedDate,
                });
                await _recalculateBalance();
                Navigator.pop(context);
              }
            },
            child: Text(context.l10n.add),
          ),
        ],
      ),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return context.l10n.requiredField;
    final num = double.tryParse(value);
    if (num == null || num < 0) return context.l10n.enterValidNonNegative;
    return null;
  }
}
