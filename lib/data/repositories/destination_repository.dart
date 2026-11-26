import '../models/destination.dart';
import '../models/experience.dart';

/// Read-only access to the curated content. Streams update live, and
/// Firestore serves them from the device cache when offline.
abstract class DestinationRepository {
  /// All destinations, in curated order.
  Stream<List<Destination>> watchAll();

  /// One destination (null if it doesn't exist).
  Stream<Destination?> watchById(String id);

  /// The experiences of one destination, in curated order.
  Stream<List<Experience>> watchExperiences(String destinationId);
}