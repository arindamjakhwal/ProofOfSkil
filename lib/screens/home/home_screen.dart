import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/nft_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/avatar_widget.dart';
import '../../services/location_service.dart';
import '../../models/learning_space_model.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SessionProvider>().loadSessions(user.id);
      }
    });
  }

  void _showWalletDialog() {
    final nft = context.read<NFTProvider>();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Connect Wallet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Connect your MetaMask wallet to access NFTs and blockchain features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Ethereum Sepolia Testnet',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              StatefulBuilder(
                builder: (ctx2, setS) {
                  return GestureDetector(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await nft.connectWallet();
                      if (ok && ctx.mounted) {
                        final auth = ctx.read<AuthProvider>();
                        if (auth.user != null && nft.walletAddress != null) {
                          auth.updateUser(
                            auth.user!.copyWith(
                                walletAddress: nft.walletAddress),
                          );
                        }
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Wallet connected: ${Helpers.truncateAddress(nft.walletAddress!)}'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.buttonShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            nft.isLoading
                                ? Icons.hourglass_top_rounded
                                : Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            nft.isLoading ? 'Connecting...' : 'Connect MetaMask',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
    final sessions = context.watch<SessionProvider>();

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
              _buildHeader(user.name, user.walletAddress),
              const SizedBox(height: 24),
              _buildPointsCard(user.points, user.sessionsCompleted, user.rating),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildStatsRow(user),
              const SizedBox(height: 24),
              _buildInsightCard(),
              const SizedBox(height: 24),
              _buildWeeklyChart(sessions.weeklyData),
              const SizedBox(height: 24),
              const _MapPreviewSection(),
              const SizedBox(height: 24),
              _buildSkillsSection(user.skillsOffered),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String? walletAddress) {
    final firstName = name.split(' ').first;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready to learn something new?',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Wallet button
        GestureDetector(
          onTap: walletAddress != null ? null : _showWalletDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: walletAddress != null
                  ? AppColors.successLight
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: walletAddress != null
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 14,
                  color: walletAddress != null
                      ? AppColors.success
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  walletAddress != null
                      ? Helpers.truncateAddress(walletAddress)
                      : 'Connect',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: walletAddress != null
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(int points, int sessionsCompleted, double rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.buttonShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skill Points',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('+12%',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Helpers.formatPoints(points),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pointsPill(Icons.school_rounded, '$sessionsCompleted Sessions'),
              const SizedBox(width: 12),
              _pointsPill(Icons.star_rounded, '$rating Rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pointsPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
            child: _ActionCard(
                icon: Icons.school_rounded,
                label: 'Teach',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/teach'))),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionCard(
                icon: Icons.menu_book_rounded,
                label: 'Learn',
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, '/learn'))),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionCard(
                icon: Icons.swap_horiz_rounded,
                label: 'Match',
                color: AppColors.success,
                onTap: () {
                  // Switch to Match tab (index 1)
                  final shell = context.findAncestorStateOfType<State>();
                  if (shell != null && shell.mounted) {
                    // Navigate via bottom nav - handled by MainShell
                  }
                })),
      ],
    );
  }

  Widget _buildStatsRow(dynamic user) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Sessions',
            value: '${user.sessionsCompleted}',
            icon: Icons.handshake_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Skills',
            value: '${user.skillsLearned}',
            icon: Icons.auto_awesome_rounded,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    final insight = Helpers.getDailyInsight();
    final parsed = Helpers.parseInsight(insight);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Daily Insight',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${parsed.quote}"',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— ${parsed.author}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<int> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Activity',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Hours spent learning this week',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  data.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].toDouble(),
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Skills',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Edit in Profile →',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map((s) => SkillChip(label: s, isSelected: true))
              .toList(),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Map Preview Section ────────────────────────────────────
class _MapPreviewSection extends StatefulWidget {
  const _MapPreviewSection();

  @override
  State<_MapPreviewSection> createState() => _MapPreviewSectionState();
}

