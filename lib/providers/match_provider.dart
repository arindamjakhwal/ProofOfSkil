import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class MatchProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _candidates = [];
  bool _isLoading = false;
  int _currentIndex = 0;

  List<UserModel> get candidates => _candidates;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  bool get hasMore => _currentIndex < _candidates.length;

  Future<void> loadCandidates(UserModel currentUser) async {
    _isLoading = true;
    notifyListeners();

    _candidates = await _userService.getMatchCandidates(currentUser);
    _currentIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  void swipeRight(UserModel candidate) {
    // Like — in production, create a match in Firestore
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
