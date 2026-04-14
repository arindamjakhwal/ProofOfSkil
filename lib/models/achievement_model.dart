enum AchievementType {
  firstSession,
  fiveSessions,
  tenSessions,
  twentyFiveSessions,
  fiftySessions,
  firstRating,
  topRated,
  skillCollector,
  streakWeek,
}

class AchievementModel {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon; // Material icon name
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredCount;
  final int currentCount;

  const AchievementModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.requiredCount,
    this.currentCount = 0,
  });

  double get progress =>
      requiredCount > 0 ? (currentCount / requiredCount).clamp(0.0, 1.0) : 0;

  AchievementModel copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentCount,
  }) {
    return AchievementModel(
      id: id,
      type: type,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requiredCount: requiredCount,
      currentCount: currentCount ?? this.currentCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'icon': icon,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'requiredCount': requiredCount,
        'currentCount': currentCount,
      };

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] as String,
        type: AchievementType.values.byName(json['type'] as String),
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
        requiredCount: json['requiredCount'] as int,
        currentCount: json['currentCount'] as int? ?? 0,
      );
}
