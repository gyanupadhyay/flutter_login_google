import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_login_google/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signInWithGoogle();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const List<String> _requestedScopes = <String>[
    // Standard userinfo scopes (safe, non-empty)
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      // Access token is optional for Firebase; try to obtain it for standard scopes.
      // NOTE: Passing an empty list throws: "requestedScopes cannot be null or empty".
      String? accessToken;
      try {
        final authorization = await googleUser.authorizationClient
            .authorizationForScopes(_requestedScopes);
        accessToken = authorization?.accessToken;
      } catch (_) {
        // If access token retrieval fails, continue with idToken-only sign-in.
        accessToken = null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return null;
      }

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException {
      // Re-throw to be handled by repository
      rethrow;
    } on GoogleSignInException {
      // Re-throw to be handled by repository
      rethrow;
    } catch (e) {
      // Re-throw as generic exception
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    // Re-throw exceptions to be handled by repository
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
