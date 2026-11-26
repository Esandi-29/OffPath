import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offpath/app.dart';
import 'package:offpath/data/models/app_user.dart';
import 'package:offpath/data/repositories/auth_repository.dart';
import 'package:offpath/features/auth/auth_providers.dart';

/// Stands in for Firebase in tests: always signed in as [user] (or signed out).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.user);

  final AppUser? user;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(user);

  @override
  AppUser? get currentUser => user;

  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

Future<void> pumpApp(WidgetTester tester, AppUser? user) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(user)),
      ],
      child: const OffPathApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Signed-out user is sent to Login', (tester) async {
    await pumpApp(tester, null);

    expect(find.text('Welcome back, traveller'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Signed-in user opens on Discover and can switch tabs',
          (tester) async {
        await pumpApp(
          tester,
          const AppUser(uid: 'test', email: 'test@offpath.app', displayName: 'Test'),
        );

        // Discover appears twice: the app bar title and the tab label.
        expect(find.text('Discover'), findsNWidgets(2));

        await tester.tap(find.text('Explore'));
        await tester.pumpAndSettle();
        expect(find.text('Search and filters coming in 2.6'), findsOneWidget);
      });
}