import '../models/session_model.dart';
import '../core/utils/helpers.dart';

/// Session service — replace with Firestore collection 'sessions'.
class SessionService {
  final List<SessionModel> _sessions = [
    SessionModel(
      id: 'sess_001',
      teacherId: 'user_001',
      teacherName: 'Tanay Prasad',
      learnerId: 'user_002',
      learnerName: 'Aarav Sharma',
      skill: 'Flutter',
      status: SessionStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      completedAt: DateTime.now().subtract(const Duration(days: 7)),
      startTime: DateTime.now().subtract(const Duration(days: 7, hours: 1)),
      endTime: DateTime.now().subtract(const Duration(days: 7)),
      duration: 45,
      deepFocusScore: 7.5,
    ),
    SessionModel(
      id: 'sess_002',
      teacherId: 'user_003',
      teacherName: 'Priya Patel',
      learnerId: 'user_001',
      learnerName: 'Tanay Prasad',
      skill: 'UI/UX Design',
      status: SessionStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 5)),
      startTime: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
      endTime: DateTime.now().subtract(const Duration(days: 5)),
      duration: 30,
      deepFocusScore: 5.0,
    ),
    SessionModel(
      id: 'sess_003',
      teacherId: 'user_001',
      teacherName: 'Tanay Prasad',
      learnerId: 'user_004',
      learnerName: 'Rohan Mehta',
      skill: 'Flutter',
      status: SessionStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Get all sessions for a user (as teacher or learner).
  Future<List<SessionModel>> getUserSessions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sessions
        .where((s) => s.teacherId == userId || s.learnerId == userId)
        .toList();
  }

  /// Create new session.
  Future<SessionModel> createSession(SessionModel session) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sessions.add(session);
    return session;
  }

  /// Complete a session.
  Future<SessionModel> completeSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      _sessions[index] = _sessions[index].copyWith(
        status: SessionStatus.completed,
        completedAt: DateTime.now(),
      );
      return _sessions[index];
    }
    throw Exception('Session not found');
  }

  /// Confirm user readiness for deep focus session.
  /// Replace with: Firestore update on session document
  Future<SessionModel> confirmReady({
    required String sessionId,
    required bool isUser1,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      _sessions[index] = _sessions[index].copyWith(
        user1Ready: isUser1 ? true : null,
        user2Ready: !isUser1 ? true : null,
      );
      return _sessions[index];
    }
    throw Exception('Session not found');
  }

  /// Start a deep focus session (called when both users are ready).
  /// Replace with: Firestore update + Cloud Function trigger
  Future<SessionModel> startDeepFocusSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      _sessions[index] = _sessions[index].copyWith(
        status: SessionStatus.active,
        startTime: DateTime.now(),
      );
      return _sessions[index];
    }
    throw Exception('Session not found');
  }

  /// End a deep focus session and calculate score.
  /// Replace with: Firestore update + calculate on Cloud Function
  Future<SessionModel> endDeepFocusSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      final session = _sessions[index];
      final now = DateTime.now();
      final duration = session.startTime != null
          ? now.difference(session.startTime!).inMinutes
          : 0;
      final score = Helpers.calculateDeepFocusScore(duration);

      _sessions[index] = session.copyWith(
        status: SessionStatus.completed,
        endTime: now,
        completedAt: now,
        duration: duration,
        deepFocusScore: score,
      );
      return _sessions[index];
    }
    throw Exception('Session not found');
  }

  /// Get count of completed sessions for progress tracking.
  Future<int> getCompletedCount(String userId) async {
    final sessions = await getUserSessions(userId);
    return sessions.where((s) => s.status == SessionStatus.completed).length;
  }

  /// Get total hours spent by user across completed sessions.
  Future<double> getTotalHours(String userId) async {
    final sessions = await getUserSessions(userId);
    final totalMinutes = sessions
        .where((s) => s.status == SessionStatus.completed)
        .fold<int>(0, (sum, s) => sum + s.duration);
    return totalMinutes / 60.0;
  }

  /// Get weekly session data for charts (hours per day).
  Future<List<int>> getWeeklyData(String userId) async {
    // Mock: hours per day of the week
    return [2, 3, 1, 4, 2, 5, 1];
  }

  /// Get monthly session data for charts.
  Future<List<int>> getMonthlyData(String userId) async {
    return [5, 8, 12, 7, 15, 10, 18, 14, 20, 16, 22, 12];
  }
}
