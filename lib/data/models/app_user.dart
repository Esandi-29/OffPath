/// The signed-in traveller. A plain Dart class, independent of Firebase,
/// so screens and tests don't depend on Firebase types.
class AppUser {
  const AppUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;
}