import 'package:intl/intl.dart';

import '../../data/models/trip.dart';

final _dayMonthYear = DateFormat('d MMM y');
final _dayMonth = DateFormat('d MMM');
final _monthYear = DateFormat('MMM y');

/// "12–18 Mar 2027", "28 Mar – 3 Apr 2027", "28 Dec 2026 – 3 Jan 2027",
/// or "12 Mar 2027" for a one-day trip.
String formatTripDates(DateTime start, DateTime end) {
  final sameYear = start.year == end.year;
  final sameMonth = sameYear && start.month == end.month;
  if (sameMonth && start.day == end.day) return _dayMonthYear.format(start);
  if (sameMonth) return '${start.day}–${_dayMonthYear.format(end)}';
  if (sameYear) return '${_dayMonth.format(start)} – ${_dayMonthYear.format(end)}';
  return '${_dayMonthYear.format(start)} – ${_dayMonthYear.format(end)}';
}

/// "1 day" or "7 days".
String formatDayCount(int days) => days == 1 ? '1 day' : '$days days';

/// Month and year for past trips, e.g. "Oct 2026".
String formatTripMonth(DateTime date) => _monthYear.format(date);

/// Chip text for an upcoming trip: "Tomorrow" or "In 23 days".
String formatCountdown(int days) => days <= 1 ? 'Tomorrow' : 'In $days days';

/// Profile subtitle, e.g. "1 upcoming · 1 happening now".
String tripSummary(List<Trip> trips, DateTime today) {
  if (trips.isEmpty) return 'Plan your first trip';
  final upcoming =
      trips.where((t) => t.statusOn(today) == TripStatus.upcoming).length;
  final now =
      trips.where((t) => t.statusOn(today) == TripStatus.happeningNow).length;
  final parts = [
    if (upcoming > 0) '$upcoming upcoming',
    if (now > 0) '$now happening now',
  ];
  if (parts.isEmpty) {
    return trips.length == 1 ? '1 past trip' : '${trips.length} past trips';
  }
  return parts.join(' · ');
}