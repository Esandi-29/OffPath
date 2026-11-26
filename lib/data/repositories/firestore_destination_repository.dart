import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/destination.dart';
import '../models/experience.dart';
import 'destination_repository.dart';

class FirestoreDestinationRepository implements DestinationRepository {
  FirestoreDestinationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _destinations =>
      _db.collection('destinations');

  @override
  Stream<List<Destination>> watchAll() => _destinations
      .orderBy('sortOrder')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Destination.fromMap(doc.id, doc.data()))
      .toList());

  @override
  Stream<Destination?> watchById(String id) =>
      _destinations.doc(id).snapshots().map((doc) {
        final data = doc.data();
        return data == null ? null : Destination.fromMap(doc.id, data);
      });

  @override
  Stream<List<Experience>> watchExperiences(String destinationId) =>
      _destinations
          .doc(destinationId)
          .collection('experiences')
          .orderBy('sortOrder')
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Experience.fromMap(doc.id, doc.data()))
          .toList());
}