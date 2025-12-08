class Conversation {
  final String id;
  final String storeId;
  final String storeName;
  final String lastMessage;
  final DateTime lastTimestamp;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCount,
  });
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isMe,
  });
}

/// بيانات تجريبية للمحادثات
final List<Conversation> kDummyConversations = [
  Conversation(
    id: 'conv-coffee-mood',
    storeId: 'coffee-mood',
    storeName: 'Coffee Mood',
    lastMessage: 'أهلاً! العرض لليوم كامل 🔥',
    lastTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
  ),
  Conversation(
    id: 'conv-fit-zone',
    storeId: 'fit-zone',
    storeName: 'FitZone Gym',
    lastMessage: 'أكيد، بنقدر نحجزلك من بكرا.',
    lastTimestamp: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 0,
  ),
  Conversation(
    id: 'conv-tech-corner',
    storeId: 'tech-corner',
    storeName: 'Tech Corner',
    lastMessage: 'الشحن بياخد من 2-3 أيام عمل.',
    lastTimestamp: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
  ),
];

/// بيانات تجريبية لرسائل كل محادثة
final Map<String, List<ChatMessage>> kDummyMessagesByConversation = {
  'conv-coffee-mood': [
    ChatMessage(
      id: 'm1',
      conversationId: 'conv-coffee-mood',
      senderId: 'me',
      senderName: 'أنت',
      text: 'مرحبا، العرض 30% على كل المشروبات؟',
      sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
      isMe: true,
    ),
    ChatMessage(
      id: 'm2',
      conversationId: 'conv-coffee-mood',
      senderId: 'store',
      senderName: 'Coffee Mood',
      text: 'أهلاً فيك! نعم العرض على كل المشروبات الباردة. 🧊',
      sentAt: DateTime.now().subtract(const Duration(minutes: 9)),
      isMe: false,
    ),
    ChatMessage(
      id: 'm3',
      conversationId: 'conv-coffee-mood',
      senderId: 'store',
      senderName: 'Coffee Mood',
      text: 'والعرض ساري لليوم كامل.',
      sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    ),
  ],
  'conv-fit-zone': [
    ChatMessage(
      id: 'm4',
      conversationId: 'conv-fit-zone',
      senderId: 'me',
      senderName: 'أنت',
      text: 'هل في عرض على الاشتراك 3 أشهر؟',
      sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      isMe: true,
    ),
    ChatMessage(
      id: 'm5',
      conversationId: 'conv-fit-zone',
      senderId: 'store',
      senderName: 'FitZone Gym',
      text: 'نعم في خصم 20%.',
      sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      isMe: false,
    ),
  ],
  'conv-tech-corner': [
    ChatMessage(
      id: 'm6',
      conversationId: 'conv-tech-corner',
      senderId: 'me',
      senderName: 'أنت',
      text: 'كم يوم الشحن لو طلبت السماعات؟',
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      isMe: true,
    ),
    ChatMessage(
      id: 'm7',
      conversationId: 'conv-tech-corner',
      senderId: 'store',
      senderName: 'Tech Corner',
      text: 'الشحن بياخد من 2-3 أيام عمل.',
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
      isMe: false,
    ),
  ],
};
