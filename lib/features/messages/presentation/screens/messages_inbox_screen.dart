import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/auth/guest_guard.dart';

class MessagesInboxScreen extends StatelessWidget {
  const MessagesInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    // محادثات تجريبية
    final conversations = _dummyConversations;

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: conversations.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: w * 0.20,
                      color: cs.onSurface.withOpacity(0.35),
                    ),
                    SizedBox(height: h * 0.015),
                    Text(
                      'ما في أي محادثات لسه 💬',
                      style: TextStyle(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: h * 0.008),
                    Text(
                      'تقدر تبدأ محادثة من صفحة المتجر أو من تفاصيل العرض.',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.012,
              ),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => SizedBox(height: h * 0.010),
              itemBuilder: (context, index) {
                final c = conversations[index];
                return _ConversationTile(conversation: c);
              },
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: cs.surface,
      leading: CircleAvatar(
        radius: w * 0.06,
        backgroundColor: conversation.color.withOpacity(0.12),
        child: Text(
          conversation.name.characters.first,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: w * 0.055,
            color: conversation.color,
          ),
        ),
      ),
      title: Text(
        conversation.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: w * 0.040, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: w * 0.033,
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            conversation.timeLabel,
            style: TextStyle(
              fontSize: w * 0.030,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
          if (conversation.unreadCount > 0) ...[
            SizedBox(height: h * 0.004),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.018,
                vertical: h * 0.002,
              ),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: TextStyle(fontSize: w * 0.030, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      onTap: () async {
        final ok = await requireLogin(context);
        if (!ok) return;
        context.pushNamed('chat', pathParameters: {'id': conversation.id});
      },
    );
  }
}

class _Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final Color color;

  _Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.color,
  });
}

final List<_Conversation> _dummyConversations = [
  _Conversation(
    id: 'coffee-mood',
    name: 'Coffee Mood',
    lastMessage: 'أكيد، العرض شغال لليوم 👌',
    timeLabel: 'قبل 10 د',
    unreadCount: 2,
    color: const Color(0xFF6A1B9A),
  ),
  _Conversation(
    id: 'tech-corner',
    name: 'Tech Corner',
    lastMessage: 'الباور بانك عليه ضمان سنة كاملة.',
    timeLabel: 'أمس',
    unreadCount: 0,
    color: const Color(0xFF0D47A1),
  ),
];
