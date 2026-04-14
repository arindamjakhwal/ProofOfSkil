import '../models/user_model.dart';
import '../models/user_location.dart';
import '../models/learning_space_model.dart';

/// Location service — replace with Geolocator + Firestore GeoQuery.
class LocationService {
  // Mock current user location (New Delhi area)
  static const UserLocation _currentLocation = UserLocation(
    latitude: 28.6139,
    longitude: 77.2090,
  );

  /// Get the current user's location.
  /// Replace with: Geolocator.getCurrentPosition()
  Future<UserLocation> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentLocation;
  }

  /// Get nearby users within a radius (km).
  /// Replace with: Firestore GeoQuery or GeoFlutterFire
  Future<List<NearbyUser>> getNearbyUsers({
    required String currentUserId,
    double radiusKm = 10.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockNearbyUsers
        .where((u) => u.user.id != currentUserId)
        .where((u) =>
            _currentLocation.distanceTo(u.location) <= radiusKm)
        .toList();
  }

  /// Get nearby learning spaces.
  /// Replace with: Firestore collection 'learningSpaces' or Google Places API
  Future<List<LearningSpaceModel>> getNearbySpaces({
    double radiusKm = 10.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSpaces;
  }
}

/// A user with their location for map display.
class NearbyUser {
  final UserModel user;
  final UserLocation location;
  final double distanceKm;

  const NearbyUser({
    required this.user,
    required this.location,
    this.distanceKm = 0.0,
  });
}

// ─── Mock Nearby Users ─────────────────────────────────────
final List<NearbyUser> _mockNearbyUsers = [
  NearbyUser(
    user: UserModel(
      id: 'user_002',
      name: 'Aarav Sharma',
      email: 'aarav@example.com',
      bio: 'Full-stack developer passionate about React.',
      skillsOffered: ['React', 'Node.js', 'TypeScript'],
      skillsWanted: ['Flutter', 'UI/UX Design'],
      rating: 4.9,
      totalRatings: 28,
      points: 3200,
      sessionsCompleted: 28,
      skillsLearned: 8,
      isOnline: true,
      createdAt: DateTime(2025, 11, 1),
    ),
    location: const UserLocation(latitude: 28.6200, longitude: 77.2150),
    distanceKm: 1.2,
  ),
  NearbyUser(
    user: UserModel(
      id: 'user_003',
      name: 'Priya Patel',
      email: 'priya@example.com',
      bio: 'UI/UX Designer creating beautiful experiences.',
      skillsOffered: ['Figma', 'UI/UX Design'],
      skillsWanted: ['Python', 'Data Science'],
      rating: 4.7,
      totalRatings: 15,
      points: 1800,
      sessionsCompleted: 15,
      isOnline: true,
      createdAt: DateTime(2026, 1, 10),
    ),
    location: const UserLocation(latitude: 28.6080, longitude: 77.2020),
    distanceKm: 0.8,
  ),
  NearbyUser(
    user: UserModel(
      id: 'user_004',
      name: 'Rohan Mehta',
      email: 'rohan@example.com',
      bio: 'ML Engineer exploring AI and mobile dev.',
      skillsOffered: ['Machine Learning', 'Python'],
      skillsWanted: ['Flutter', 'Photography'],
      rating: 4.8,
      totalRatings: 32,
      points: 4100,
      sessionsCompleted: 32,
      isOnline: false,
      createdAt: DateTime(2025, 9, 20),
    ),
    location: const UserLocation(latitude: 28.6250, longitude: 77.1980),
    distanceKm: 1.8,
  ),
  NearbyUser(
    user: UserModel(
      id: 'user_005',
      name: 'Sneha Iyer',
      email: 'sneha@example.com',
      bio: 'Creative marketer and content creator.',
      skillsOffered: ['Marketing', 'Content Writing'],
      skillsWanted: ['React', 'JavaScript'],
      rating: 4.6,
      totalRatings: 19,
      points: 2100,
      sessionsCompleted: 19,
      isOnline: true,
      createdAt: DateTime(2026, 2, 5),
    ),
    location: const UserLocation(latitude: 28.6050, longitude: 77.2180),
    distanceKm: 1.5,
  ),
  NearbyUser(
    user: UserModel(
      id: 'user_006',
      name: 'Karan Singh',
      email: 'karan@example.com',
      bio: 'Blockchain developer building decentralized apps.',
      skillsOffered: ['Blockchain', 'Solidity'],
      skillsWanted: ['Flutter', 'Python'],
      rating: 4.5,
      totalRatings: 10,
      points: 1500,
      sessionsCompleted: 10,
      isOnline: false,
      createdAt: DateTime(2026, 3, 1),
    ),
    location: const UserLocation(latitude: 28.6300, longitude: 77.2100),
    distanceKm: 2.1,
  ),
];

// ─── Mock Learning Spaces ──────────────────────────────────
final List<LearningSpaceModel> _mockSpaces = [
  const LearningSpaceModel(
    id: 'space_001',
    name: 'Central Public Library',
    latitude: 28.6180,
    longitude: 77.2050,
    type: SpaceType.library,
    address: 'Connaught Place, New Delhi',
    rating: 4.5,
  ),
  const LearningSpaceModel(
    id: 'space_002',
    name: 'The Study Café',
    latitude: 28.6100,
    longitude: 77.2130,
    type: SpaceType.cafe,
    address: 'Janpath Rd, New Delhi',
    rating: 4.3,
  ),
  const LearningSpaceModel(
    id: 'space_003',
    name: 'Innovation Hub',
    latitude: 28.6220,
    longitude: 77.2000,
    type: SpaceType.coworking,
    address: 'Barakhamba Road, New Delhi',
    rating: 4.7,
  ),
  const LearningSpaceModel(
    id: 'space_004',
    name: 'Garden Study Area',
    latitude: 28.6160,
    longitude: 77.2200,
    type: SpaceType.openSpace,
    address: 'India Gate Lawns, New Delhi',
    rating: 4.1,
  ),
];
