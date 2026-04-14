import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _achievementService = AchievementService();

  List<AchievementModel> _achievements = [];
  bool _isLoading = false;

  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;

  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;
  int get totalCount => _achievements.length;

  Future<void> loadAchievements(int sessionsCompleted) async {
    _isLoading = true;
    notifyListeners();

    _achievements =
        await _achievementService.getAchievements(sessionsCompleted);
    _isLoading = false;
    notifyListeners();
  }

  Future<AchievementModel?> checkNewAchievement(
      int sessionsCompleted) async {
    return _achievementService.checkNewAchievement(sessionsCompleted);
  }
}
