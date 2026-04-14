import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/learning_space_model.dart';
import '../../services/location_service.dart';
import '../../widgets/avatar_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  List<NearbyUser> _nearbyUsers = [];
  List<LearningSpaceModel> _spaces = [];
  bool _isLoading = true;
  double _radius = 10.0;
  bool _showUsers = true;
  bool _showSpaces = true;

  // Map interaction state
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  int? _selectedUserIdx;
  int? _selectedSpaceIdx;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
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
      radiusKm: _radius,
    );
    final spaces = await _locationService.getNearbySpaces(radiusKm: _radius);
    setState(() {
      _nearbyUsers = users;
      _spaces = spaces;
      _isLoading = false;
    });
  }

  void _showUserProfile(NearbyUser nearby) {
    setState(() => _selectedSpaceIdx = null);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UserBottomSheet(nearby: nearby),
    );
  }

  void _showSpaceInfo(LearningSpaceModel space) {
    setState(() => _selectedUserIdx = null);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpaceBottomSheet(space: space),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nearby',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Filter chips
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Users',
                  icon: Icons.people_rounded,
                  isActive: _showUsers,
                  onTap: () => setState(() => _showUsers = !_showUsers),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Spaces',
                  icon: Icons.place_rounded,
                  isActive: _showSpaces,
                  onTap: () => setState(() => _showSpaces = !_showSpaces),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                // Map canvas
                GestureDetector(
                  onPanUpdate: (d) {
                    setState(() => _panOffset += d.delta);
                  },
                  onDoubleTap: () {
                    setState(() {
                      _scale = _scale >= 1.5 ? 1.0 : _scale + 0.25;
                    });
                  },
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child2) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _MapPainter(
                          users: _showUsers ? _nearbyUsers : [],
                          spaces: _showSpaces ? _spaces : [],
                          panOffset: _panOffset,
                          scale: _scale,
                          pulseValue: _pulseAnim.value,
                          selectedUserIdx: _selectedUserIdx,
                          selectedSpaceIdx: _selectedSpaceIdx,
                        ),
                      );
                    },
                  ),
                ),
                // Tap detection layer
                ..._buildTapTargets(context),
                // Stats bar
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: _buildStatsBar(),
                ),
                // Radius slider
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _buildRadiusSlider(),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildTapTargets(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2 + _panOffset.dx;
    final cy = size.height / 2 + _panOffset.dy - 60;
    final targets = <Widget>[];

    if (_showUsers) {
      for (int i = 0; i < _nearbyUsers.length; i++) {
        final u = _nearbyUsers[i];
        final angle = (i * 2 * pi / _nearbyUsers.length) - pi / 2;
        final dist = (50 + u.distanceKm * 40) * _scale;
        final x = cx + cos(angle) * dist - 18;
        final y = cy + sin(angle) * dist - 18;

        targets.add(Positioned(
          left: x,
          top: y,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedUserIdx = i);
              _showUserProfile(u);
            },
            child: const SizedBox(width: 36, height: 36),
          ),
        ));
      }
    }

    if (_showSpaces) {
      for (int i = 0; i < _spaces.length; i++) {
        final s = _spaces[i];
        final angle = (i * 2 * pi / _spaces.length) +
            pi / _spaces.length;
        final dist = (90 + i * 25) * _scale;
        final x = cx + cos(angle) * dist - 16;
        final y = cy + sin(angle) * dist - 16;

        targets.add(Positioned(
          left: x,
          top: y,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedSpaceIdx = i);
              _showSpaceInfo(s);
            },
            child: const SizedBox(width: 32, height: 32),
          ),
        ));
      }
    }

    return targets;
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            'New Delhi',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_nearbyUsers.length} users',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_spaces.length} spaces',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search Radius',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_radius.toInt()} km',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7),
            ),
            child: Slider(
              value: _radius,
              min: 1,
              max: 20,
              onChanged: (v) {
                setState(() => _radius = v);
              },
              onChangeEnd: (_) => _loadData(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map Painter (CustomPaint) ──────────────────────────────
class _MapPainter extends CustomPainter {
  final List<NearbyUser> users;
  final List<LearningSpaceModel> spaces;
  final Offset panOffset;
  final double scale;
  final double pulseValue;
  final int? selectedUserIdx;
  final int? selectedSpaceIdx;

  _MapPainter({
    required this.users,
    required this.spaces,
    required this.panOffset,
    required this.scale,
    required this.pulseValue,
    this.selectedUserIdx,
    this.selectedSpaceIdx,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 + panOffset.dx;
    final cy = size.height / 2 + panOffset.dy - 60;

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF0F4FF), Color(0xFFE8ECF4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines (subtle map feel)
    final gridPaint = Paint()
      ..color = const Color(0xFFD8DEE8)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40 * scale) {
      canvas.drawLine(
          Offset(x + (panOffset.dx % (40 * scale)), 0),
          Offset(x + (panOffset.dx % (40 * scale)), size.height),
          gridPaint);
    }
    for (double y = 0; y < size.height; y += 40 * scale) {
      canvas.drawLine(
          Offset(0, y + (panOffset.dy % (40 * scale))),
          Offset(size.width, y + (panOffset.dy % (40 * scale))),
          gridPaint);
    }

    // Radius rings
    final ringPaint = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 120 * scale, ringPaint);

    final ringStroke = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), 80 * scale, ringStroke);
    canvas.drawCircle(Offset(cx, cy), 120 * scale, ringStroke);
    canvas.drawCircle(Offset(cx, cy), 160 * scale, ringStroke);

    // Current user (blue dot with pulse)
    final pulsePaint = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.15 * pulseValue);
    canvas.drawCircle(Offset(cx, cy), 22 * pulseValue, pulsePaint);

    final dotOuter = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(cx, cy), 14, dotOuter);

    final dotInner = Paint()..color = const Color(0xFF4F46E5);
    canvas.drawCircle(Offset(cx, cy), 8, dotInner);

    final dotCenter = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 3.5, dotCenter);

    // "You" label
    final youTP = TextPainter(
      text: const TextSpan(
        text: 'You',
        style: TextStyle(
          color: Color(0xFF4F46E5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    youTP.paint(canvas, Offset(cx - youTP.width / 2, cy + 18));

    // Learning space markers
    for (int i = 0; i < spaces.length; i++) {
      final s = spaces[i];
      final angle = (i * 2 * pi / spaces.length) + pi / spaces.length;
      final dist = (90 + i * 25) * scale;
      final x = cx + cos(angle) * dist;
      final y = cy + sin(angle) * dist;
      final isSelected = selectedSpaceIdx == i;

      // Shadow
      final shadowP = Paint()
        ..color = const Color(0xFF06B6D4).withValues(alpha: 0.15);
      canvas.drawCircle(Offset(x, y + 2), isSelected ? 18 : 14, shadowP);

      // Background
      final bgP = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(x, y), isSelected ? 18 : 14, bgP);

      // Border
      final borderP = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5;
      canvas.drawCircle(Offset(x, y), isSelected ? 18 : 14, borderP);

      // Icon placeholder (small colored dot)
      final iconP = Paint()..color = const Color(0xFF06B6D4);
      canvas.drawCircle(Offset(x, y), isSelected ? 6 : 5, iconP);

      // Label
      final labelTP = TextPainter(
        text: TextSpan(
          text: s.name.length > 12 ? '${s.name.substring(0, 12)}…' : s.name,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: isSelected ? 10 : 9,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTP.paint(
          canvas, Offset(x - labelTP.width / 2, y + (isSelected ? 22 : 18)));
    }

    // User markers (circular avatar-style)
    for (int i = 0; i < users.length; i++) {
      final u = users[i];
      final angle = (i * 2 * pi / users.length) - pi / 2;
      final dist = (50 + u.distanceKm * 40) * scale;
      final x = cx + cos(angle) * dist;
      final y = cy + sin(angle) * dist;
      final isSelected = selectedUserIdx == i;
      final isOnline = u.user.isOnline;

      // Shadow
      final shadowP = Paint()
        ..color = const Color(0xFF4F46E5).withValues(alpha: 0.15);
      canvas.drawCircle(Offset(x, y + 2), isSelected ? 20 : 16, shadowP);

      // Avatar circle
      final avatarBg = Paint()..color = const Color(0xFF4F46E5);
      canvas.drawCircle(Offset(x, y), isSelected ? 20 : 16, avatarBg);

      final innerBg = Paint()..color = const Color(0xFFEEF2FF);
      canvas.drawCircle(Offset(x, y), isSelected ? 17 : 13.5, innerBg);

      // Initials
      final initials = Helpers.initials(u.user.name);
      final initialsTP = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: const Color(0xFF4F46E5),
            fontSize: isSelected ? 12 : 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      initialsTP.paint(
          canvas, Offset(x - initialsTP.width / 2, y - initialsTP.height / 2));

      // Online indicator
      if (isOnline) {
        final onlineBorder = Paint()..color = Colors.white;
        canvas.drawCircle(
            Offset(x + (isSelected ? 14 : 11), y - (isSelected ? 14 : 11)),
            5,
            onlineBorder);
        final onlineDot = Paint()..color = const Color(0xFF10B981);
        canvas.drawCircle(
            Offset(x + (isSelected ? 14 : 11), y - (isSelected ? 14 : 11)),
            3.5,
            onlineDot);
      }

      // Name label
      final nameTP = TextPainter(
        text: TextSpan(
          text: u.user.name.split(' ').first,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: isSelected ? 11 : 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      nameTP.paint(
          canvas, Offset(x - nameTP.width / 2, y + (isSelected ? 24 : 20)));
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      pulseValue != oldDelegate.pulseValue ||
      panOffset != oldDelegate.panOffset ||
      scale != oldDelegate.scale ||
      selectedUserIdx != oldDelegate.selectedUserIdx ||
      selectedSpaceIdx != oldDelegate.selectedSpaceIdx ||
      users.length != oldDelegate.users.length ||
      spaces.length != oldDelegate.spaces.length;
}

// ─── Filter Chip ────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12,
                color: isActive ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ─── User Bottom Sheet ──────────────────────────────────────
class _UserBottomSheet extends StatelessWidget {
  final NearbyUser nearby;
  const _UserBottomSheet({required this.nearby});

  @override
  Widget build(BuildContext context) {
    final u = nearby.user;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                AvatarWidget(
                    name: u.name,
                    size: 52,
                    backgroundColor: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            u.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (u.isOnline) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.warning, size: 14),
                          const SizedBox(width: 3),
                          Text('${u.rating}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text(' · ${nearby.distanceKm} km away',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (u.bio != null) ...[
              const SizedBox(height: 12),
              Text(
                u.bio!,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4),
              ),
            ],
            const SizedBox(height: 16),
            // Skills
            Row(
              children: [
                const Text('Teaches: ',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: u.skillsOffered
                        .take(3)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/chat');
                    },
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.buttonShadow,
                      ),
                      child: const Center(
                        child: Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Space Bottom Sheet ─────────────────────────────────────
class _SpaceBottomSheet extends StatelessWidget {
  final LearningSpaceModel space;
  const _SpaceBottomSheet({required this.space});

  IconData _getSpaceIcon() {
    switch (space.type) {
      case SpaceType.library:
        return Icons.local_library_rounded;
      case SpaceType.cafe:
        return Icons.coffee_rounded;
      case SpaceType.openSpace:
        return Icons.park_rounded;
      case SpaceType.coworking:
        return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getSpaceIcon(),
                      color: AppColors.secondary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        space.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(space.typeLabel,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (space.rating != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded,
                                color: AppColors.warning, size: 13),
                            const SizedBox(width: 2),
                            Text('${space.rating}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (space.address != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(space.address!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.secondary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Get Directions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
