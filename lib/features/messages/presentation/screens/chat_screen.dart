import 'package:flutter/material.dart';

import 'package:shoofha/core/responsive/responsive.dart';
import 'package:shoofha/core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // نستخدم لستة رسائل محلية (تجريبية)
  final List<_Message> _messages = List.of(_dummyMessages);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _conversationTitle {
    final conv = _dummyConversations
        .where((c) => c.id == widget.conversationId)
        .toList();
    if (conv.isNotEmpty) return conv.first.name;
    return 'المحادثة';
  }

  Color get _conversationColor {
    final conv = _dummyConversations
        .where((c) => c.id == widget.conversationId)
        .toList();
    if (conv.isNotEmpty) return conv.first.color;
    return AppColors.teal;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, _Message(text: text, isMe: true, timeLabel: 'الآن'));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                width: h * 0.042,
                height: h * 0.042,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _conversationColor.withOpacity(0.18),
                ),
                alignment: Alignment.center,
                child: Text(
                  _conversationTitle.characters.first,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _conversationColor,
                  ),
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: Text(
                  _conversationTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.012,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            _ChatInputBar(controller: _controller, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.008, w * 0.04, h * 0.012),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.light ? 0.06 : 0.35,
              ),
              blurRadius: h * 0.016,
              offset: Offset(0, -h * 0.004),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.035,
                  vertical: h * 0.004,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(h * 0.022),
                  border: Border.all(color: cs.outline.withOpacity(0.25)),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'اكتب رسالتك هنا...',
                  ),
                ),
              ),
            ),
            SizedBox(width: w * 0.02),
            InkWell(
              borderRadius: BorderRadius.circular(h * 0.022),
              onTap: onSend,
              child: Container(
                padding: EdgeInsets.all(h * 0.010),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, AppColors.purple],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: h * 0.022,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final h = Responsive.height(context);
    final w = Responsive.width(context);
    final theme = Theme.of(context);

    final isMe = message.isMe;

    final bgColor = isMe ? AppColors.teal : theme.colorScheme.surface;
    final textColor = isMe ? Colors.white : theme.textTheme.bodyMedium?.color;

    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.004),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w * 0.76),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.010,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(h * 0.018),
                topRight: Radius.circular(h * 0.018),
                bottomLeft: isMe
                    ? Radius.circular(h * 0.018)
                    : Radius.circular(4),
                bottomRight: isMe
                    ? Radius.circular(4)
                    : Radius.circular(h * 0.018),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.light ? 0.03 : 0.20,
                  ),
                  blurRadius: h * 0.012,
                  offset: Offset(0, h * 0.004),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: h * 0.004),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    message.timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isMe ? Colors.white : textColor)?.withOpacity(
                        0.75,
                      ),
                      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) - 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String timeLabel;

  _Message({required this.text, required this.isMe, required this.timeLabel});
}

/// رسائل تجريبية
final List<_Message> _dummyMessages = [
  _Message(
    text: 'أكيد، العرض شغال لليوم 👌',
    isMe: false,
    timeLabel: 'قبل 5 د',
  ),
  _Message(text: 'وفي توصيل لمرج الحمام؟', isMe: true, timeLabel: 'قبل 6 د'),
  _Message(
    text: 'أهلاً فيك، كيف فيني أساعدك؟',
    isMe: false,
    timeLabel: 'قبل 8 د',
  ),
];

/// نفس نموذج المحادثات اللي بالإنبوكس (بس لو احتجنا الاسم في الهيدر)
class _Conversation {
  final String id;
  final String name;
  final Color color;

  _Conversation({required this.id, required this.name, required this.color});
}

final List<_Conversation> _dummyConversations = [
  _Conversation(
    id: 'coffee-mood',
    name: 'Coffee Mood',
    color: const Color(0xFF6A1B9A),
  ),
  _Conversation(
    id: 'fit-zone',
    name: 'Fit Zone Gym',
    color: const Color(0xFF1B5E20),
  ),
  _Conversation(
    id: 'pizza-house',
    name: 'Pizza House',
    color: const Color(0xFFD32F2F),
  ),
  _Conversation(
    id: 'tech-corner',
    name: 'Tech Corner',
    color: const Color(0xFF0D47A1),
  ),
];
