import 'package:flutter_riverpod/legacy.dart';

import 'package:shoofha/features/messages/domain/message_models.dart';

class MessagesState {
  final List<Conversation> conversations;
  final Map<String, List<ChatMessage>> messagesByConversation;

  const MessagesState({
    required this.conversations,
    required this.messagesByConversation,
  });

  MessagesState copyWith({
    List<Conversation>? conversations,
    Map<String, List<ChatMessage>>? messagesByConversation,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
    );
  }
}

class MessagesController extends StateNotifier<MessagesState> {
  MessagesController()
    : super(const MessagesState(conversations: [], messagesByConversation: {}));

  /// إرسال رسالة جديدة ضمن محادثة
  void sendMessage({
    required String conversationId,
    required String content,
    required bool fromUser,
  }) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: fromUser ? 'user' : 'store',
      senderName: fromUser ? 'أنت' : 'المتجر',
      text: content,
      sentAt: DateTime.now(),
      isMe: fromUser,
    );

    final existingMessages =
        state.messagesByConversation[conversationId] ?? const <ChatMessage>[];

    final updatedMessages = [...existingMessages, newMessage];

    state = state.copyWith(
      messagesByConversation: {
        ...state.messagesByConversation,
        conversationId: updatedMessages,
      },
    );

    // تحديث آخر رسالة في المحادثة (إن وجدت)
    final updatedConversations = state.conversations.map((c) {
      if (c.id == conversationId) {
        return Conversation(
          id: c.id,
          storeId: c.storeId,
          storeName: c.storeName,
          lastMessage: content,
          lastTimestamp: DateTime.now(),
          unreadCount: c.unreadCount,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  /// تعيين المحادثة كمقروءة (جعل عدد الرسائل غير المقروءة = 0)
  void markConversationAsRead(String conversationId) {
    final updated = state.conversations.map((c) {
      if (c.id == conversationId) {
        return Conversation(
          id: c.id,
          storeId: c.storeId,
          storeName: c.storeName,
          lastMessage: c.lastMessage,
          lastTimestamp: c.lastTimestamp,
          unreadCount: 0,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(conversations: updated);
  }
}

final messagesControllerProvider =
    StateNotifierProvider<MessagesController, MessagesState>(
      (ref) => MessagesController(),
    );
