import '../models/destination.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';

/// Debug helper: adds three example trips (upcoming, happening now and past)
/// so My trips can be tested before the trip form exists.
/// Returns how many trips were added.
int addSampleTrips(
    TripRepository repository,
    String uid,
    List<Destination> destinations,
    ) {
  final now = DateTime.now();
  DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);

  final plans = [
    ('narangala', 'Hill escape', day(23), day(29)),
    ('lake-bohinj', 'Alpine week', day(-1), day(2)),
    ('mardin', 'Old town walk', day(-40), day(-37)),
  ];

  var added = 0;
  for (final (id, title, start, end) in plans) {
    final matches = destinations.where((d) => d.id == id);
    if (matches.isEmpty) continue;
    final destination = matches.first;
    repository.addTrip(
      uid,
      Trip(
        id: '', // Firestore makes the real id
        title: title,
        destinationId: destination.id,
        destinationName: destination.name,
        country: destination.country,
        photoUrl: destination.photo.url,
        startDate: start,
        endDate: end,
      ),
    );
    added++;
  }
  return added;
}