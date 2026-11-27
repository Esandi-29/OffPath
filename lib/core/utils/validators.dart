/// Form validators. Each returns an error message, or null when valid.
/// Kept separate from the screens so they can be unit tested (task 5.1).
abstract final class Validators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your name.';
    if (v.length > 40) return 'Name must be 40 characters or fewer.';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email.';
    if (!_emailPattern.hasMatch(v)) return 'Please enter a valid email address.';
    return null;
  }

  /// Login only checks a password was entered.
  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Please enter your password.' : null;

  /// Registration: Firebase requires at least 6 characters.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please enter a password.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  // ---- Trip form ----

  static String? tripName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter a trip name.';
    if (v.length > 40) return 'Trip name must be 40 characters or fewer.';
    return null;
  }

  static String? tripDestination(String? destinationId) =>
      (destinationId == null || destinationId.isEmpty)
          ? 'Please choose a destination.'
          : null;

  /// The date picker can't return an end before the start, so the second
  /// check is a safety net (e.g. for bad data loaded from Firestore).
  static String? tripDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Choose your trip dates.';
    if (end.isBefore(start)) return "End date can't be before start date.";
    return null;
  }

  static String? tripNotes(String? value) =>
      (value ?? '').length > 500 ? 'Notes must be 500 characters or fewer.' : null;
}