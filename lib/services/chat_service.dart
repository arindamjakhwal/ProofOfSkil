import '../models/message_model.dart';

/// Chat service — replace with Firestore collection 'messages'.
class ChatService {
  /// Get messages for a session/chat.
  Future<List<MessageModel>> getMessages(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMessages;
  }

  /// Send a message.
  /// Replace with: FirebaseFirestore.instance.collection('messages').add()
  Future<MessageModel> sendMessage(MessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return message;
  }

  /// Send an attachment message.
  /// Replace with: Firebase Storage upload + Firestore message document
  Future<MessageModel> sendAttachment({
    required String senderId,
    required String senderName,
    required String receiverId,
    required MessageType type,
    required String attachmentUrl,
    String content = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content.isEmpty ? type.name.toUpperCase() : content,
      type: type,
      attachmentUrl: attachmentUrl,
      timestamp: DateTime.now(),
    );
    return message;
  }

  /// Get chat previews (latest message per conversation).
  Future<List<ChatPreview>> getChatPreviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ChatPreview(
        sessionId: 'sess_003',
        partnerId: 'user_004',
        partnerName: 'Rohan Mehta',
        partnerInitial: 'R',
        lastMessage: 'Ready for the Flutter session!',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        skill: 'Flutter',
      ),
      ChatPreview(
        sessionId: 'sess_002',
        partnerId: 'user_003',
        partnerName: 'Priya Patel',
        partnerInitial: 'P',
        lastMessage: 'Thanks for the design tips! 🎨',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
        isOnline: true,
        skill: 'UI/UX Design',
      ),
      ChatPreview(
        sessionId: 'sess_001',
        partnerId: 'user_002',
        partnerName: 'Aarav Sharma',
        partnerInitial: 'A',
        lastMessage: 'Great session! Learned a lot about Flutter.',
        time: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
        skill: 'Flutter',
      ),
    ];
  }
}

class ChatPreview {
  final String sessionId;
  final String partnerId;
  final String partnerName;
  final String partnerInitial;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final bool isOnline;
  final String skill;

  const ChatPreview({
    required this.sessionId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerInitial,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.skill,
  });
}

final List<MessageModel> _mockMessages = [
  MessageModel(
    id: 'msg_1',
    senderId: 'user_004',
    senderName: 'Rohan',
    receiverId: 'user_001',
    content: 'Hey! Ready for the Flutter session today?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  MessageModel(
    id: 'msg_2',
    senderId: 'user_001',
    senderName: 'Tanay',
    receiverId: 'user_004',
    content: 'Yes! I\'ve prepared a demo on state management.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
  ),
  MessageModel(
    id: 'msg_3',
    senderId: 'user_004',
    senderName: 'Rohan',
    receiverId: 'user_001',
    content: 'That sounds perfect. Can we cover Provider too?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
  ),
  MessageModel(
    id: 'msg_4',
    senderId: 'user_001',
    senderName: 'Tanay',
    receiverId: 'user_004',
    content: 'Absolutely! Provider is actually what I\'ll focus on.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
  ),
  MessageModel(
    id: 'msg_5',
    senderId: 'user_004',
    senderName: 'Rohan',
    receiverId: 'user_001',
    content: 'Great. Let me set up my environment.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  MessageModel(
    id: 'msg_6',
    senderId: 'user_001',
    senderName: 'Tanay',
    receiverId: 'user_004',
    content: 'Take your time. I\'ll share my screen when you\'re ready.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  MessageModel(
    id: 'msg_7',
    senderId: 'user_004',
    senderName: 'Rohan',
    receiverId: 'user_001',
    content: 'Ready! Let\'s start 💪',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
];
