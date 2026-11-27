import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/models/app_user.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/destination/destination_details_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/trips/my_trips_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// The app's router. It watches the signed-in state and redirects:
/// signed out -> Login, signed in -> away from Login/Register.
final routerProvider = Provider<GoRouter>((ref) {
  // Bridge between Riverpod and go_router: when auth changes, the router
  // re-runs `redirect`.
  final authState = ValueNotifier<AsyncValue<AppUser?>>(const AsyncLoading());
  ref.onDispose(authState.dispose);
  ref.listen(
    authStateProvider,
        (previous, next) => authState.value = next,
    fireImmediately: true,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authState,
    redirect: (context, state) {
      final auth = authState.value;
      final location = state.matchedLocation;
      final onAuthPage = location == '/login' || location == '/register';

      // Still finding out who is signed in: wait on the splash screen.
      if (!auth.hasValue && !auth.hasError) {
        return location == '/splash' ? null : '/splash';
      }

      final signedIn = auth.value != null;
      if (!signedIn) return onAuthPage ? null : '/login';
      if (onAuthPage || location == '/splash') return '/discover';
      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // The 4 tabs. Each branch keeps its own history and scroll position.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // Pushed full-screen over the bottom bar.
      GoRoute(
        path: '/destination/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DestinationDetailsScreen(
          destinationId: state.pathParameters['id']!,
        ),
      ),

      // My trips, opened from Profile (also full-screen).
      GoRoute(
        path: '/trips',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyTripsScreen(),
      ),
    ],
  );
});