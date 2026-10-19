import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_models.dart';
import 'chat_providers.dart';
import 'chat_repository.dart';
import 'chat_room_screen.dart';
import '../l10n/l10n.dart';

/// Lists the team group chat plus a direct chat with every other owner/admin/editor.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(currentAppUserProvider);
    final staffAsync = ref.watch(staffProvider);
    final chats = ref.watch(myChatsProvider).valueOrNull ?? const <ChatRoom>[];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chat), centerTitle: true),
      body: Builder(builder: (context) {
        if (meAsync.isLoading || staffAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = meAsync.error ?? staffAsync.error;
        if (error != null) {
          return Center(
            child: Text(context.l10n.errorWithMessage(error), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          );
        }

        final me = meAsync.value;
        if (me == null || !me.canChat) {
          return Center(child: Text(context.l10n.chatOnlyStaff));
        }

        final staff = staffAsync.value ?? const <AppUser>[];
        final chatById = {for (final c in chats) c.id: c};

        final entries = <_ChatEntry>[
          for (final u in staff.where((u) => u.uid != me.uid))
            _ChatEntry(user: u, room: chatById[ChatRepository.directChatId(me.uid, u.uid)]),
        ]..sort((a, b) {
            final at = a.room?.lastMessageAt, bt = b.room?.lastMessageAt;
            if (at == null && bt == null) return a.user.name.compareTo(b.user.name);
            if (at == null) return 1;
            if (bt == null) return -1;
            return bt.compareTo(at);
          });

        return ListView(
          children: [
            _ChatTile(
              me: me,
              room: chatById[teamChatId],
              title: context.l10n.teamChat,
              subtitleFallback: context.l10n.everyoneMembers(staff.length),
              leading: const CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.groups, color: Colors.white),
              ),
              onTap: () async {
                final id = await ref.read(chatRepositoryProvider).ensureTeamChat(staff);
                if (context.mounted) _open(context, id, context.l10n.teamChat);
              },
            ),
            const Divider(height: 1),
            for (final e in entries) ...[
              _ChatTile(
                me: me,
                room: e.room,
                title: e.user.name,
                subtitleFallback: context.l10n.tapToStartChatting,
                leading: CircleAvatar(
                  backgroundColor: roleColor(e.user.role),
                  child: Text(
                    e.user.name.isNotEmpty ? e.user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                badge: e.user.role,
                onTap: () async {
                  final id = await ref.read(chatRepositoryProvider).ensureDirectChat(me, e.user);
                  if (context.mounted) _open(context, id, e.user.name);
                },
              ),
              const Divider(height: 1, indent: 72),
            ],
          ],
        );
      }),
    );
  }

  void _open(BuildContext context, String chatId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId, title: title)),
    );
  }
}

class _ChatEntry {
  final AppUser user;
  final ChatRoom? room;
  const _ChatEntry({required this.user, this.room});
}

class _ChatTile extends StatelessWidget {
  final AppUser me;
  final ChatRoom? room;
  final String title;
  final String subtitleFallback;
  final Widget leading;
  final String? badge;
  final VoidCallback onTap;

  const _ChatTile({
    required this.me,
    required this.room,
    required this.title,
    required this.subtitleFallback,
    required this.leading,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final unread = room?.unreadFor(me.uid) ?? 0;
    final hasMessage = room != null && room!.lastMessage.isNotEmpty;
    final prefix = hasMessage && room!.lastSenderId == me.uid
        ? context.l10n.youPrefix
        : hasMessage && room!.isGroup
            ? '${room!.memberNames[room!.lastSenderId] ?? ''}: '
            : '';

    return ListTile(
      leading: leading,
      onTap: onTap,
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Text(context.l10n.role(badge!), style: TextStyle(fontSize: 12, color: roleColor(badge!))),
          ],
        ],
      ),
      subtitle: Text(
        hasMessage ? '$prefix${room!.lastMessage}' : subtitleFallback,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasMessage)
            Text(formatChatTime(context, room!.lastMessageAt), style: const TextStyle(fontSize: 11)),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Badge(label: Text('$unread'), backgroundColor: Colors.redAccent),
          ],
        ],
      ),
    );
  }
}
