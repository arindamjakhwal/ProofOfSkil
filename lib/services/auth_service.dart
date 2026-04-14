import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<UserModel> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Sign-in failed: no Firebase user returned');
    }
    await _upsertUserProfile(user);
    _currentUser = _mapFirebaseUser(user);
    return _currentUser!;
  }

  Future<UserModel> signUp(String name, String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Sign-up failed: no Firebase user returned');
    }

    if ((user.displayName ?? '').trim().isEmpty) {
      await user.updateDisplayName(name);
      await user.reload();
    }

    final refreshedUser = _firebaseAuth.currentUser ?? user;
    await _upsertUserProfile(refreshedUser);
    _currentUser = _mapFirebaseUser(refreshedUser);
    return _currentUser!;
  }

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final credential =
        await _firebaseAuth.signInWithCredential(oauthCredential);
    final user = credential.user;
    if (user == null) {
      throw Exception('Google sign-in failed: no Firebase user returned');
    }

    await _upsertUserProfile(user);
    _currentUser = _mapFirebaseUser(user);
    return _currentUser!;
  }

  Future<void> _upsertUserProfile(User user) async {
    final uid = user.uid;
    final email = user.email ?? '';
    final displayName = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!.trim()
        : (email.isNotEmpty ? email.split('@').first : 'User');

    final usersRef = _firestore.collection('users');

    if (email.isNotEmpty) {
      final legacyByEmail = await usersRef
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (legacyByEmail.docs.isNotEmpty && legacyByEmail.docs.first.id != uid) {
        final legacyData = legacyByEmail.docs.first.data();
        await usersRef.doc(uid).set({
          ...legacyData,
          'uid': uid,
          'id': uid,
          'name': legacyData['name'] ?? displayName,
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }
    }

    await usersRef.doc(uid).set({
      'uid': uid,
      'id': uid,
      'name': displayName,
      'email': email,
      'skillsOffered': const <String>[],
      'skillsWanted': const <String>[],
      'rating': 0,
      'points': 200,
      'bio': '',
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': user.metadata.creationTime ?? DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  UserModel _mapFirebaseUser(User user) {
    final derivedName = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'User');

    return UserModel(
      id: user.uid,
      name: derivedName,
      email: user.email ?? '',
      points: 200,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
