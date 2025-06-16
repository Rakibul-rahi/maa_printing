import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'danar_party_model.dart';
import 'danar_party_transaction_screen.dart';

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
        title: const Text('Delete Party'),
        content: Text('Are you sure you want to delete "$partyName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('partyAccounts').doc(partyId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Party deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danar Party Hishab'),
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
                hintText: 'Search by party name...',
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final accounts = snapshot.data!.docs;
                if (accounts.isEmpty) {
                  return const Center(child: Text('No party accounts found'));
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
                    Text('Contact: ${account.contactPerson}'),
                    Text('Phone: ${account.phone}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        Chip(
                          label: Text('Due: ₹${account.dueAmount.toStringAsFixed(2)}'),
                          backgroundColor: Colors.red[100],
                        ),
                        Chip(
                          label: Text('Advance: ₹${account.advanceAmount.toStringAsFixed(2)}'),
                          backgroundColor: Colors.green[100],
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
                  Text(
                    '₹${account.totalBill.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last: ${_formatDate(account.lastTransactionDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteParty(account.id, account.partyName),
                    tooltip: 'Delete Party',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
  }

  void _showAddPartyDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', contact = '', phone = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Party'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Party Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact Person'),
                onSaved: (v) => contact = v!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => phone = v!,
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
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
