import '../../data/models/destination.dart';

/// Filters destinations by a search query and a category.
/// Matches name, country, region, continent and category, ignoring case and
/// accents (so "lencois" finds "Lençóis"). Kept separate from the screen so
/// it can be unit tested.
List<Destination> filterDestinations(
    List<Destination> all, {
      String query = '',
      String category = 'all',
    }) {
  final q = foldAccents(query.trim().toLowerCase());

  return all.where((destination) {
    final inCategory =
        category == 'all' || destination.categories.contains(category);
    if (!inCategory) return false;
    if (q.isEmpty) return true;

    final searchable = foldAccents([
      destination.name,
      destination.country,
      destination.region,
      destination.continent,
      ...destination.categories,
    ].join(' ').toLowerCase());
    return searchable.contains(q);
  }).toList();
}

/// Replaces common accented letters with plain ones (ç → c, ö → o, ë → e…).
String foldAccents(String input) {
  const from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyy';
  final buffer = StringBuffer();
  for (final char in input.split('')) {
    final index = from.indexOf(char);
    buffer.write(index == -1 ? char : to[index]);
  }
  return buffer.toString();
}