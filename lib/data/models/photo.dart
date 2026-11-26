/// A photo with its credit (all OffPath photos come from Wikimedia Commons).
class Photo {
  const Photo({
    required this.url,
    required this.author,
    required this.licence,
    this.file = '',
  });

  final String url;
  final String author;
  final String licence;
  final String file;

  /// Shown under images, as the photo licences require.
  String get credit => 'Photo: $author · $licence';

  factory Photo.fromMap(Map<String, dynamic>? map) => Photo(
    url: map?['url'] as String? ?? '',
    author: map?['author'] as String? ?? 'Unknown',
    licence: map?['licence'] as String? ?? '',
    file: map?['file'] as String? ?? '',
  );
}