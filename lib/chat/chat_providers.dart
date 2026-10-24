import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_models.dart';
import 'chat_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's profile (role + name) from the `users` collection.
final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(chatRepositoryProvider).watchUser(uid);
});

/// Every owner / admin / editor, used to start conversations.
final staffProvider = StreamProvider<List<AppUser>>((ref) {
  // Rebuild on login/logout so a stale permission-denied from a previous
  // (or signed-out) session is never reused.
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const <AppUser>[]);
  return ref.watch(chatRepositoryProvider).watchStaff();
});

/// Conversations the current user belongs to, newest first.
final myChatsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).watchChatsFor(uid);
});

final chatRoomProvider = StreamProvider.autoDispose.family<ChatRoom?, String>(
  (ref, chatId) => ref.watch(chatRepositoryProvider).watchChat(chatId),
);

/// Messages for a chat, newest first (for a reversed ListView).
final messagesProvider = StreamProvider.autoDispose.family<List<ChatMessage>, String>(
  (ref, chatId) => ref.watch(chatRepositoryProvider).watchMessages(chatId),
);

/// Total unread messages across all chats, for the badge on the home screen.
final totalUnreadProvider = Provider<int>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  final chats = ref.watch(myChatsProvider).valueOrNull ?? const [];
  if (uid == null) return 0;
  return chats.fold(0, (sum, c) => sum + c.unreadFor(uid));
});
