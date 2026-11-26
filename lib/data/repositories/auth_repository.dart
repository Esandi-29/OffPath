import '../models/app_user.dart';

/// Everything the app needs from authentication. The UI only uses this
/// interface, so Firebase can be swapped for a fake in tests.
abstract class AuthRepository {
  /// Emits the current user (or null) now and whenever it changes.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

/// An auth error with a message that is safe to show to the user.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}