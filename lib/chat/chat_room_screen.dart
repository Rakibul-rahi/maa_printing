import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_models.dart';
import 'chat_providers.dart';
import '../l10n/l10n.dart';

Color roleColor(String role) {
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

String formatChatTime(BuildContext context, DateTime? t) {
  if (t == null) return '';
  final now = DateTime.now();
  final sameDay = t.year == now.year && t.month == now.month && t.day == now.day;
  return sameDay ? context.time(t) : context.dateTime(t);
}

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title;
  const ChatRoomScreen({super.key, required this.chatId, required this.title});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markRead() {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) ref.read(chatRepositoryProvider).markRead(widget.chatId, uid);
  }

  Future<void> _send() async {
    final me = ref.read(currentAppUserProvider).valueOrNull;
    final room = ref.read(chatRoomProvider(widget.chatId)).valueOrNull;
    final text = _controller.text;
    if (me == null || room == null || text.trim().isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            chatId: widget.chatId,
            sender: me,
            members: room.members,
            text: text,
          );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.messageNotSent(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(authStateProvider).valueOrNull?.uid;
    final room = ref.watch(chatRoomProvider(widget.chatId)).valueOrNull;
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));

    // Keep the chat marked as read while it is open.
    ref.listen(messagesProvider(widget.chatId), (prev, next) {
      if (next.hasValue) _markRead();
    });

    final otherRole = room?.memberRoles[room.otherMemberId(myUid ?? '')];
    final subtitle = room == null
        ? null
        : room.isGroup
            ? context.l10n.membersCount(room.members.length)
            : (otherRole == null ? null : context.l10n.role(otherRole));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(context.l10n.errorLoadingMessages(e), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(child: Text(context.l10n.noMessagesYet));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final older = i + 1 < messages.length ? messages[i + 1] : null;
                    return _MessageBubble(
                      message: msg,
                      isMine: msg.senderId == myUid,
                      showSender: (room?.isGroup ?? false) && older?.senderId != msg.senderId,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: context.l10n.typeMessage,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _sending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showSender;

  const _MessageBubble({required this.message, required this.isMine, required this.showSender});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = isMine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMine ? scheme.primary : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSender && !isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${message.senderName} · ${context.l10n.role(message.senderRole)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: roleColor(message.senderRole),
                    ),
                  ),
                ),
              Text(
                message.text,
                style: TextStyle(fontSize: 15, color: textColor),
              ),
              const SizedBox(height: 2),
              Text(
                formatChatTime(context, message.createdAt),
                style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
