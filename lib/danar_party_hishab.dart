import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'danar_party_model.dart';
import 'danar_party_transaction_screen.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

class DanarPartyHishab extends StatefulWidget {
  const DanarPartyHishab({super.key});

  @override
  State<DanarPartyHishab> createState() => _DanarPartyHishabState();
}

class _DanarPartyHishabState extends State<DanarPartyHishab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  void _confirmDeleteParty(String partyId, String partyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteParty),
        content: Text(context.l10n.deleteConfirmName(partyName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('partyAccounts').doc(partyId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.partyDeleted)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.danarPartyHishab),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.searchParty,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
              stream: _firestore.collection('partyAccounts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(context.l10n.errorWithMessage(snapshot.error!)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final accounts = snapshot.data!.docs;
                if (accounts.isEmpty) {
                  return Center(child: Text(context.l10n.noPartyAccounts));
                }

                final filteredAccounts = accounts.where((account) {
                  final data = account.data() as Map<String, dynamic>;
                  final partyName = data['partyName']?.toString().toLowerCase() ?? '';
                  final searchTerm = _searchController.text.toLowerCase();
                  return partyName.contains(searchTerm);
                }).toList();

                return ListView.builder(
                  itemCount: filteredAccounts.length,
                  itemBuilder: (context, index) {
                    final doc = filteredAccounts[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final account = DanarPartyAccount.fromMap(doc.id, data);
                    return _buildPartyCard(account);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPartyDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPartyCard(DanarPartyAccount account) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PartyTransactionScreen(
                partyId: account.id,
                partyName: account.partyName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Party info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.partyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(context.l10n.contactLabel(account.contactPerson)),
                    Text(context.l10n.phoneLabel(account.phone)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        Chip(
                          label: Text(context.l10n.dueAmount(context.money(account.dueAmount))),
                          backgroundColor: context.dangerContainer,
                        ),
                        Chip(
                          label: Text(context.l10n.advanceAmount(context.money(account.advanceAmount))),
                          backgroundColor: context.successContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right side - Amount and delete button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [


                  const SizedBox(height: 4),
                  Text(
                    context.l10n.lastDate(context.date(account.lastTransactionDate)),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.delete, color: context.dangerColor),
                    onPressed: () => _confirmDeleteParty(account.id, account.partyName),
                    tooltip: context.l10n.deleteParty,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showAddPartyDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', contact = '', phone = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.addParty),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.partyName),
                validator: (v) => v == null || v.isEmpty ? context.l10n.requiredField : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.contactPerson),
                onSaved: (v) => contact = v!,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final now = DateTime.now();
                final newAccount = DanarPartyAccount(
                  partyName: name,
                  contactPerson: contact,
                  phone: phone,
                  totalBill: 0.0,
                  totalPaid: 0.0,
                  lastTransactionDate: now,
                  createdAt: now,
                  updatedAt: now,
                );

                try {
                  await _firestore.collection('partyAccounts').add(newAccount.toMap());
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
