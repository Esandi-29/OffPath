import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/seed/destination_seeder.dart';
import '../../data/seed/sample_trips.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_providers.dart';
import '../destination/destination_providers.dart';
import '../trips/trip_format.dart';
import '../trips/trip_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _seed(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await ref.read(destinationSeederProvider).seed();
      messenger.showSnackBar(
        SnackBar(content: Text('Seeded $count destinations to Firestore.')),
      );
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Seeding failed: ${e.code}')),
      );
    }
  }

  Future<void> _addSampleTrips(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    final destinations = await ref.read(destinationsProvider.future);
    final count =
    addSampleTrips(ref.read(tripRepositoryProvider), uid, destinations);
    messenger.showSnackBar(
      SnackBar(content: Text('Added $count sample trips.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final trips = ref.watch(tripsProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(user?.displayName ?? 'Traveller', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(user?.email ?? '', style: text.bodyMedium),
          const SizedBox(height: 24),

          // My trips row (the full Profile hub design comes in 3.4).
          Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.map_outlined, color: scheme.primary),
              ),
              title: const Text('My trips'),
              subtitle: Text(
                trips.when(
                  data: (all) => tripSummary(all, DateTime.now()),
                  loading: () => 'Loading…',
                  error: (error, stackTrace) => 'Your planned and past trips',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/trips'),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),

          // Developer tools: only exist in debug builds, never in the release APK.
          if (kDebugMode) ...[
            const SizedBox(height: 40),
            Text('Developer', style: text.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _seed(context, ref),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Seed destinations (admin)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _addSampleTrips(context, ref),
              icon: const Icon(Icons.luggage_outlined),
              label: const Text('Add sample trips'),
            ),
          ],
        ],
      ),
    );
  }
}