import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../features/destination/destination_details_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/saved/saved_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/discover',
  routes: [
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
  ],
);