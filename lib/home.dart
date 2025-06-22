import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'danar_party_hishab.dart';
import 'customer_hishab.dart';
import 'daily_production_hishab.dart';
import 'stock_hishab.dart';
import 'notifications_page.dart';

class HomePage extends StatelessWidget {
  final String uid;
   HomePage({super.key, required this.uid});

  Widget _buildNotificationButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      tooltip: 'View Notifications',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsPage(roleFilter: _roleFilter),
          ),
        );
      },
    );
  }

  // Returns a Firestore query filter string based on user role
  String _roleFilter = '';

  Future<String> _getUserRoleByUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['role'] ?? 'User';
    } catch (e) {
      print('⚠️ Error fetching user role by UID: $e');
      return 'User';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.blue;
      case 'admin':
        return Colors.redAccent;
      case 'editor':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  String _welcomeMessage(String role) {
    switch (role) {
      case 'owner':
        return 'Welcome, Owner! Full access granted';
      case 'admin':
        return 'Welcome, Admin! Managerial access';
      case 'editor':
        return 'Welcome, Shad';
      default:
        return 'Welcome to Maa Printing Factory!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRoleByUid(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;
        _roleFilter = role; // set role filter for notifications
        final roleColor = _roleColor(role);
        final welcomeMessage = _welcomeMessage(role);

        return PopScope(
          canPop: false, // This is equivalent to onWillPop: () async => false,
          onPopInvoked: (bool didPop) {
            // If canPop is false, didPop will always be false when the back button is pressed.
            // You can add a dialog or other logic here if you want to
            // inform the user that they can't go back, but since your original
            // onWillPop always returned false, you might not need anything here.
            // For example, to show a toast:
            // if (!didPop) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Cannot go back from this screen.')),
            //   );
            // }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Maa Printing Factory'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      if (role == 'owner' || role == 'admin') _buildNotificationButton(context),
                      Chip(
                        label: Text(
                          role,
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
                    Text(
                      welcomeMessage,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPartyDueCard(),
                    const SizedBox(height: 20),
                    _buildCustomerReceivableCard(),
                    const SizedBox(height: 20),
                    _buildAccountingButtons(context, role),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  Widget _buildAccountingButtons(BuildContext context, String role) {
    return Column(
      children: [
        _AccountingButton(
          icon: Icons.account_balance_wallet,
          label: 'Danar Party Heshab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DanarPartyHishab()),
          ),
        ),
        const SizedBox(height: 20),
        _AccountingButton(
          icon: Icons.groups,
          label: 'Customer Heshab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHishab()),
          ),
        ),
        const SizedBox(height: 20),
        _AccountingButton(
          icon: Icons.bar_chart,
          label: 'Daily Production Heshab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DailyProductionHishab()),
          ),
        ),
        const SizedBox(height: 20),
        _AccountingButton(
          icon: Icons.inventory,
          label: 'Powder Heshab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeStockView()),
          ),
        ),
        if (role == 'admin')
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: _AccountingButton(
              icon: Icons.notifications_active,
              label: 'Notify Owner (Accounts Updated)',
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('notifications').add({
                    'to': 'owner',
                    'message': 'Accounts have been updated by Admin.',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Notification sent to Owner')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Failed to send: $e')),
                  );
                }
              },
            ),
          ),
        if (role == 'owner') ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance.collection('notifications').add({
                          'to': 'admin',
                          'message': '✅ Owner approved the accounts.',
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Sent to Admin')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('❌ Failed to send: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Accounts OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance.collection('notifications').add({
                          'to': 'admin',
                          'message': '❌ Owner flagged issues in the accounts.',
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ Alert sent to Admin')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('❌ Failed to send: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('Not OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
