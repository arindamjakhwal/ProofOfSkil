enum SessionStatus { pending, active, completed, cancelled }

class SessionModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String learnerId;
  final String learnerName;
  final String skill;
  final SessionStatus status;
  final int pointsExchanged;
  final DateTime createdAt;
  final DateTime? completedAt;

  // Deep Focus Session fields
  final DateTime? startTime;
  final DateTime? endTime;
  final int duration; // in minutes
  final double deepFocusScore;
  final bool user1Ready;
  final bool user2Ready;

  const SessionModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.learnerId,
    required this.learnerName,
    required this.skill,
    this.status = SessionStatus.pending,
    this.pointsExchanged = 100,
    required this.createdAt,
    this.completedAt,
    this.startTime,
    this.endTime,
    this.duration = 0,
    this.deepFocusScore = 0.0,
    this.user1Ready = false,
    this.user2Ready = false,
  });

  SessionModel copyWith({
    SessionStatus? status,
    DateTime? completedAt,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    double? deepFocusScore,
    bool? user1Ready,
    bool? user2Ready,
    int? pointsExchanged,
  }) {
    return SessionModel(
      id: id,
      teacherId: teacherId,
      teacherName: teacherName,
      learnerId: learnerId,
      learnerName: learnerName,
      skill: skill,
      status: status ?? this.status,
      pointsExchanged: pointsExchanged ?? this.pointsExchanged,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      deepFocusScore: deepFocusScore ?? this.deepFocusScore,
      user1Ready: user1Ready ?? this.user1Ready,
      user2Ready: user2Ready ?? this.user2Ready,
    );
  }

  /// Whether both users have confirmed readiness
  bool get bothReady => user1Ready && user2Ready;

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'learnerId': learnerId,
        'learnerName': learnerName,
        'skill': skill,
        'status': status.name,
        'pointsExchanged': pointsExchanged,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'duration': duration,
        'deepFocusScore': deepFocusScore,
        'user1Ready': user1Ready,
        'user2Ready': user2Ready,
      };

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] as String,
        teacherId: json['teacherId'] as String,
        teacherName: json['teacherName'] as String,
        learnerId: json['learnerId'] as String,
        learnerName: json['learnerName'] as String,
        skill: json['skill'] as String,
        status: SessionStatus.values.byName(json['status'] as String),
        pointsExchanged: json['pointsExchanged'] as int? ?? 100,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        duration: json['duration'] as int? ?? 0,
        deepFocusScore:
            (json['deepFocusScore'] as num?)?.toDouble() ?? 0.0,
        user1Ready: json['user1Ready'] as bool? ?? false,
        user2Ready: json['user2Ready'] as bool? ?? false,
      );
}
