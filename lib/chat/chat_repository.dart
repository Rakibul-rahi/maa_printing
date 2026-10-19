import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_models.dart';

/// Firestore layout:
///   chats/{chatId}                 -> ChatRoom (members, last message, unread counts)
///   chats/{chatId}/messages/{id}   -> ChatMessage
class ChatRepository {
  final FirebaseFirestore _db;
  ChatRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _chats => _db.collection('chats');

  static String directChatId(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<AppUser?> watchUser(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);

  Stream<List<AppUser>> watchStaff() => _db.collection('users').snapshots().map((snap) =>
      snap.docs.map(AppUser.fromDoc).where((u) => u.canChat).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));

  /// Sorted client-side so no composite index is needed.
  Stream<List<ChatRoom>> watchChatsFor(String uid) => _chats
      .where('members', arrayContains: uid)
      .snapshots()
      .map((snap) => snap.docs.map(ChatRoom.fromDoc).toList()
        ..sort((a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(a.lastMessageAt ?? DateTime(0))));

  Stream<ChatRoom?> watchChat(String chatId) =>
      _chats.doc(chatId).snapshots().map((doc) => doc.exists ? ChatRoom.fromDoc(doc) : null);

  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 200}) => _chats
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());

  Future<String> ensureDirectChat(AppUser me, AppUser other) async {
    final id = directChatId(me.uid, other.uid);
    await _chats.doc(id).set({
      'isGroup': false,
      'members': [me.uid, other.uid],
      'memberNames': {me.uid: me.name, other.uid: other.name},
      'memberRoles': {me.uid: me.role, other.uid: other.role},
    }, SetOptions(merge: true));
    return id;
  }

  /// Keeps the team group's member list in sync with the current staff list.
  Future<String> ensureTeamChat(List<AppUser> staff) async {
    await _chats.doc(teamChatId).set({
      'isGroup': true,
      'members': staff.map((u) => u.uid).toList(),
      'memberNames': {for (final u in staff) u.uid: u.name},
      'memberRoles': {for (final u in staff) u.uid: u.role},
    }, SetOptions(merge: true));
    return teamChatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required AppUser sender,
    required List<String> members,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final chatRef = _chats.doc(chatId);
    final batch = _db.batch();
    batch.set(chatRef.collection('messages').doc(), {
      'senderId': sender.uid,
      'senderName': sender.name,
      'senderRole': sender.role,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(chatRef, {
      'lastMessage': trimmed,
      'lastSenderId': sender.uid,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread': {
        for (final m in members)
          if (m != sender.uid) m: FieldValue.increment(1),
      },
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> markRead(String chatId, String uid) => _chats.doc(chatId).set({
        'unread': {uid: 0},
      }, SetOptions(merge: true));
}
