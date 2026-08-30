import 'package:cloud_firestore/cloud_firestore.dart';

class StoryCoverImage {
  final String storyId;
  final String path;
  final String? resolvedUrl;
  final String name;
  final String country;
  final String countryISOCode;
  final Timestamp? timestamp;

  StoryCoverImage({
    required this.storyId,
    required this.path,
    this.resolvedUrl,
    required this.name,
    required this.country,
    required this.countryISOCode,
    this.timestamp,
  });

  factory StoryCoverImage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoryCoverImage(
      storyId: doc.id,
      path: data['coverImage']?['path'] ?? '',
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      countryISOCode: data['countryISOCode'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }
}
