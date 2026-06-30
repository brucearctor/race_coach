import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
/// Uses google_sign_in v6 with the legacy GoogleSignInClient API which is
/// more reliable than the v7 Credential Manager flow on many devices.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// The GoogleSignIn instance with scopes needed for Firebase Auth.
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /// The currently signed-in user, or `null`.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google.
  ///
  /// Returns the [UserCredential] on success, or `null` if the user
  /// cancelled the sign-in flow.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        debugPrint('[Auth] Starting Google Sign-In (v6 legacy flow)...');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('[Auth] User cancelled sign-in');
        }
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        debugPrint('[Auth] ✅ Sign-in successful');
      }
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[Auth] ❌ Sign-in error: $e');
        debugPrint('[Auth] Stack: $st');
      }
      rethrow;
    }
  }

  /// Sign out from both Google and Firebase.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign-out failure is non-critical.
    }
    await _auth.signOut();
  }
}
