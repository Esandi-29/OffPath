import 'package:cloud_firestore/cloud_firestore.dart';

/// Where a trip is in time. Worked out from the dates, never stored.
enum TripStatus { upcoming, happeningNow, past }

/// A trip the user plans to one destination (users/{uid}/trips/{id}).
class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.destinationName,
    required this.country,
    required this.photoUrl,
    required this.startDate,
    required this.endDate,
    this.notes = '',
    this.visited,
  });

  final String id;
  final String title;
  final String destinationId;
  // Copied from the destination when the trip is made, so the list can show
  // them without loading every destination (a common NoSQL pattern).
  final String destinationName;
  final String country;
  final String photoUrl;
  final DateTime startDate; // date only (midnight)
  final DateTime endDate;
  final String notes;
  final bool? visited; // null = "Did you go?" not answered yet

  /// "Narangala, Sri Lanka"
  String get place =>
      country.isEmpty ? destinationName : '$destinationName, $country';

  /// Days in the trip, counting the first and last day (12–18 Mar = 7).
  int get dayCount =>
      _utcDay(endDate).difference(_utcDay(startDate)).inDays + 1;

  /// Upcoming, happening now or past, compared with [today].
  TripStatus statusOn(DateTime today) {
    final day = _utcDay(today);
    if (_utcDay(endDate).isBefore(day)) return TripStatus.past;
    if (_utcDay(startDate).isAfter(day)) return TripStatus.upcoming;
    return TripStatus.happeningNow;
  }

  /// Whole days from [today] to the first day of the trip.
  int daysUntilStart(DateTime today) =>
      _utcDay(startDate).difference(_utcDay(today)).inDays;

  /// The fields saved to Firestore (the id is the document's name).
  Map<String, dynamic> toMap() => {
    'title': title,
    'destinationId': destinationId,
    'destinationName': destinationName,
    'country': country,
    'photoUrl': photoUrl,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'notes': notes,
    'visited': visited,
  };

  /// Builds a Trip from a Firestore document, with safe defaults.
  factory Trip.fromMap(String id, Map<String, dynamic> map) => Trip(
    id: id,
    title: map['title'] as String? ?? 'Untitled trip',
    destinationId: map['destinationId'] as String? ?? '',
    destinationName: map['destinationName'] as String? ?? '',
    country: map['country'] as String? ?? '',
    photoUrl: map['photoUrl'] as String? ?? '',
    startDate: _date(map['startDate']),
    endDate: _date(map['endDate']),
    notes: map['notes'] as String? ?? '',
    visited: map['visited'] as bool?,
  );

  static DateTime _date(Object? value) {
    final date = value is Timestamp ? value.toDate() : DateTime.now();
    return DateTime(date.year, date.month, date.day);
  }

  // Compares calendar days in UTC, so daylight-saving changes can't make
  // a day 23 hours long and throw the counts off by one.
  static DateTime _utcDay(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
}