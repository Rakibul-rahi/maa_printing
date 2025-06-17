import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'danar_party_hishab.dart';
import 'customer_hishab.dart';
import 'daily_production_hishab.dart';
import 'stock_hishab.dart';

class HomePage extends StatelessWidget {
  final String userRole;
  const HomePage({super.key, required this.userRole});

  String get welcomeMessage {
    switch (userRole) {
      case 'Owner':
        return 'Welcome, Owner! Full access granted';
      case 'Admin':
        return 'Welcome, Admin! Managerial access';
      case 'Editor':
        return 'Welcome, Editor! Limited access';
      default:
        return 'Welcome to Maa Printing Factory!';
    }
  }

  Color get roleColor {
    switch (userRole) {
      case 'Owner':
        return Colors.deepPurple;
      case 'Admin':
        return Colors.blue;
      case 'Editor':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maa Printing Factory'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      userRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: roleColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sign out',
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildLogoSection(),
                const SizedBox(height: 10),
                _buildWelcomeMessage(),
                const SizedBox(height: 20),
                _buildPartyDueCard(),
                const SizedBox(height: 20),
                _buildCustomerReceivableCard(),
                const SizedBox(height: 20),
                _buildAccountingButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Image.asset(
      'assets/maa.png',
      width: 120,
      height: 120,
      errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.factory, size: 100, color: Colors.blue),
    );
  }

  Widget _buildWelcomeMessage() {
    return Text(
      welcomeMessage,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: roleColor,
      ),
    );
  }

  Widget _buildPartyDueCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('partyAccounts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _ErrorText("Error fetching party data");
        if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingIndicator();

        double totalDue = 0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final totalBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
          final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;
          final due = totalBill - totalPaid;
          if (due > 0) totalDue += due;
        }

        return _AmountCard(
          title: 'Total Due to Danar Parties',
          amount: totalDue,
          color: Colors.redAccent,
          icon: Icons.hourglass_bottom_sharp,
        );
      },
    );
  }

  Widget _buildCustomerReceivableCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('customerAccounts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _ErrorText("Error fetching customer data");
        if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingIndicator();

        double totalReceivable = 0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final totalBill = (data['totalBill'] as num?)?.toDouble() ?? 0.0;
          final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;
          final due = totalBill - totalPaid;
          if (due > 0) totalReceivable += due;
        }

        return _AmountCard(
          title: 'Total Receivable from Customers',
          amount: totalReceivable,
          color: Colors.green,
          icon: Icons.attach_money,
        );
      },
    );
  }

  Widget _buildAccountingButtons(BuildContext context) {
    return Column(
      children: [
        _AccountingButton(
          icon: Icons.account_balance_wallet,
          label: 'Danar Party Hishab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DanarPartyHishab()),
          ),
        ),
        const SizedBox(height: 20),
        _AccountingButton(
          icon: Icons.groups,
          label: 'Customer Hishab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHishab()),
          ),
        ),
        const SizedBox(height: 20),
        _AccountingButton(
          icon: Icons.bar_chart,
          label: 'Daily Production Hishab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DailyProductionHishab()),
          ),
        ),
        const SizedBox(height: 20),
        _AccountingButton(
          icon: Icons.inventory,
          label: 'Stock Hishab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeStockView(), // Fixed navigation
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _AmountCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AccountingButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(message, style: const TextStyle(color: Colors.red));
  }
}
