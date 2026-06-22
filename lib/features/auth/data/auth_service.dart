import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// =============================================================================
// Riverpod Providers
// =============================================================================

/// Provides the [FirebaseAuth] singleton instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Streams the current auth state (signed-in [User] or `null`).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Provides the [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

// =============================================================================
// AuthService
// =============================================================================

/// Manages Firebase Authentication with Google Sign-In.
///
/// **IMPORTANT**: Before using Google Sign-In, you must enable the Google
/// sign-in provider in the Firebase Console:
///   Firebase Console → Authentication → Sign-in method → Google → Enable
///
/// On Android, ensure the app's SHA-1 fingerprint is registered in the
/// Firebase project settings.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  bool _googleInitialized = false;

  /// The currently signed-in user, or `null`.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Ensures [GoogleSignIn] is initialized exactly once.
  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  /// Sign in with Google.
  ///
  /// Returns the [UserCredential] on success, or `null` if the user
  /// cancelled the sign-in flow.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final googleUser = await GoogleSignIn.instance.authenticate();
      // v7: authenticate() throws on cancel, so googleUser is never null.

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      // User cancelled or other error.
      if (e.toString().contains('cancel') ||
          e.toString().contains('canceled')) {
        return null;
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  /// Sign out from both Google and Firebase.
  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google sign-out failure is non-critical.
    }
    await _auth.signOut();
  }
}

/// Exception wrapper for Firebase Auth errors.
class FirebaseAuthException implements Exception {
  const FirebaseAuthException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => 'FirebaseAuthException($code): $message';
}
