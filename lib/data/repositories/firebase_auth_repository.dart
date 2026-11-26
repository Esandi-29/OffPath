import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// AuthRepository backed by Firebase Authentication (email/password).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Accounts created before profiles existed get one now.
      await _ensureProfile(credential.user!);
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
      await _ensureProfile(credential.user!, name: name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Creates users/{uid} the first time this account is seen.
  /// A failure here must not block sign-in, so it is only logged.
  Future<void> _ensureProfile(User user, {String? name}) async {
    try {
      final doc = _db.collection('users').doc(user.uid);
      final snapshot = await doc.get();
      if (snapshot.exists) return;
      await doc.set({
        'displayName': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'interests': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Could not create profile for ${user.uid}: ${e.code}');
    }
  }

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