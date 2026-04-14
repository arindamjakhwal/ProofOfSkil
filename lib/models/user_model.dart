import 'user_location.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final List<String> skillsOffered;
  final List<String> skillsWanted;
  final double rating;
  final int totalRatings;
  final int points;
  final int sessionsCompleted;
  final int skillsLearned;
  final double deepFocusScore;
  final double totalHoursSpent;
  final String? walletAddress;
  final bool isOnline;
  final DateTime? lastSeen;
  final UserLocation? location;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.skillsOffered = const [],
    this.skillsWanted = const [],
    this.rating = 0.0,
    this.totalRatings = 0,
    this.points = 200,
    this.sessionsCompleted = 0,
    this.skillsLearned = 0,
    this.deepFocusScore = 0.0,
    this.totalHoursSpent = 0.0,
    this.walletAddress,
    this.isOnline = false,
    this.lastSeen,
    this.location,
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    List<String>? skillsOffered,
    List<String>? skillsWanted,
    double? rating,
    int? totalRatings,
    int? points,
    int? sessionsCompleted,
    int? skillsLearned,
    double? deepFocusScore,
    double? totalHoursSpent,
    String? walletAddress,
    bool? isOnline,
    DateTime? lastSeen,
    UserLocation? location,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      skillsOffered: skillsOffered ?? this.skillsOffered,
      skillsWanted: skillsWanted ?? this.skillsWanted,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      points: points ?? this.points,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      skillsLearned: skillsLearned ?? this.skillsLearned,
      deepFocusScore: deepFocusScore ?? this.deepFocusScore,
      totalHoursSpent: totalHoursSpent ?? this.totalHoursSpent,
      walletAddress: walletAddress ?? this.walletAddress,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }

  /// JSON serialization — ready for Firestore
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'skillsOffered': skillsOffered,
        'skillsWanted': skillsWanted,
        'rating': rating,
        'totalRatings': totalRatings,
        'points': points,
        'sessionsCompleted': sessionsCompleted,
        'skillsLearned': skillsLearned,
        'deepFocusScore': deepFocusScore,
        'totalHoursSpent': totalHoursSpent,
        'walletAddress': walletAddress,
        'isOnline': isOnline,
        'lastSeen': lastSeen?.toIso8601String(),
        'location': location?.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        bio: json['bio'] as String?,
        skillsOffered: List<String>.from(json['skillsOffered'] ?? []),
        skillsWanted: List<String>.from(json['skillsWanted'] ?? []),
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        totalRatings: json['totalRatings'] as int? ?? 0,
        points: json['points'] as int? ?? 200,
        sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
        skillsLearned: json['skillsLearned'] as int? ?? 0,
        deepFocusScore: (json['deepFocusScore'] as num?)?.toDouble() ?? 0.0,
        totalHoursSpent: (json['totalHoursSpent'] as num?)?.toDouble() ?? 0.0,
        walletAddress: json['walletAddress'] as String?,
        isOnline: json['isOnline'] as bool? ?? false,
        lastSeen: json['lastSeen'] != null
            ? DateTime.parse(json['lastSeen'] as String)
            : null,
        location: json['location'] != null
            ? UserLocation.fromJson(json['location'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
