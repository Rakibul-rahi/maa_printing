import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maa Printing Factory'),
        centerTitle: true,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔵 Factory Logo
              Image.asset(
                'assets/maa.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.factory, size: 100, color: Colors.blue),
              ),
              const SizedBox(height: 20),

              // 🔴 TOTAL DUE TO DANAR PARTIES
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('partyAccounts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error fetching party data");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  double totalDue = 0;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final totalBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
                    final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;

                    final due = totalBill - totalPaid;
                    if (due > 0) totalDue += due;
                  }

                  return _buildAmountCard(
                    title: 'Total Due to Danar Parties',
                    amount: totalDue,
                    color: Colors.redAccent,
                    icon: Icons.account_balance_wallet,
                  );
                },
              ),
              const SizedBox(height: 20),

              // 🟢 TOTAL RECEIVABLE FROM CUSTOMERS
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('customerAccounts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error fetching customer data");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  double totalReceivable = 0;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final totalBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
                    final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;

                    final due = totalBill - totalPaid;
                    if (due > 0) totalReceivable += due;
                  }

                  return _buildAmountCard(
                    title: 'Total Receivable from Customers',
                    amount: totalReceivable,
                    color: Colors.green,
                    icon: Icons.attach_money,
                  );
                },
              ),
              const SizedBox(height: 20),

              // 🔵 Accounting Buttons
              _buildAccountingButton(
                context: context,
                icon: Icons.account_balance_wallet,
                label: 'Danar Party Hishab',
                routeName: '/danar-party',
              ),
              const SizedBox(height: 20),

              _buildAccountingButton(
                context: context,
                icon: Icons.groups,
                label: 'Customer Hishab',
                routeName: '/customer',
              ),
              const SizedBox(height: 20),

              _buildAccountingButton(
                context: context,
                icon: Icons.bar_chart,
                label: 'Daily Production Hishab',
                routeName: '/daily-production',
              ),
              const SizedBox(height: 20),

              // NEW STOCK HISAB BUTTON
              _buildAccountingButton(
                context: context,
                icon: Icons.inventory,
                label: 'Stock Hishab',
                routeName: '/stock',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountingButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, routeName),
        icon: Icon(icon, size: 30),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}