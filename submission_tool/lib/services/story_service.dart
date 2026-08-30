import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/story_cover_image.dart';

class StoryService {
  Future<List<StoryCoverImage>> fetchApprovedStoryCoverImages() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('status', isEqualTo: 'approved')
          .orderBy('timestamp', descending: true)
          .get();

      List<StoryCoverImage> covers = [];
      Set<String> processedStoryIds = {};

      for (var doc in snapshot.docs) {
        if (processedStoryIds.contains(doc.id)) continue;

        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String? path = data['coverImage']?['path'];
          
          if (path == null || path.trim().isEmpty) continue;
          
          String? resolvedUrl;
          if (path.startsWith('http://') || path.startsWith('https://')) {
            resolvedUrl = path;
          } else {
            resolvedUrl = await FirebaseStorage.instance.ref(path).getDownloadURL();
          }
          
          var cover = StoryCoverImage.fromFirestore(doc);
          covers.add(StoryCoverImage(
            storyId: cover.storyId,
            path: cover.path,
            resolvedUrl: resolvedUrl,
            name: cover.name,
            country: cover.country,
            countryISOCode: cover.countryISOCode,
            timestamp: cover.timestamp,
          ));
          processedStoryIds.add(doc.id);
        } catch (e) {
          debugPrint('Error resolving cover for ${doc.id}: $e');
        }
      }
      return covers;
    } catch (e) {
      debugPrint('Error fetching approved stories: $e');
      return [];
    }
  }
}
