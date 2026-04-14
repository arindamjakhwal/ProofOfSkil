import '../models/user_model.dart';

/// User profile service — replace with Firestore reads/writes.
class UserService {
  /// Fetch user profile by ID.
  /// Replace with: FirebaseFirestore.instance.collection('users').doc(id).get()
  Future<UserModel> getUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers.firstWhere((u) => u.id == id);
  }

  /// Update user profile.
  /// Replace with: FirebaseFirestore.instance.collection('users').doc(id).update()
  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return user;
  }

  /// Update user skills.
  /// Replace with: Firestore update on user document
  Future<UserModel> updateSkills(
    UserModel user, {
    List<String>? skillsOffered,
    List<String>? skillsWanted,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return user.copyWith(
      skillsOffered: skillsOffered,
      skillsWanted: skillsWanted,
    );
  }

  /// Connect wallet address to user.
  /// Replace with: Firestore update + WalletConnect verification
  Future<UserModel> connectWallet(UserModel user, String walletAddress) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return user.copyWith(walletAddress: walletAddress);
  }

  /// Update online/offline status.
  /// Replace with: Firestore Realtime update or Firebase Presence
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In production: update Firestore and Firebase Presence
  }

  /// Get users for matchmaking (users whose wants match our offers).
  /// Replace with: Firestore query with arrayContainsAny
  Future<List<UserModel>> getMatchCandidates(UserModel currentUser) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockUsers
        .where((u) => u.id != currentUser.id)
        .where((u) {
          // Check skill compatibility: their wants ∩ our offers
          final theirWants = u.skillsWanted.toSet();
          final ourOffers = currentUser.skillsOffered.toSet();
          return theirWants.intersection(ourOffers).isNotEmpty;
        })
        .toList();
  }

  /// Get available teachers for a specific skill.
  Future<List<UserModel>> getTeachersForSkill(String skill, String excludeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers
        .where((u) => u.id != excludeId)
        .where((u) => u.skillsOffered.contains(skill))
        .toList();
  }

  /// Get available learners wanting a specific skill.
  Future<List<UserModel>> getLearnersForSkill(String skill, String excludeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers
        .where((u) => u.id != excludeId)
        .where((u) => u.skillsWanted.contains(skill))
        .toList();
  }

  /// Add points to user.
  Future<UserModel> addPoints(UserModel user, int amount) async {
    return user.copyWith(points: user.points + amount);
  }

  /// Calculate and update points after a session.
  /// Formula: basePoints + (rating * 10) + (deepFocusScore * 5) + (duration * 2)
  Future<UserModel> addSessionPoints({
    required UserModel user,
    required int basePoints,
    required double deepFocusScore,
    required int durationMinutes,
  }) async {
    final earned = basePoints +
        (user.rating * 10).toInt() +
        (deepFocusScore * 5).toInt() +
        (durationMinutes * 2);
    return user.copyWith(
      points: user.points + earned,
      sessionsCompleted: user.sessionsCompleted + 1,
      deepFocusScore: double.parse(
        ((user.deepFocusScore + deepFocusScore) / 2).toStringAsFixed(1),
      ),
      totalHoursSpent: user.totalHoursSpent + (durationMinutes / 60.0),
    );
  }

  /// Update user rating with new score.
  Future<UserModel> updateRating(UserModel user, int newScore) async {
    final newTotal = user.totalRatings + 1;
    final newRating =
        ((user.rating * user.totalRatings) + newScore) / newTotal;
    return user.copyWith(
      rating: double.parse(newRating.toStringAsFixed(1)),
      totalRatings: newTotal,
    );
  }
}

// Mock data — will be replaced by Firestore
final List<UserModel> _mockUsers = [
  UserModel(
    id: 'user_002',
    name: 'Aarav Sharma',
    email: 'aarav@example.com',
    bio: 'Full-stack developer passionate about React and cloud computing.',
    skillsOffered: ['React', 'Node.js', 'TypeScript'],
    skillsWanted: ['Flutter', 'UI/UX Design'],
    rating: 4.9,
    totalRatings: 28,
    points: 3200,
    sessionsCompleted: 28,
    skillsLearned: 8,
    deepFocusScore: 7.2,
    totalHoursSpent: 42.5,
    isOnline: true,
    createdAt: DateTime(2025, 11, 1),
  ),
  UserModel(
    id: 'user_003',
    name: 'Priya Patel',
    email: 'priya@example.com',
    bio: 'UI/UX Designer creating beautiful digital experiences.',
    skillsOffered: ['Figma', 'UI/UX Design', 'Photography'],
    skillsWanted: ['Python', 'Data Science'],
    rating: 4.7,
    totalRatings: 15,
    points: 1800,
    sessionsCompleted: 15,
    skillsLearned: 4,
    deepFocusScore: 6.4,
    totalHoursSpent: 22.0,
    isOnline: true,
    createdAt: DateTime(2026, 1, 10),
  ),
  UserModel(
    id: 'user_004',
    name: 'Rohan Mehta',
    email: 'rohan@example.com',
    bio: 'ML Engineer exploring the intersection of AI and mobile development.',
    skillsOffered: ['Machine Learning', 'Python', 'Data Science'],
    skillsWanted: ['Flutter', 'Photography'],
    rating: 4.8,
    totalRatings: 32,
    points: 4100,
    sessionsCompleted: 32,
    skillsLearned: 6,
    deepFocusScore: 8.1,
    totalHoursSpent: 58.0,
    isOnline: true,
    createdAt: DateTime(2025, 9, 20),
  ),
  UserModel(
    id: 'user_005',
    name: 'Sneha Iyer',
    email: 'sneha@example.com',
    bio: 'Creative marketer with expertise in content and video production.',
    skillsOffered: ['Marketing', 'Content Writing', 'Video Editing'],
    skillsWanted: ['React', 'JavaScript'],
    rating: 4.6,
    totalRatings: 19,
    points: 2100,
    sessionsCompleted: 19,
    skillsLearned: 3,
    deepFocusScore: 5.8,
    totalHoursSpent: 28.0,
    isOnline: false,
    lastSeen: DateTime.now().subtract(const Duration(hours: 3)),
    createdAt: DateTime(2026, 2, 5),
  ),
  UserModel(
    id: 'user_006',
    name: 'Karan Singh',
    email: 'karan@example.com',
    bio: 'Blockchain developer building the future of decentralized apps.',
    skillsOffered: ['Blockchain', 'Solidity', 'Go'],
    skillsWanted: ['Flutter', 'Python'],
    rating: 4.5,
    totalRatings: 10,
    points: 1500,
    sessionsCompleted: 10,
    skillsLearned: 2,
    deepFocusScore: 6.0,
    totalHoursSpent: 15.0,
    isOnline: false,
    lastSeen: DateTime.now().subtract(const Duration(hours: 8)),
    createdAt: DateTime(2026, 3, 1),
  ),
];
