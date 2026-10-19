import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles that are allowed to use the in-app chat.
const chatRoles = {'owner', 'admin', 'editor'};

/// Id of the shared group conversation that every staff member belongs to.
const teamChatId = 'team_group';

class AppUser {
  final String uid;
  final String name;
  final String role;

  const AppUser({required this.uid, required this.name, required this.role});

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final role = (data['role'] ?? '').toString().toLowerCase();
    final name = (data['name'] ?? data['displayName'] ?? data['email'] ?? '').toString();
    return AppUser(
      uid: doc.id,
      name: name.isNotEmpty ? name : _capitalize(role.isNotEmpty ? role : 'User'),
      role: role,
    );
  }

  bool get canChat => chatRoles.contains(role);

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class ChatRoom {
  final String id;
  final bool isGroup;
  final List<String> members;
  final Map<String, String> memberNames;
  final Map<String, String> memberRoles;
  final String lastMessage;
  final String lastSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unread;

  const ChatRoom({
    required this.id,
    required this.isGroup,
    required this.members,
    required this.memberNames,
    required this.memberRoles,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageAt,
    required this.unread,
  });

  factory ChatRoom.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatRoom(
      id: doc.id,
      isGroup: data['isGroup'] == true,
      members: List<String>.from(data['members'] ?? const []),
      memberNames: Map<String, String>.from(data['memberNames'] ?? const {}),
      memberRoles: Map<String, String>.from(data['memberRoles'] ?? const {}),
      lastMessage: (data['lastMessage'] ?? '').toString(),
      lastSenderId: (data['lastSenderId'] ?? '').toString(),
      // Null while a just-sent message's server timestamp is pending.
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ??
          ((data['lastMessage'] ?? '').toString().isNotEmpty ? DateTime.now() : null),
      unread: (data['unread'] as Map<String, dynamic>? ?? const {})
          .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );
  }

  int unreadFor(String uid) => unread[uid] ?? 0;

  /// For a direct chat, the uid of the person on the other side.
  String otherMemberId(String myUid) =>
      members.firstWhere((m) => m != myUid, orElse: () => myUid);

  String titleFor(String myUid) =>
      isGroup ? 'Team Chat' : (memberNames[otherMemberId(myUid)] ?? 'Chat');
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    // createdAt is null until the server confirms a just-sent message.
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      senderId: (data['senderId'] ?? '').toString(),
      senderName: (data['senderName'] ?? '').toString(),
      senderRole: (data['senderRole'] ?? '').toString(),
      text: (data['text'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
