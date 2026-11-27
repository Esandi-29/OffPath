import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/category_chip.dart';
import '../../core/widgets/destination_card.dart';
import '../../core/widgets/message_view.dart';
import '../destination/destination_providers.dart';
import 'destination_search.dart';

/// Search and filter all destinations.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'all';

  static const _categories = [
    ('all', 'All'),
    ('nature', 'Nature'),
    ('culture', 'Culture'),
    ('food', 'Food'),
    ('adventure', 'Adventure'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search places, countries, cultures…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 12),
          Expanded(
            child: destinations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => MessageView(
                icon: Icons.cloud_off_outlined,
                title: "Couldn't load destinations",
                message: 'Check your connection and try again.',
                actionLabel: 'Try again',
                onAction: () => ref.invalidate(destinationsProvider),
              ),
              data: (all) {
                final results = filterDestinations(
                  all,
                  query: _query,
                  category: _category,
                );
                if (results.isEmpty) {
                  return MessageView(
                    icon: Icons.search_off,
                    title: 'No matches',
                    message: _query.isEmpty
                        ? 'No destinations in this category yet.'
                        : 'Nothing found for "${_query.trim()}". '
                        'Try a country, region or category.',
                    actionLabel: _query.isEmpty ? null : 'Clear search',
                    onAction: _clearSearch,
                  );
                }
                return ListView.separated(
                  // Swiping the list hides the keyboard.
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: results.length + 1,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final count = results.length;
                      return Text(
                        count == 1 ? '1 destination' : '$count destinations',
                        style: Theme.of(context).textTheme.labelLarge,
                      );
                    }
                    final destination = results[index - 1];
                    return DestinationCard(
                      name: destination.name,
                      country: destination.country,
                      imageUrl: destination.photo.url,
                      height: 180,
                      showHiddenGemBadge: destination.featured,
                      onTap: () =>
                          context.push('/destination/${destination.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}