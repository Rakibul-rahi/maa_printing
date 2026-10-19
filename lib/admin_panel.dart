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
  final List<String> _roles = ['user', 'editor', 'admin', 'owner'];

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
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _auth.signOut(),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'User Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildUserManagementSection()),
        ],
      ),
    );
  }

  Widget _buildUserManagementSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildUserTile(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildUserTile(String userId, Map<String, dynamic> data) {
    final isCurrentUser = userId == _currentUser.uid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(data['role']),
          child: Text(
            data['email']?.toString().substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          data['email'] ?? 'No email',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Role: ${data['role'] ?? 'user'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoleChip(data['role']),
            if (!isCurrentUser)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showRoleEditor(userId, data['role']),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String? role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleColor(role),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role?.toUpperCase() ?? 'USER',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.blue;
      case 'editor':
        return Colors.green;
      case 'owner':
        return Colors.amber[700]!;
      default:
        return Colors.grey;
    }
  }

  void _showRoleEditor(String userId, String? currentRole) {
    String? selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<String>(
              value: selectedRole,
              isExpanded: true,
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
              onChanged: (newRole) => setState(() => selectedRole = newRole),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedRole != null && selectedRole != currentRole) {
                await _firestore.collection('users').doc(userId).update({
                  'role': selectedRole
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}