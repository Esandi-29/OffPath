import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

/// AuthRepository backed by Firebase Authentication (email/password).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
  );

  // userChanges() also fires when the display name is updated.
  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Turns Firebase error codes into friendly messages.
  String _messageFor(FirebaseAuthException e) => switch (e.code) {
    'invalid-email' => "That email address doesn't look right.",
    'user-disabled' => 'This account has been disabled.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' =>
    'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists with this email.',
    'weak-password' => 'Please choose a stronger password.',
    'network-request-failed' =>
    'No internet connection. Check your connection and try again.',
    'too-many-requests' =>
    'Too many attempts. Please wait a moment and try again.',
    _ => 'Something went wrong (${e.code}). Please try again.',
  };
}