import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  final String roleFilter;
  const NotificationsPage({super.key, required this.roleFilter});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('to', isEqualTo: roleFilter)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error loading notifications'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final message = data['message'] ?? 'No message';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return ListTile(
                leading: const Icon(Icons.notification_important, color: Colors.indigo),
                title: Text(message),
                subtitle: timestamp != null
                    ? Text('${timestamp.toLocal()}'.split('.')[0])
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
