import 'package:flutter_test/flutter_test.dart';
import 'package:offpath/data/models/trip.dart';
import 'package:offpath/features/trips/trip_format.dart';

Trip tripOn(DateTime start, DateTime end) => Trip(
  id: 'test',
  title: 'Test trip',
  destinationId: 'narangala',
  destinationName: 'Narangala',
  country: 'Sri Lanka',
  photoUrl: '',
  startDate: start,
  endDate: end,
);

void main() {
  final today = DateTime(2026, 11, 27);

  group('Trip status', () {
    test('a trip that starts later is upcoming', () {
      final trip = tripOn(DateTime(2026, 12, 20), DateTime(2026, 12, 26));
      expect(trip.statusOn(today), TripStatus.upcoming);
      expect(trip.daysUntilStart(today), 23);
    });

    test('a trip that includes today is happening now', () {
      final trip = tripOn(DateTime(2026, 11, 24), DateTime(2026, 11, 27));
      expect(trip.statusOn(today), TripStatus.happeningNow);
    });

    test('a trip that ended yesterday is past', () {
      final trip = tripOn(DateTime(2026, 10, 1), DateTime(2026, 11, 26));
      expect(trip.statusOn(today), TripStatus.past);
    });

    test('day count includes the first and last day', () {
      final trip = tripOn(DateTime(2027, 3, 12), DateTime(2027, 3, 18));
      expect(trip.dayCount, 7);
    });
  });

  group('Trip text', () {
    test('dates in one month', () {
      expect(formatTripDates(DateTime(2027, 3, 12), DateTime(2027, 3, 18)),
          '12–18 Mar 2027');
    });

    test('dates across two months', () {
      expect(formatTripDates(DateTime(2027, 3, 28), DateTime(2027, 4, 3)),
          '28 Mar – 3 Apr 2027');
    });

    test('dates across two years', () {
      expect(formatTripDates(DateTime(2026, 12, 28), DateTime(2027, 1, 3)),
          '28 Dec 2026 – 3 Jan 2027');
    });

    test('a one-day trip', () {
      expect(formatTripDates(DateTime(2027, 3, 12), DateTime(2027, 3, 12)),
          '12 Mar 2027');
    });

    test('month for past trips and countdown chip', () {
      expect(formatTripMonth(DateTime(2026, 10, 5)), 'Oct 2026');
      expect(formatCountdown(1), 'Tomorrow');
      expect(formatCountdown(23), 'In 23 days');
    });

    test('profile summary', () {
      final trips = [
        tripOn(DateTime(2026, 12, 20), DateTime(2026, 12, 26)),
        tripOn(DateTime(2026, 11, 26), DateTime(2026, 11, 29)),
      ];
      expect(tripSummary(trips, today), '1 upcoming · 1 happening now');
      expect(tripSummary(const [], today), 'Plan your first trip');
    });
  });
}