import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context
            .read<AchievementProvider>()
            .loadAchievements(user.sessionsCompleted);
        context.read<SessionProvider>().loadSessions(user.id);
      }
    });
  }

  void _showEditSkillsDialog(
      {required String title,
      required List<String> current,
      required bool isOffered}) {
    final selected = Set<String>.from(current);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap to select or deselect skills',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.allSkills
                      .map((s) => SkillChip(
                            label: s,
                            isSelected: selected.contains(s),
                            onTap: () {
                              setS(() {
                                if (selected.contains(s)) {
                                  selected.remove(s);
                                } else {
                                  selected.add(s);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Save',
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (auth.user != null) {
                      auth.updateUser(
                        isOffered
                            ? auth.user!.copyWith(
                                skillsOffered: selected.toList())
                            : auth.user!.copyWith(
                                skillsWanted: selected.toList()),
                      );
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final bioCtrl = TextEditingController(text: user.bio ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Name',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
              const SizedBox(height: 16),
              const Text('Bio',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: bioCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
                decoration:
                    const InputDecoration(hintText: 'Tell us about yourself'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Changes',
                onPressed: () {
                  auth.updateUser(
                    user.copyWith(
                      name: nameCtrl.text.trim(),
                      bio: bioCtrl.text.trim(),
                    ),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final achievements = context.watch<AchievementProvider>();
    final sessions = context.watch<SessionProvider>();

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              AvatarWidget(
                  name: user.name,
                  size: 80,
                  backgroundColor: AppColors.primary),
              const SizedBox(height: 14),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.bio ?? 'Skill Exchange Enthusiast',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              // Wallet badge
              if (user.walletAddress != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.truncateAddress(user.walletAddress!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < user.rating.floor()
                          ? Icons.star_rounded
                          : (i < user.rating
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded),
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${user.rating}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 15)),
                  Text(' (${user.totalRatings})',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 24),
              // Stats
              Row(
                children: [
                  _MiniStat(
                      value: Helpers.formatPoints(user.points),
                      label: 'Points',
                      icon: Icons.bolt_rounded),
                  const SizedBox(width: 10),
                  _MiniStat(
                      value: '${user.sessionsCompleted}',
                      label: 'Sessions',
                      icon: Icons.handshake_rounded),
                  const SizedBox(width: 10),
                  _MiniStat(
                      value: '${user.skillsLearned}',
                      label: 'Skills',
                      icon: Icons.auto_awesome_rounded),
                ],
              ),
              const SizedBox(height: 10),
              // Deep Focus + Hours row
              Row(
                children: [
                  _MiniStat(
                      value: user.deepFocusScore.toStringAsFixed(1),
                      label: 'Focus Score',
                      icon: Icons.psychology_rounded),
                  const SizedBox(width: 10),
                  _MiniStat(
                      value: Helpers.formatHours(
                          sessions.totalHoursSpent > 0
                              ? sessions.totalHoursSpent
                              : user.totalHoursSpent),
                      label: 'Hours',
                      icon: Icons.timer_rounded),
                  const SizedBox(width: 10),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 24),
              // Skills - Editable
              _buildEditableSection(
                'Skills I Teach',
                user.skillsOffered,
                true,
                () => _showEditSkillsDialog(
                  title: 'Edit Teaching Skills',
                  current: user.skillsOffered,
                  isOffered: true,
                ),
              ),
              const SizedBox(height: 16),
              _buildEditableSection(
                'Skills I Want',
                user.skillsWanted,
                false,
                () => _showEditSkillsDialog(
                  title: 'Edit Wanted Skills',
                  current: user.skillsWanted,
                  isOffered: false,
                ),
              ),
              const SizedBox(height: 24),
              // Progress
              _buildProgressCard(user, sessions),
              const SizedBox(height: 24),
              // Achievement timeline
              _buildAchievementTimeline(achievements),
              const SizedBox(height: 24),
              // Edit profile button
              PrimaryButton(
                text: 'Edit Profile',
                icon: Icons.edit_rounded,
                isOutlined: true,
                onPressed: _showEditProfileDialog,
              ),
              const SizedBox(height: 16),
              // Logout button
              PrimaryButton(
                text: 'Logout',
                icon: Icons.logout_rounded,
                isOutlined: true,
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableSection(
      String title, List<String> skills, bool selected, VoidCallback onEdit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded,
                          size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          skills.isEmpty
              ? const Text(
                  'No skills added yet. Tap Edit to add.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) =>
                          SkillChip(label: s, isSelected: selected))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(dynamic user, SessionProvider sessions) {
    final totalSessions = user.sessionsCompleted as int;
    final progressPercent =
        totalSessions > 0 ? (totalSessions / 15).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 48,
            lineWidth: 7,
            percent: progressPercent,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(progressPercent * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const Text('Done',
                    style:
                        TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.border,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _progressRow('Sessions', '$totalSessions/15'),
                const SizedBox(height: 10),
                _progressRow('Skills', '${user.skillsLearned}/8'),
                const SizedBox(height: 10),
                _progressRow(
                    'Hours',
                    Helpers.formatHours(sessions.totalHoursSpent > 0
                        ? sessions.totalHoursSpent
                        : user.totalHoursSpent)),
                const SizedBox(height: 10),
                _progressRow('Focus',
                    '${user.deepFocusScore.toStringAsFixed(1)}/10'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildAchievementTimeline(AchievementProvider achievements) {
    if (achievements.achievements.isEmpty) return const SizedBox.shrink();

    final unlocked =
        achievements.achievements.where((a) => a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Achievements',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text('${achievements.unlockedCount}/${achievements.totalCount}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 16),
        ...unlocked.take(4).map((a) => _TimelineItem(
              title: a.title,
              description: a.description,
              date: a.unlockedAt != null
                  ? Helpers.formatDate(a.unlockedAt!)
                  : '',
              isLast: a == unlocked.take(4).last,
            )),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MiniStat(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
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

class _TimelineItem extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.description,
    required this.date,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
