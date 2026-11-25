import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/category_chip.dart';
import '../../core/widgets/collection_tile.dart';
import '../../core/widgets/destination_card.dart';
import '../../core/widgets/section_header.dart';

/// Temporary test version of Discover (2.2): shows the custom components
/// with sample content. Real data from Firestore replaces this in 2.5.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'all';
  final Set<String> _saved = {};

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

  void _toggleSaved(String id) {
    setState(() {
      if (!_saved.remove(id)) _saved.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView(
        // No side padding here, so horizontal rows can run edge to edge.
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: _pagePadding,
            child: SectionHeader(title: 'Categories'),
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
                  selected: _selectedCategory == id,
                  onTap: () => setState(() => _selectedCategory = id),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: _pagePadding,
            child: SectionHeader(title: 'Featured hidden gems'),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: _pagePadding,
            child: Column(
              children: [
                DestinationCard(
                  name: 'Narangala',
                  country: 'Sri Lanka',
                  imageUrl:
                  'https://commons.wikimedia.org/wiki/Special:FilePath/Hikers_in_Narangala_Sri_Lanka.jpg?width=1280',
                  showHiddenGemBadge: true,
                  isSaved: _saved.contains('narangala'),
                  onSaveToggle: () => _toggleSaved('narangala'),
                  onTap: () => context.push('/destination/narangala'),
                ),
                const SizedBox(height: 16),
                DestinationCard(
                  name: 'Lake Bohinj',
                  country: 'Slovenia',
                  imageUrl:
                  'https://commons.wikimedia.org/wiki/Special:FilePath/Bohinjsko_jezero_2.jpg?width=1280',
                  isSaved: _saved.contains('lake-bohinj'),
                  onSaveToggle: () => _toggleSaved('lake-bohinj'),
                  onTap: () => context.push('/destination/lake-bohinj'),
                ),
              ],
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
                return CollectionTile(label: label, icon: icon, onTap: () {});
              },
            ),
          ),
          const SizedBox(height: 24),
          // Temporary: preview of the themed buttons (removed in 2.5).
          Padding(
            padding: _pagePadding,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Get started'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add activity'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}