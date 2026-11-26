import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';

/// The one AuthRepository the app uses (tests can override it with a fake).
final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

/// The signed-in user, or null when signed out. Screens watch this.
final authStateProvider = StreamProvider<AppUser?>(
      (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);