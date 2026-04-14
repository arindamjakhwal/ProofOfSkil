import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _sessionService = SessionService();

  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  List<int> _weeklyData = [];
  List<int> _monthlyData = [];

  // Deep Focus Session state
  bool _isUser1Ready = false;
  bool _isUser2Ready = false;
  bool _isSessionActive = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  SessionModel? _activeSession;
  double _totalHoursSpent = 0.0;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  List<int> get weeklyData => _weeklyData;
  List<int> get monthlyData => _monthlyData;

  // Deep Focus getters
  bool get isUser1Ready => _isUser1Ready;
  bool get isUser2Ready => _isUser2Ready;
  bool get isSessionActive => _isSessionActive;
  int get elapsedSeconds => _elapsedSeconds;
  int get elapsedMinutes => _elapsedSeconds ~/ 60;
  SessionModel? get activeSession => _activeSession;
  double get totalHoursSpent => _totalHoursSpent;

  int get completedCount =>
      _sessions.where((s) => s.status == SessionStatus.completed).length;

  int get activeCount =>
      _sessions.where((s) => s.status == SessionStatus.active).length;

  Future<void> loadSessions(String userId) async {
    _isLoading = true;
    notifyListeners();

    _sessions = await _sessionService.getUserSessions(userId);
    _weeklyData = await _sessionService.getWeeklyData(userId);
    _monthlyData = await _sessionService.getMonthlyData(userId);
    _totalHoursSpent = await _sessionService.getTotalHours(userId);

    // Check for active session
    final activeSessions = _sessions.where(
      (s) => s.status == SessionStatus.active,
    );
    if (activeSessions.isNotEmpty) {
      _activeSession = activeSessions.first;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// User confirms readiness for deep focus session.
  /// In production: update Firestore, listen for partner's readiness.
  void confirmReady({required bool isUser1}) {
    if (isUser1) {
      _isUser1Ready = true;
    } else {
      _isUser2Ready = true;
    }
    notifyListeners();

    // If both ready, start the session
    if (_isUser1Ready && _isUser2Ready) {
      _startTimer();
    }
  }

  /// Simulate partner confirming (for demo purposes).
  void simulatePartnerReady() {
    Future.delayed(const Duration(seconds: 2), () {
      _isUser2Ready = true;
      notifyListeners();
      if (_isUser1Ready && _isUser2Ready) {
        _startTimer();
      }
    });
  }

  /// Start the session timer.
  void _startTimer() {
    _isSessionActive = true;
    _elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  /// End the deep focus session.
  Future<SessionModel?> endSession() async {
    _timer?.cancel();
    _timer = null;
    _isSessionActive = false;

    if (_activeSession != null) {
      final completed = await _sessionService.endDeepFocusSession(
        _activeSession!.id,
      );
      final index = _sessions.indexWhere((s) => s.id == completed.id);
      if (index >= 0) {
        _sessions[index] = completed;
      }
      _activeSession = completed;

      // Update total hours
      _totalHoursSpent += completed.duration / 60.0;

      // Reset readiness
      _isUser1Ready = false;
      _isUser2Ready = false;

      notifyListeners();
      return completed;
    }
    return null;
  }

  /// Reset session state.
  void resetSession() {
    _timer?.cancel();
    _timer = null;
    _isSessionActive = false;
    _isUser1Ready = false;
    _isUser2Ready = false;
    _elapsedSeconds = 0;
    _activeSession = null;
    notifyListeners();
  }

  Future<SessionModel> completeSession(String sessionId) async {
    final session = await _sessionService.completeSession(sessionId);
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      _sessions[index] = session;
    }
    notifyListeners();
    return session;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
