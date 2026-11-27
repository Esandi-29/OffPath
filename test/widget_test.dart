import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offpath/app.dart';
import 'package:offpath/data/models/app_user.dart';
import 'package:offpath/data/models/destination.dart';
import 'package:offpath/data/models/experience.dart';
import 'package:offpath/data/models/photo.dart';
import 'package:offpath/data/repositories/auth_repository.dart';
import 'package:offpath/data/repositories/destination_repository.dart';
import 'package:offpath/features/auth/auth_providers.dart';
import 'package:offpath/features/destination/destination_providers.dart';
import 'package:material_ui/material_ui.dart';

/// Stands in for Firebase Auth in tests: always signed in as [user] (or signed out).
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

const sampleDestination = Destination(
  id: 'narangala',
  name: 'Narangala',
  country: 'Sri Lanka',
  region: 'Uva Province',
  continent: 'Asia',
  lat: 7.018,
  lng: 81.063,
  categories: ['nature', 'adventure'],
  collections: ['remote-escapes'],
  featured: true,
  shortDescription: '',
  overview: '',
  whyHiddenGem: '',
  travelInfo: TravelInfo(
      bestTime: '', gettingThere: '', language: '', currency: ''),
  photo: Photo(
      url: 'https://example.com/narangala.jpg', author: 'Test', licence: ''),
);

/// Stands in for Firestore in tests: always returns [sampleDestination].
class FakeDestinationRepository implements DestinationRepository {
  @override
  Stream<List<Destination>> watchAll() => Stream.value([sampleDestination]);

  @override
  Stream<Destination?> watchById(String id) => Stream.value(sampleDestination);

  @override
  Stream<List<Experience>> watchExperiences(String destinationId) =>
      Stream.value(const []);
}

Future<void> pumpApp(WidgetTester tester, AppUser? user) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(user)),
        destinationRepositoryProvider
            .overrideWithValue(FakeDestinationRepository()),
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

  testWidgets('Signed-in user sees Discover and can switch tabs',
          (tester) async {
        await pumpApp(
          tester,
          const AppUser(uid: 'test', email: 'test@offpath.app', displayName: 'Test'),
        );

        expect(find.text('Featured hidden gems'), findsOneWidget);
        // The featured card is on screen (the "All" list below is built lazily,
        // only when scrolled into view).
        expect(find.text('Narangala'), findsWidgets);

        await tester.tap(find.text('Explore'));
        await tester.pumpAndSettle();
        expect(find.text('Explore'), findsWidgets); // app bar + tab label

        // Searching by country finds the destination…
        await tester.enterText(find.byType(TextField), 'sri lanka');
        await tester.pumpAndSettle();
        expect(find.text('1 destination'), findsOneWidget);

        // …and a search with no matches shows the empty state.
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        expect(find.text('No matches'), findsOneWidget);
      });
}