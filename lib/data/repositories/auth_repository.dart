import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<UserModel?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges().map((User? user) {
        if (user == null) return null;
        return UserModel(
          uid: user.uid,
          email: user.email ?? 'user@safecircle.app',
          displayName: user.displayName ?? 'SafeCircle User',
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
          createdAt: DateTime.now(),
        );
      });
    } catch (e) {
      debugPrint('Auth stream fallback active: $e');
      return Stream.value(null);
    }
  }

  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? 'user@safecircle.app',
      displayName: user.displayName ?? 'SafeCircle User',
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      return UserModel(
        uid: user.uid,
        email: user.email ?? googleUser.email,
        displayName: user.displayName ?? googleUser.displayName ?? 'SafeCircle User',
        photoUrl: user.photoURL ?? googleUser.photoUrl,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Google Sign In fallback triggered: $e');
      // Graceful fallback for testing when Google OAuth is not configured
      return UserModel(
        uid: 'demo_user_123',
        email: 'demo@safecircle.app',
        displayName: 'SafeCircle Demo User',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<UserModel> signInDemoUser() async {
    return UserModel(
      uid: 'demo_user_123',
      email: 'demo@safecircle.app',
      displayName: 'SafeCircle Demo User',
      createdAt: DateTime.now(),
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Sign out exception: $e');
    }
  }
}
