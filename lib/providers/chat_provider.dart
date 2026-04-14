import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  List<ChatPreview> _previews = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  List<ChatPreview> get previews => _previews;
  bool get isLoading => _isLoading;

  /// Load chat previews for inbox.
  Future<void> loadPreviews(String userId) async {
    _isLoading = true;
    notifyListeners();

    _previews = await _chatService.getChatPreviews(userId);
    _isLoading = false;
    notifyListeners();
  }

  /// Load messages for a specific session/chat.
  Future<void> loadMessages(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    _messages = await _chatService.getMessages(sessionId);
    _isLoading = false;
    notifyListeners();
  }

  /// Send a text message.
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  }) async {
    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    // Optimistic add
    _messages.add(message);
    notifyListeners();

    // Persist (Firebase in production)
    await _chatService.sendMessage(message);
  }

  /// Send an attachment message.
  Future<void> sendAttachment({
    required String senderId,
    required String senderName,
    required String receiverId,
    required MessageType type,
    required String attachmentUrl,
    String content = '',
  }) async {
    final message = await _chatService.sendAttachment(
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      type: type,
      attachmentUrl: attachmentUrl,
      content: content,
    );

    _messages.add(message);
    notifyListeners();
  }

  /// Clear current chat state.
  void clearChat() {
    _messages = [];
    notifyListeners();
  }
}
