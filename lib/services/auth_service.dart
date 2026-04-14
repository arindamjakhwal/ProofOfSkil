import '../models/user_model.dart';

/// Abstracted auth service — replace internals with Firebase Auth.
class AuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Sign in with email and password.
  /// Replace with: FirebaseAuth.instance.signInWithEmailAndPassword()
  Future<UserModel> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: 'user_001',
      name: 'Tanay Prasad',
      email: email,
      skillsOffered: ['Flutter', 'Python', 'Firebase'],
      skillsWanted: ['UI/UX Design', 'Machine Learning', 'Blockchain'],
      rating: 4.8,
      totalRatings: 42,
      points: 2450,
      sessionsCompleted: 12,
      skillsLearned: 5,
      createdAt: DateTime(2026, 1, 15),
    );
    return _currentUser!;
  }

  /// Sign up with email and password.
  /// Replace with: FirebaseAuth.instance.createUserWithEmailAndPassword()
  Future<UserModel> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      points: 200,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  /// Sign in with Google.
  /// Replace with: GoogleSignIn + FirebaseAuth
  Future<UserModel> signInWithGoogle() async {
    return signIn('tanay@example.com', '');
  }

  /// Sign out.
  Future<void> signOut() async {
    _currentUser = null;
  }
}
