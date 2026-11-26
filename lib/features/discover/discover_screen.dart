import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/category_chip.dart';
import '../../core/widgets/collection_tile.dart';
import '../../core/widgets/destination_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/destination.dart';
import '../auth/auth_providers.dart';
import '../destination/destination_providers.dart';

/// Home screen: greeting, search entry, featured gems, collections and the
/// full list filtered by category. Data comes live from Firestore.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _category = 'all';

  static const _pagePadding = EdgeInsets.symmetric(horizontal: 16);

  static const _categories = [
    ('all', 'All'),
    ('nature', 'Nature'),
    ('culture', 'Culture'),
    ('food', 'Food'),
    ('adventure', 'Adventure'),
  ];

  static const _collections = [
    ('Underrated nature', Icons.forest_outlined),
    ('Remote escapes', Icons.terrain_outlined),
    ('Cultural heritage', Icons.account_balance_outlined),
    ('Hidden villages', Icons.holiday_village_outlined),
    ('Local food', Icons.restaurant_outlined),
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void _open(Destination destination) =>
      context.push('/destination/${destination.id}');

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);
    final displayName = ref.watch(authStateProvider).value?.displayName;
    final firstName = (displayName == null || displayName.isEmpty)
        ? 'Traveller'
        : displayName.split(' ').first;

    return Scaffold(
      body: SafeArea(
        // One widget per state: loading, error, or data.
        child: destinations.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _MessageView(
            icon: Icons.cloud_off_outlined,
            title: "Couldn't load destinations",
            message: 'Check your connection and try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(destinationsProvider),
          ),
          data: (all) {
            if (all.isEmpty) {
              return const _MessageView(
                icon: Icons.travel_explore,
                title: 'No destinations yet',
                message: 'New hidden gems will appear here soon.',
              );
            }
            final featured = all.where((d) => d.featured).toList();
            final filtered = _category == 'all'
                ? all
                : all.where((d) => d.categories.contains(_category)).toList();
            return _buildContent(context, firstName, featured, filtered);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      String firstName,
      List<Destination> featured,
      List<Destination> filtered,
      ) {
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: _pagePadding,
          child: Text('${_greeting()},\n$firstName',
              style: text.headlineMedium),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: _pagePadding,
          child: _SearchBar(onTap: () => context.go('/explore')),
        ),
        const SizedBox(height: 24),

        // Featured hidden gems: sideways-scrolling large cards.
        const Padding(
          padding: _pagePadding,
          child: SectionHeader(title: 'Featured hidden gems'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: _pagePadding,
            itemCount: featured.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final destination = featured[index];
              return SizedBox(
                width: 280,
                child: DestinationCard(
                  name: destination.name,
                  country: destination.country,
                  imageUrl: destination.photo.url,
                  height: 220,
                  showHiddenGemBadge: true,
                  onTap: () => _open(destination),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        const Padding(
          padding: _pagePadding,
          child: SectionHeader(title: 'Explore collections'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: _pagePadding,
            itemCount: _collections.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final (label, icon) = _collections[index];
              return CollectionTile(label: label, icon: icon);
            },
          ),
        ),
        const SizedBox(height: 24),

        // All destinations, filtered by category.
        const Padding(
          padding: _pagePadding,
          child: SectionHeader(title: 'All hidden gems'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: _pagePadding,
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (id, label) = _categories[index];
              return CategoryChip(
                label: label,
                categoryId: id,
                selected: _category == id,
                onTap: () => setState(() => _category = id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: _pagePadding,
          child: Column(
            children: [
              for (final destination in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DestinationCard(
                    name: destination.name,
                    country: destination.country,
                    imageUrl: destination.photo.url,
                    onTap: () => _open(destination),
                  ),
                ),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No destinations in this category yet.'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tappable search bar that opens the Explore tab.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(
                'Search destinations…',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered icon + message, used for the error and empty states.
class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}