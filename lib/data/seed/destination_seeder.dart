import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_providers.dart';

/// Uploads the curated content in assets/data/destinations.json to Firestore:
///   destinations/{id}                     (destination fields)
///   destinations/{id}/experiences/{expId} (one document per experience)
/// Safe to run again: documents are overwritten by id, never duplicated.
class DestinationSeeder {
  DestinationSeeder(this._db);

  final FirebaseFirestore _db;

  Future<int> seed() async {
    final raw = await rootBundle.loadString('assets/data/destinations.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final destinations =
    (json['destinations'] as List).cast<Map<String, dynamic>>();

    // A batch sends every write together: all succeed or none do.
    final batch = _db.batch();

    for (final source in destinations) {
      final destination = Map<String, dynamic>.from(source);
      final experiences = (destination.remove('experiences') as List)
          .cast<Map<String, dynamic>>();

      final destinationRef =
      _db.collection('destinations').doc(destination['id'] as String);
      batch.set(destinationRef, {
        ...destination,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      for (final (index, experience) in experiences.indexed) {
        final experienceRef = destinationRef
            .collection('experiences')
            .doc(experience['id'] as String);
        batch.set(experienceRef, {...experience, 'sortOrder': index + 1});
      }
    }

    await batch.commit();
    return destinations.length;
  }
}

final destinationSeederProvider = Provider<DestinationSeeder>(
      (ref) => DestinationSeeder(ref.watch(firestoreProvider)),
);