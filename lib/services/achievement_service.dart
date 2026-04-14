import '../models/achievement_model.dart';

/// Achievement service — replace with Firestore collection 'achievements'.
class AchievementService {
  /// Get all achievements for a user.
  Future<List<AchievementModel>> getAchievements(
      int sessionsCompleted) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AchievementModel(
        id: 'ach_001',
        type: AchievementType.firstSession,
        title: 'First Exchange',
        description: 'Complete your first skill exchange session',
        icon: 'handshake',
        isUnlocked: sessionsCompleted >= 1,
        unlockedAt: sessionsCompleted >= 1 ? DateTime(2026, 1, 20) : null,
        requiredCount: 1,
        currentCount: sessionsCompleted.clamp(0, 1),
      ),
      AchievementModel(
        id: 'ach_002',
        type: AchievementType.fiveSessions,
        title: 'Rising Star',
        description: 'Complete 5 skill exchange sessions',
        icon: 'star',
        isUnlocked: sessionsCompleted >= 5,
        unlockedAt: sessionsCompleted >= 5 ? DateTime(2026, 2, 10) : null,
        requiredCount: 5,
        currentCount: sessionsCompleted.clamp(0, 5),
      ),
      AchievementModel(
        id: 'ach_003',
        type: AchievementType.tenSessions,
        title: 'Skill Trader',
        description: 'Complete 10 skill exchange sessions',
        icon: 'swap_horiz',
        isUnlocked: sessionsCompleted >= 10,
        unlockedAt: sessionsCompleted >= 10 ? DateTime(2026, 3, 5) : null,
        requiredCount: 10,
        currentCount: sessionsCompleted.clamp(0, 10),
      ),
      AchievementModel(
        id: 'ach_004',
        type: AchievementType.twentyFiveSessions,
        title: 'Knowledge Architect',
        description: 'Complete 25 skill exchange sessions',
        icon: 'architecture',
        isUnlocked: sessionsCompleted >= 25,
        requiredCount: 25,
        currentCount: sessionsCompleted.clamp(0, 25),
      ),
      AchievementModel(
        id: 'ach_005',
        type: AchievementType.fiftySessions,
        title: 'Proof of Mastery',
        description: 'Complete 50 skill exchange sessions',
        icon: 'diamond',
        isUnlocked: sessionsCompleted >= 50,
        requiredCount: 50,
        currentCount: sessionsCompleted.clamp(0, 50),
      ),
      AchievementModel(
        id: 'ach_006',
        type: AchievementType.topRated,
        title: 'Top Rated',
        description: 'Maintain a 4.5+ rating with 10+ reviews',
        icon: 'verified',
        isUnlocked: sessionsCompleted >= 10,
        unlockedAt:
            sessionsCompleted >= 10 ? DateTime(2026, 3, 5) : null,
        requiredCount: 10,
        currentCount: sessionsCompleted.clamp(0, 10),
      ),
      AchievementModel(
        id: 'ach_007',
        type: AchievementType.skillCollector,
        title: 'Skill Collector',
        description: 'Learn 5 different skills from exchanges',
        icon: 'collections',
        isUnlocked: sessionsCompleted >= 8,
        unlockedAt:
            sessionsCompleted >= 8 ? DateTime(2026, 3, 15) : null,
        requiredCount: 5,
        currentCount: (sessionsCompleted * 0.4).clamp(0, 5).toInt(),
      ),
      AchievementModel(
        id: 'ach_008',
        type: AchievementType.streakWeek,
        title: 'Week Warrior',
        description: 'Maintain a 7-day activity streak',
        icon: 'local_fire_department',
        isUnlocked: sessionsCompleted >= 7,
        unlockedAt:
            sessionsCompleted >= 7 ? DateTime(2026, 2, 28) : null,
        requiredCount: 7,
        currentCount: sessionsCompleted.clamp(0, 7),
      ),
    ];
  }

  /// Check and unlock new achievements after session completion.
  Future<AchievementModel?> checkNewAchievement(
      int sessionsCompleted) async {
    final achievements = await getAchievements(sessionsCompleted);
    // Return the latest unlocked achievement
    final justUnlocked = achievements
        .where((a) => a.isUnlocked && a.currentCount == a.requiredCount)
        .toList();
    return justUnlocked.isNotEmpty ? justUnlocked.last : null;
  }
}
