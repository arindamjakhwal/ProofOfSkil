import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/achievement_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/achievement_provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context
            .read<AchievementProvider>()
            .loadAchievements(user.sessionsCompleted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final achProv = context.watch<AchievementProvider>();

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Achievements',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Your milestones and badges',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              // Points overview
              _buildPointsOverview(user.points, achProv),
              const SizedBox(height: 20),
              // Stats
              Row(
                children: [
                  _miniStat('Unlocked', '${achProv.unlockedCount}',
                      Icons.verified_rounded),
                  const SizedBox(width: 10),
                  _miniStat(
                      'Total', '${achProv.totalCount}', Icons.grid_view_rounded),
                  const SizedBox(width: 10),
                  _miniStat('Streak', '7 🔥',
                      Icons.local_fire_department_rounded),
                ],
              ),
              const SizedBox(height: 28),
              // Achievement cards
              const Text('All Achievements',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ...achProv.achievements.map(
                  (a) => _AchievementCard(achievement: a)),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsOverview(int points, AchievementProvider achProv) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skill Points',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(Helpers.formatPoints(points),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ],
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.primary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Next milestone at 3,000 pts',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text('${((points / 3000) * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: (points / 3000).clamp(0.0, 1.0),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.border,
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const _AchievementCard({required this.achievement});

  IconData _getIcon() {
    switch (achievement.icon) {
      case 'handshake':
        return Icons.handshake_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'swap_horiz':
        return Icons.swap_horiz_rounded;
      case 'architecture':
        return Icons.architecture_rounded;
      case 'diamond':
        return Icons.diamond_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'collections':
        return Icons.collections_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.border,
        ),
        boxShadow: achievement.isUnlocked ? AppColors.cardShadow : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppColors.primaryLight
                  : AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIcon(),
              color: achievement.isUnlocked
                  ? AppColors.primary
                  : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: achievement.isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    if (achievement.isUnlocked)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 18)
                    else
                      const Icon(Icons.lock_rounded,
                          color: AppColors.textMuted, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement.isUnlocked
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 4,
                    percent: achievement.progress,
                    progressColor: AppColors.primary,
                    backgroundColor: AppColors.border,
                    barRadius: const Radius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.currentCount}/${achievement.requiredCount}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                ],
                if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Unlocked ${Helpers.formatDate(achievement.unlockedAt!)}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
