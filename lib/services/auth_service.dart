import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred.');
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred.');
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':      return 'No account found with this email.';
      case 'wrong-password':      return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'invalid-email':       return 'Please enter a valid email address.';
      case 'weak-password':       return 'Password must be at least 6 characters.';
      case 'user-disabled':       return 'This account has been disabled.';
      case 'too-many-requests':   return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Check your connection.';
      case 'invalid-credential':  return 'Invalid credentials. Check your email and password.';
      default:
        debugPrint('FirebaseAuthException: ${e.code} — ${e.message}');
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

class AuthResult {
  const AuthResult._({this.user, this.errorMessage});
  factory AuthResult.success(User? user) => AuthResult._(user: user);
  factory AuthResult.failure(String message) => AuthResult._(errorMessage: message);

  final User? user;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
  bool get isFailure => errorMessage != null;
}
