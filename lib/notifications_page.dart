import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

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
        title: Text(context.l10n.notifications),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.errorLoadingNotifications));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text(context.l10n.noNotifications));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final message = data['message'] ?? context.l10n.noMessage;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return ListTile(
                leading: Icon(Icons.notification_important, color: context.brandTextColor),
                title: Text(message),
                subtitle: timestamp != null
                    ? Text(context.dateTime(timestamp.toLocal()))
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
