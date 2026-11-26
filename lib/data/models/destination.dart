import 'photo.dart';

/// Practical travel information shown on Destination Details.
class TravelInfo {
  const TravelInfo({
    required this.bestTime,
    required this.gettingThere,
    required this.language,
    required this.currency,
  });

  final String bestTime;
  final String gettingThere;
  final String language;
  final String currency;

  factory TravelInfo.fromMap(Map<String, dynamic>? map) => TravelInfo(
    bestTime: map?['bestTime'] as String? ?? '',
    gettingThere: map?['gettingThere'] as String? ?? '',
    language: map?['language'] as String? ?? '',
    currency: map?['currency'] as String? ?? '',
  );
}

/// A curated hidden-gem destination (read-only in the app).
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.continent,
    required this.lat,
    required this.lng,
    required this.categories,
    required this.collections,
    required this.featured,
    required this.shortDescription,
    required this.overview,
    required this.whyHiddenGem,
    required this.travelInfo,
    required this.photo,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String country;
  final String region;
  final String continent;
  final double lat;
  final double lng;
  final List<String> categories; // e.g. ['nature', 'adventure']
  final List<String> collections; // e.g. ['hidden-villages']
  final bool featured;
  final String shortDescription;
  final String overview;
  final String whyHiddenGem;
  final TravelInfo travelInfo;
  final Photo photo;
  final int sortOrder;

  /// Builds a Destination from a Firestore document's data. Missing or
  /// wrongly typed fields fall back to safe defaults instead of crashing.
  factory Destination.fromMap(String id, Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;
    return Destination(
      id: id,
      name: map['name'] as String? ?? 'Unnamed destination',
      country: map['country'] as String? ?? '',
      region: map['region'] as String? ?? '',
      continent: map['continent'] as String? ?? '',
      lat: (location?['lat'] as num?)?.toDouble() ?? 0,
      lng: (location?['lng'] as num?)?.toDouble() ?? 0,
      categories: _stringList(map['categories']),
      collections: _stringList(map['collections']),
      featured: map['featured'] as bool? ?? false,
      shortDescription: map['shortDescription'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      whyHiddenGem: map['whyHiddenGem'] as String? ?? '',
      travelInfo: TravelInfo.fromMap(map['travelInfo'] as Map<String, dynamic>?),
      photo: Photo.fromMap(map['photo'] as Map<String, dynamic>?),
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static List<String> _stringList(Object? value) =>
      (value as List?)?.whereType<String>().toList() ?? const [];
}