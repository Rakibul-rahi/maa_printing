import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factory Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          )
        ],
      ),
      body: _buildUserManagementSection(),
    );
  }

  Widget _buildUserManagementSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildUserTile(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildUserTile(String userId, Map<String, dynamic> data) {
    return ListTile(
      title: Text(data['email']),
      subtitle: Text(data['role'] ?? 'No role assigned'),
      trailing: _buildRoleIndicator(data['role']),
    );
  }

  Widget _buildRoleIndicator(String? role) {
    return Chip(
      label: Text(role ?? 'user'),
      backgroundColor: _getRoleColor(role),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.blue[200]!;
      case 'editor':
        return Colors.green[200]!;
      case 'owner':
        return Colors.amber[200]!;
      default:
        return Colors.grey[200]!;
    }
  }
}