import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase_providers.dart';
import '../../data/models/trip.dart';
import '../../data/repositories/firestore_trip_repository.dart';
import '../../data/repositories/trip_repository.dart';
import '../auth/auth_providers.dart';

/// The one TripRepository the app uses (tests can override it with a fake).
final tripRepositoryProvider = Provider<TripRepository>(
      (ref) => FirestoreTripRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's trips, live. Empty when signed out.
final tripsProvider = StreamProvider<List<Trip>>((ref) {
  final uid = ref.watch(authStateProvider.select((auth) => auth.value?.uid));
  if (uid == null) return Stream.value(const []);
  return ref.watch(tripRepositoryProvider).watchTrips(uid);
});