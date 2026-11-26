import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase_providers.dart';
import '../../data/models/destination.dart';
import '../../data/models/experience.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/firestore_destination_repository.dart';
import '../auth/auth_providers.dart';

final destinationRepositoryProvider = Provider<DestinationRepository>(
      (ref) => FirestoreDestinationRepository(ref.watch(firestoreProvider)),
);

/// The signed-in user's id. Providers below watch it so they re-subscribe
/// after logging in or out (the security rules require a signed-in user).
final _uidProvider = Provider<String?>(
      (ref) => ref.watch(authStateProvider.select((auth) => auth.value?.uid)),
);

/// All destinations, live from Firestore.
final destinationsProvider = StreamProvider<List<Destination>>((ref) {
  if (ref.watch(_uidProvider) == null) return Stream.value(const []);
  return ref.watch(destinationRepositoryProvider).watchAll();
});

/// Featured destinations, worked out from the full list (no extra query).
final featuredDestinationsProvider = Provider<AsyncValue<List<Destination>>>(
      (ref) => ref
      .watch(destinationsProvider)
      .whenData((all) => all.where((d) => d.featured).toList()),
);

/// Destinations in one collection, e.g. 'hidden-villages'.
final collectionDestinationsProvider =
Provider.family<AsyncValue<List<Destination>>, String>(
      (ref, collectionId) => ref.watch(destinationsProvider).whenData(
          (all) => all.where((d) => d.collections.contains(collectionId)).toList()),
);

/// One destination, for Destination Details.
final destinationProvider =
StreamProvider.autoDispose.family<Destination?, String>((ref, id) {
  if (ref.watch(_uidProvider) == null) return Stream.value(null);
  return ref.watch(destinationRepositoryProvider).watchById(id);
});

/// A destination's experiences, for the Experiences tab.
final experiencesProvider =
StreamProvider.autoDispose.family<List<Experience>, String>((ref, id) {
  if (ref.watch(_uidProvider) == null) return Stream.value(const []);
  return ref.watch(destinationRepositoryProvider).watchExperiences(id);
});