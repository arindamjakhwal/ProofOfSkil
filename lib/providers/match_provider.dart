import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';

class MatchProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();

  List<UserModel> _candidates = [];
  bool _isLoading = false;
  int _currentIndex = 0;
  UserModel? _currentUser;

  List<UserModel> get candidates => _candidates;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  bool get hasMore => _currentIndex < _candidates.length;

  Future<void> loadCandidates(UserModel currentUser) async {
    _currentUser = currentUser;
    _isLoading = true;
    notifyListeners();

    _candidates = await _userService.getMatchCandidates(currentUser);
    _currentIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  void swipeRight(UserModel candidate) async {
    final user = _currentUser;
    if (user != null && candidate.id != user.id) {
      final sessionId = 'conv_${user.id}_${candidate.id}';
      try {
        await _chatService.sendMessage(
          MessageModel(
            id: '',
            senderId: user.id,
            senderName: user.name,
            receiverId: candidate.id,
            content: '👋 Hi ${candidate.name}, I liked your profile. Let’s connect!',
            timestamp: DateTime.now(),
            sessionId: sessionId,
          ),
        );
      } catch (_) {
        // Ignore DM creation failures for swipe flow; user can still continue swiping.
      }
    }
    _currentIndex++;
    notifyListeners();
  }

  void swipeLeft() {
    // Skip
    _currentIndex++;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }
}
