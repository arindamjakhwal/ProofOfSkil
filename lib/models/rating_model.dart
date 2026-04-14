class RatingModel {
  final String id;
  final String sessionId;
  final String fromUserId;
  final String toUserId;
  final int score; // 1–5
  final String? feedback;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.sessionId,
    required this.fromUserId,
    required this.toUserId,
    required this.score,
    this.feedback,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'score': score,
        'feedback': feedback,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        fromUserId: json['fromUserId'] as String,
        toUserId: json['toUserId'] as String,
        score: json['score'] as int,
        feedback: json['feedback'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
