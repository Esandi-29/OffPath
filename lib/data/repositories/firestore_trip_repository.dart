import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/trip.dart';
import 'trip_repository.dart';

class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _trips(String uid) =>
      _db.collection('users').doc(uid).collection('trips');

  @override
  Stream<List<Trip>> watchTrips(String uid) => _trips(uid)
      .orderBy('startDate')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Trip.fromMap(doc.id, doc.data()))
      .toList());

  // The writes below are not awaited on purpose. Firestore saves them on the
  // device straight away, but the Future only finishes when the server
  // confirms, which never happens offline. The live stream above already
  // shows the change, so the app doesn't need to wait.

  @override
  String addTrip(String uid, Trip trip) {
    final doc = _trips(uid).doc(); // new random id, made on the device
    doc.set({
      ...trip.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError(_logError);
    return doc.id;
  }

  @override
  void updateTrip(String uid, Trip trip) {
    _trips(uid).doc(trip.id).update({
      ...trip.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError(_logError);
  }

  @override
  void deleteTrip(String uid, String tripId) {
    _trips(uid).doc(tripId).delete().catchError(_logError);
  }

  static void _logError(Object error) =>
      debugPrint('Trip write failed: $error');
}