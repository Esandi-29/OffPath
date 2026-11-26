import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Firebase services, provided once so repositories (and tests) share them.
final firebaseAuthProvider =
Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);