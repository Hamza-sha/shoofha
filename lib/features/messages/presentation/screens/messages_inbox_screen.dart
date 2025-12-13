import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/auth/guest_guard.dart';
import 'package:shoofha/core/theme/app_colors.dart';

class MessagesInboxScreen extends StatelessWidget {
  const MessagesInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final _ = Theme.of(context);

    final conversations = _dummyConversations;
    final isEmpty = conversations.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الرسائل'), centerTitle: true),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.06,
            vertical: h * 0.015,
          ),
          child: isEmpty
              ? _EmptyInbox()
              : ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => SizedBox(height: h * 0.014),
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return _ConversationTile(conversation: conv);
                  },
                ),
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: h * 0.18,
              height: h * 0.18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.teal, AppColors.purple],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: h * 0.08,
              ),
            ),
            SizedBox(height: h * 0.02),
            Text(
              'ما عندك رسائل حالياً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.008),
            Text(
              'تابع المتاجر وتفاعل مع العروض عشان تبلّش المحادثات بينك وبينهم.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.025),
            SizedBox(
              width: w * 0.6,
              height: h * 0.055,
              child: FilledButton(
                onPressed: () {
                  context.go('/app');
                },
                child: const Text('استكشف العروض'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(h * 0.02),
      onTap: () async {
        final allowed = await requireLogin(context);
        if (!allowed) return;
        if (!context.mounted) return;

        context.pushNamed('chat', pathParameters: {'id': conversation.id});
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.03,
          vertical: h * 0.012,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(h * 0.02),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.04 : 0.16,
              ),
              blurRadius: h * 0.018,
              offset: Offset(0, h * 0.008),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: h * 0.06,
              height: h * 0.06,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: conversation.color.withOpacity(0.18),
              ),
              alignment: Alignment.center,
              child: Text(
                conversation.name.characters.first,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: conversation.color,
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: w * 0.02),
                      Text(
                        conversation.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    conversation.lastMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.8,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: w * 0.02),
            if (hasUnread)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.020,
                  vertical: h * 0.004,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(h * 0.016),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
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
    id: 'fit-zone',
    name: 'Fit Zone Gym',
    lastMessage: 'موعد حصتك اليوم الساعة 7 مساءً.',
    timeLabel: 'اليوم',
    unreadCount: 0,
    color: const Color(0xFF1B5E20),
  ),
  _Conversation(
    id: 'pizza-house',
    name: 'Pizza House',
    lastMessage: 'تم تأكيد طلبك ورح يوصل خلال 35 دقيقة.',
    timeLabel: 'أمس',
    unreadCount: 1,
    color: const Color(0xFFD32F2F),
  ),
  _Conversation(
    id: 'tech-corner',
    name: 'Tech Corner',
    lastMessage: 'الباور بانك عليه ضمان سنة كاملة.',
    timeLabel: 'منذ 3 أيام',
    unreadCount: 0,
    color: const Color(0xFF0D47A1),
  ),
];