class _MapPreviewSectionState extends State<_MapPreviewSection>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  List<NearbyUser> _nearbyUsers = [];
  List<LearningSpaceModel> _spaces = [];
  bool _isLoading = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final users = await _locationService.getNearbyUsers(
      currentUserId: 'user_001',
      radiusKm: 10,
    );
    final spaces = await _locationService.getNearbySpaces();
    if (mounted) {
      setState(() {
        _nearbyUsers = users;
        _spaces = spaces;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Learners & Spaces',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/map'),
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
                    Icon(Icons.map_rounded,
                        size: 13, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Full Map',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_nearbyUsers.length} users & ${_spaces.length} spaces within 10 km',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        // Map preview card
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/map'),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child2) {
                      return CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: _MiniMapPainter(
                          users: _nearbyUsers,
                          spaces: _spaces,
                          pulseValue: _pulseAnim.value,
                        ),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 14),
        // Nearby users horizontal list
        SizedBox(
          height: 84,
          child: _isLoading
              ? const SizedBox.shrink()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _nearbyUsers.length,
                  separatorBuilder: (_, idx) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final u = _nearbyUsers[i];
                    return _NearbyUserChip(
                      name: u.user.name,
                      distance: u.distanceKm,
                      isOnline: u.user.isOnline,
                      onTap: () => Navigator.pushNamed(context, '/map'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Mini Map Painter ───────────────────────────────────────
class _MiniMapPainter extends CustomPainter {
  final List<NearbyUser> users;
  final List<LearningSpaceModel> spaces;
  final double pulseValue;

  _MiniMapPainter({
    required this.users,
    required this.spaces,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF0F4FF), Color(0xFFEBEFF7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grid
    final gridPaint = Paint()
      ..color = const Color(0xFFDDE3ED)
      ..strokeWidth = 0.3;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Radius ring
    final ringFill = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.04);
    canvas.drawCircle(Offset(cx, cy), 75, ringFill);

    final ringStroke = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(cx, cy), 50, ringStroke);
    canvas.drawCircle(Offset(cx, cy), 75, ringStroke);

    // Current user pulse
    final pulsePaint = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.12 * pulseValue);
    canvas.drawCircle(Offset(cx, cy), 16 * pulseValue, pulsePaint);

    // Current user dot
    final dotOuter = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(cx, cy), 9, dotOuter);
    final dotInner = Paint()..color = const Color(0xFF4F46E5);
    canvas.drawCircle(Offset(cx, cy), 6, dotInner);
    final dotCenter = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 2.5, dotCenter);

    // Learning spaces
    for (int i = 0; i < spaces.length; i++) {
      final angle = (i * 2 * pi / spaces.length) + pi / spaces.length;
      final dist = 55.0 + i * 12;
      final x = cx + cos(angle) * dist;
      final y = cy + sin(angle) * dist;

      final bg = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(x, y), 10, bg);

      final border = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(x, y), 10, border);

      final icon = Paint()..color = const Color(0xFF06B6D4);
      canvas.drawCircle(Offset(x, y), 3.5, icon);
    }

    // Nearby users
    for (int i = 0; i < users.length; i++) {
      final u = users[i];
      final angle = (i * 2 * pi / users.length) - pi / 2;
      final dist = 30.0 + u.distanceKm * 20;
      final x = cx + cos(angle) * dist;
      final y = cy + sin(angle) * dist;

      // Avatar circle
      final avatarBg = Paint()..color = const Color(0xFF4F46E5);
      canvas.drawCircle(Offset(x, y), 12, avatarBg);
      final innerBg = Paint()..color = const Color(0xFFEEF2FF);
      canvas.drawCircle(Offset(x, y), 10, innerBg);

      // Initials
      final parts = u.user.name.split(' ');
      final initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'
          : parts[0].substring(0, min(2, parts[0].length));
      final tp = TextPainter(
        text: TextSpan(
          text: initials,
          style: const TextStyle(
            color: Color(0xFF4F46E5),
            fontSize: 7,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));

      // Online dot
      if (u.user.isOnline) {
        final onlineBg = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(x + 8, y - 8), 3.5, onlineBg);
        final onlineDot = Paint()..color = const Color(0xFF10B981);
        canvas.drawCircle(Offset(x + 8, y - 8), 2.5, onlineDot);
      }
    }

    // "Tap to explore" label
    final labelTP = TextPainter(
      text: const TextSpan(
        text: 'Tap to explore nearby',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTP.paint(canvas,
        Offset(cx - labelTP.width / 2, size.height - 20));
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter old) =>
      pulseValue != old.pulseValue ||
      users.length != old.users.length;
}

// ─── Nearby User Chip ───────────────────────────────────────
class _NearbyUserChip extends StatelessWidget {
  final String name;
  final double distance;
  final bool isOnline;
  final VoidCallback onTap;

  const _NearbyUserChip({
    required this.name,
    required this.distance,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                AvatarWidget(
                    name: name,
                    size: 26,
                    backgroundColor: AppColors.primary),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              name.split(' ').first,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${distance}km',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
