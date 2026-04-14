import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Helpers {
  Helpers._();

  /// Format points with comma separator: 1000 → "1,000"
  static String formatPoints(int points) {
    return NumberFormat('#,###').format(points);
  }

  /// Format date to readable string: "Apr 14, 2026"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format relative time: "2m ago", "1h ago", "3d ago"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  /// Generate initials from name: "Tanay Prasad" → "TP"
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Calculate average from list of doubles
  static double average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Format duration as mm:ss for timer display
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration in hours and minutes: "2h 30m"
  static String formatHours(double hours) {
    if (hours < 1) {
      return '${(hours * 60).toInt()}m';
    }
    final h = hours.toInt();
    final m = ((hours - h) * 60).toInt();
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  /// Get daily insight based on day of year (rotates automatically)
  static String getDailyInsight() {
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year, 1, 1),
    ).inDays;
    final index = dayOfYear % AppConstants.dailyInsights.length;
    return AppConstants.dailyInsights[index];
  }

  /// Extract quote and author from insight string
  static ({String quote, String author}) parseInsight(String insight) {
    final parts = insight.split(' — ');
    return (
      quote: parts[0].replaceAll('"', ''),
      author: parts.length > 1 ? parts[1] : 'Unknown',
    );
  }

  /// Calculate points earned from a session
  /// Formula: basePoints + (rating * 10) + (deepFocusScore * 5) + (duration * 2)
  static int calculateSessionPoints({
    required int basePoints,
    required double rating,
    required double deepFocusScore,
    required int durationMinutes,
  }) {
    final ratingBonus = (rating * 10).toInt();
    final focusBonus = (deepFocusScore * 5).toInt();
    final durationBonus = (durationMinutes * 2);
    return basePoints + ratingBonus + focusBonus + durationBonus;
  }

  /// Calculate deep focus score from session duration
  /// Score scales from 0-10 based on duration (0-60+ minutes)
  static double calculateDeepFocusScore(int durationMinutes) {
    if (durationMinutes < AppConstants.deepFocusMinMinutes) return 0.0;
    // Logarithmic scale: quick ramp then plateau
    final score = (durationMinutes / 6.0).clamp(0.0, AppConstants.deepFocusMaxScore);
    return double.parse(score.toStringAsFixed(1));
  }

  /// Truncate wallet address for display: "0x1234...5678"
  static String truncateAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
