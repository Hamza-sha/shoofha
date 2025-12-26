import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/auth/guest_guard.dart';
import 'package:shoofha/core/theme/app_colors.dart';
import 'package:shoofha/features/main_shell/presentation/main_shell.dart';

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen> {
  String _query = '';

  void _safeBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    // ✅ fallback آمن
    MainShellTabs.goHome();
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final conversations = _dummyConversations;

    final filtered = _query.trim().isEmpty
        ? conversations
        : conversations.where((c) {
            final q = _query.trim().toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.lastMessage.toLowerCase().contains(q);
          }).toList();

    final isEmpty = filtered.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _InboxHeader(
                title: 'الرسائل',
                subtitle: 'تابع محادثاتك مع المتاجر وخدمة العملاء.',
                onBack: () => _safeBack(context),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.06,
                  vertical: h * 0.014,
                ),
                child: _SearchBar(
                  hintText: 'ابحث عن متجر أو رسالة...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.06,
                    vertical: h * 0.008,
                  ),
                  child: isEmpty
                      ? _EmptyInbox(
                          query: _query,
                          onCta: () {
                            MainShellTabs.goExplore();
                            context.go('/app');
                          },
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: h * 0.014),
                          itemBuilder: (context, index) {
                            final conv = filtered[index];
                            return _ConversationTile(conversation: conv);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final allowed = await requireLogin(context);
            if (!allowed) return;
            if (!context.mounted) return;

            // ✅ placeholder عالمي (لاحقاً: New Chat / Support)
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('قريباً: بدء محادثة جديدة ✨'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('محادثة جديدة'),
        ),
      ),
    );
  }
}

class _InboxHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _InboxHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final headerHeight = h * 0.18;

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.purple],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BackButton(onPressed: onBack),
                Icon(
                  Icons.forum_outlined,
                  color: Colors.white.withOpacity(0.92),
                  size: h * 0.032,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: h * 0.030,
              ),
            ),
            SizedBox(height: h * 0.006),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.86),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(h * 0.014),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.006),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(h * 0.02),
        border: Border.all(color: cs.outline.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.light ? 0.03 : 0.18,
            ),
            blurRadius: h * 0.014,
            offset: Offset(0, h * 0.006),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.hintColor),
          SizedBox(width: w * 0.02),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          SizedBox(width: w * 0.01),
          Icon(Icons.tune_rounded, color: theme.hintColor),
        ],
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  final String query;
  final VoidCallback onCta;

  const _EmptyInbox({required this.query, required this.onCta});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    final isSearching = query.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.10),
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
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: h * 0.08,
              ),
            ),
            SizedBox(height: h * 0.02),
            Text(
              isSearching ? 'ما لقينا نتائج' : 'ما عندك رسائل حالياً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.008),
            Text(
              isSearching
                  ? 'جرّب كلمات ثانية أو امسح البحث.'
                  : 'تابع المتاجر وتفاعل مع العروض عشان تبلّش المحادثات بينك وبينهم.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: h * 0.022),
            SizedBox(
              width: w * 0.62,
              height: h * 0.055,
              child: FilledButton(
                onPressed: onCta,
                child: Text(isSearching ? 'استكشف المتاجر' : 'استكشف الآن'),
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
            _AvatarBubble(conversation: conversation),
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
                            fontWeight: FontWeight.w700,
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
                        0.82,
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
                  horizontal: w * 0.022,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final _Conversation conversation;

  const _AvatarBubble({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
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
        if (conversation.isOnline)
          Positioned(
            bottom: -h * 0.002,
            left: -h * 0.002,
            child: Container(
              width: h * 0.018,
              height: h * 0.018,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.95),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
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
  final bool isOnline;

  _Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.color,
    this.isOnline = false,
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
    isOnline: true,
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
