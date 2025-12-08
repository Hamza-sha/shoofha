import 'package:flutter/material.dart';

import 'package:shoofha/core/responsive/responsive.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = List.of(_dummyMessages);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.insert(0, _Message(text: text, isMe: true, timeLabel: 'الآن'));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);

    // مؤقتاً بس اسم افتراضي من الـ id
    final title = widget.conversationId;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              reverse: true,
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.012,
              ),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => SizedBox(height: h * 0.006),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                w * 0.03,
                h * 0.006,
                w * 0.03,
                h * 0.010,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: h * 0.012,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  SizedBox(
                    height: w * 0.12,
                    width: w * 0.12,
                    child: FilledButton(
                      onPressed: _send,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final w = Responsive.width(context);
    final h = Responsive.height(context);
    final cs = Theme.of(context).colorScheme;

    final isMe = message.isMe;
    final bg = isMe ? cs.primary : cs.surfaceContainerHighest.withOpacity(0.8);
    final fg = isMe ? Colors.white : cs.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: w * 0.75),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: h * 0.008,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomLeft: Radius.circular(isMe ? 4 : 18),
              bottomRight: Radius.circular(isMe ? 18 : 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: TextStyle(fontSize: w * 0.035, color: fg),
              ),
              SizedBox(height: h * 0.003),
              Text(
                message.timeLabel,
                style: TextStyle(
                  fontSize: w * 0.028,
                  color: fg.withOpacity(0.7),
                ),
              ),
            ],
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
