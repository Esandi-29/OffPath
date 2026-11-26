import 'photo.dart';

/// A local experience or activity at a destination.
class Experience {
  const Experience({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.photo,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String category; // nature | culture | food | adventure
  final String duration;
  final String description;
  final Photo photo;
  final int sortOrder;

  factory Experience.fromMap(String id, Map<String, dynamic> map) => Experience(
    id: id,
    title: map['title'] as String? ?? '',
    category: map['category'] as String? ?? '',
    duration: map['duration'] as String? ?? '',
    description: map['description'] as String? ?? '',
    photo: Photo.fromMap(map['photo'] as Map<String, dynamic>?),
    sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
  );
}