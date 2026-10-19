import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_model.dart';
import 'customer_transaction_screen.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

class CustomerHishab extends StatefulWidget {
  const CustomerHishab({super.key});

  @override
  State<CustomerHishab> createState() => _CustomerHishabState();
}

class _CustomerHishabState extends State<CustomerHishab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  void _confirmDeleteParty(String partyId, String partyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteCustomer),
        content: Text(context.l10n.deleteConfirmName(partyName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final txRef = _firestore.collection('customerAccounts').doc(partyId).collection('transactions');
                final txSnapshot = await txRef.get();
                for (var doc in txSnapshot.docs) {
                  await doc.reference.delete();
                }
                await _firestore.collection('customerAccounts').doc(partyId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.customerDeleted)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.failedToDelete(e))),
                );
              }
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _recalculateBalanceForCustomer(String customerId) async {
    final transactionsRef = _firestore.collection('customerAccounts').doc(customerId).collection('transactions');
    final querySnapshot = await transactionsRef.get();

    double totalSales = 0;
    double totalReceived = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      totalSales += (data['amount'] as num?)?.toDouble() ?? 0;
      totalReceived += (data['paid'] as num?)?.toDouble() ?? 0;
    }

    await _firestore.collection('customerAccounts').doc(customerId).update({
      'totalBill': totalSales,
      'totalPaid': totalReceived,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.customerAccounts),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.searchCustomer,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('customerAccounts').orderBy('updatedAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final filtered = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['partyName']?.toString().toLowerCase() ?? '';
                  final searchTerm = _searchController.text.toLowerCase();
                  return name.contains(searchTerm);
                }).toList();

                if (filtered.isEmpty) return Center(child: Text(context.l10n.noMatchingCustomers));

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final account = PartyAccount.fromMap(doc.id, data);
                    return _buildPartyCard(account);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPartyCard(PartyAccount account) {
    final balance = account.totalBill - account.totalPaid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () async {
          await _recalculateBalanceForCustomer(account.id); // ensure balance is up to date
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerTransactionScreen(
                partyId: account.id,
                partyName: account.partyName,
              ),
            ),
          );
        },
        title: Text(account.partyName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.contactLabel(account.contactPerson)),
            Text(context.l10n.phoneLabel(account.phone)),
            const SizedBox(height: 4),
            Text(
              balance >= 0
                  ? context.l10n.dueAmount(context.money(balance))
                  : context.l10n.advanceAmount(context.money(balance.abs())),
              style: TextStyle(color: balance >= 0 ? context.dangerColor : context.successColor),
            ),
            const SizedBox(height: 4),
            Text(context.l10n.lastDate(context.date(account.lastTransactionDate)), style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: context.dangerColor),
          onPressed: () => _confirmDeleteParty(account.id, account.partyName),
        ),
      ),
    );
  }

  void _showAddCustomerDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', contact = '', phone = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.addCustomer),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.customerName),
                validator: (v) => v == null || v.isEmpty ? context.l10n.requiredField : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.contactPerson),
                onSaved: (v) => contact = v ?? '',
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.phone),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? context.l10n.requiredField : null,
                onSaved: (v) => phone = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final now = DateTime.now();
                final newAccount = PartyAccount(
                  partyName: name,
                  contactPerson: contact,
                  phone: phone,
                  totalBill: 0,
                  totalPaid: 0,
                  lastTransactionDate: now,
                  createdAt: now,
                  updatedAt: now,
                );
                try {
                  await _firestore.collection('customerAccounts').add(newAccount.toMap());
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.errorWithMessage(e))),
                  );
                }
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }
}
