import '../models/trip.dart';

/// The signed-in user's trips. Writes go to Firestore's cache on the device
/// first, so they work offline and sync when the connection comes back.
abstract class TripRepository {
  /// All of the user's trips, live, by start date.
  Stream<List<Trip>> watchTrips(String uid);

  /// Saves a new trip and returns its id.
  String addTrip(String uid, Trip trip);

  /// Saves changes to an existing trip.
  void updateTrip(String uid, Trip trip);

  /// Deletes a trip.
  void deleteTrip(String uid, String tripId);
}