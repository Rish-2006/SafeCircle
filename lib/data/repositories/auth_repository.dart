import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../core/services/notification_service.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();
  UserModel? _customUser;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
    _init();
  }

  void _init() {
    try {
      _firebaseAuth.authStateChanges().listen((User? user) {
        if (user != null) {
          final model = UserModel(
            uid: user.uid,
            email: user.email ?? 'user@safecircle.app',
            displayName: (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : 'SafeCircle User',
            photoUrl: user.photoURL,
            phoneNumber: user.phoneNumber,
            createdAt: DateTime.now(),
          );
          _customUser = model;
          _authStateController.add(model);
        } else if (_customUser != null && _customUser!.uid.startsWith('demo_')) {
          _authStateController.add(_customUser);
        } else {
          _customUser = null;
          _authStateController.add(null);
        }
      }, onError: (e) {
        debugPrint('Auth listener error: $e');
        if (_customUser != null) {
          _authStateController.add(_customUser);
        }
      });
    } catch (e) {
      debugPrint('Firebase Auth init error: $e');
    }
  }

  Stream<UserModel?> get authStateChanges async* {
    yield currentUser;
    yield* _authStateController.stream;
  }

  UserModel? get currentUser {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserModel(
          uid: user.uid,
          email: user.email ?? 'user@safecircle.app',
          displayName: (user.displayName != null && user.displayName!.isNotEmpty)
              ? user.displayName!
              : 'SafeCircle User',
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error getting currentUser from FirebaseAuth: $e');
    }
    return _customUser;
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          final model = UserModel(
            uid: user.uid,
            email: user.email ?? googleUser.email,
            displayName: (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : (googleUser.displayName ?? 'SafeCircle User'),
            photoUrl: user.photoURL ?? googleUser.photoUrl,
            phoneNumber: user.phoneNumber,
            createdAt: DateTime.now(),
          );

          _customUser = model;
          _authStateController.add(model);
          NotificationService().subscribeToContactTopic(model.uid).catchError((e) => null);
          return model;
        }
      }
    } catch (e) {
      debugPrint('Google Sign In error / fallback active: $e');
    }
    return await signInDemoUser();
  }

  Future<UserModel> signInDemoUser() async {
    User? firebaseUser;
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      firebaseUser = userCredential.user;
    } catch (e) {
      debugPrint('Firebase anonymous sign in fallback: $e');
    }

    final uid = firebaseUser?.uid ?? 'demo_user_123';
    final demoUser = UserModel(
      uid: uid,
      email: firebaseUser?.email ?? 'demo@safecircle.app',
      displayName: 'SafeCircle Demo User',
      phoneNumber: '+1 555-0199',
      createdAt: DateTime.now(),
    );

    _customUser = demoUser;
    _authStateController.add(demoUser);
    NotificationService().subscribeToContactTopic(uid).catchError((e) => null);
    return demoUser;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Sign out exception: $e');
    }
    _customUser = null;
    _authStateController.add(null);
  }

  void updateCurrentUser(UserModel user) {
    _customUser = user;
    _authStateController.add(user);
  }
}

