import 'package:flutter/material.dart';
import 'dart:async';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  List<MessageModel> _messages = [];
  List<ChatPreview> _previews = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  List<ChatPreview> get previews => _previews;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  /// Load chat previews for inbox.
  Future<void> loadPreviews(String userId) async {
    _isLoading = true;
    notifyListeners();

    _previews = await _chatService.getChatPreviews(userId);
    _isLoading = false;
    notifyListeners();
  }

  /// Listen to real-time messages between two users.
  void listenToConversation(String userId1, String userId2) {
    // Cancel previous subscription
    _messagesSubscription?.cancel();
    
    _isLoading = true;
    notifyListeners();

    _messagesSubscription = _chatService.getConversationStream(userId1, userId2).listen(
      (messages) {
        _messages = messages;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error, stackTrace) {
        _isLoading = false;
        notifyListeners();
      },
    );

    // Safety timeout - if no messages after 5 seconds, stop loading
    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Load messages between two users (one-time fetch).
  Future<void> loadConversation(String userId1, String userId2) async {
    _isLoading = true;
    notifyListeners();

    _messages = await _chatService.getConversation(userId1, userId2);
    _isLoading = false;
    notifyListeners();
  }



  /// Send a text message.
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
    required String sessionId,
  }) async {
    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );

    // Optimistic add
    _messages.add(message);
    notifyListeners();

    try {
      // Persist to Firebase
      await _chatService.sendMessage(message);
    } catch (e) {
      // Remove the message if it failed to send
      _messages.remove(message);
      notifyListeners();
    }
  }

  /// Send an attachment message.
  Future<void> sendAttachment({
    required String senderId,
    required String senderName,
    required String receiverId,
    required MessageType type,
    required String attachmentUrl,
    required String sessionId,
    String content = '',
  }) async {
    final message = await _chatService.sendAttachment(
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      type: type,
      attachmentUrl: attachmentUrl,
      sessionId: sessionId,
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
