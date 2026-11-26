import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/seed/destination_seeder.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_providers.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(user?.displayName ?? 'Traveller', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(user?.email ?? '', style: text.bodyMedium),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),

          // Developer tool: only exists in debug builds, never in the release APK.
          if (kDebugMode) ...[
            const SizedBox(height: 40),
            Text('Developer', style: text.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _seed(context, ref),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Seed destinations (admin)'),
            ),
          ],
        ],
      ),
    );
  }
}