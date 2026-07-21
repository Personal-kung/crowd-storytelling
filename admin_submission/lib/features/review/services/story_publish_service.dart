import 'package:cloud_firestore/cloud_firestore.dart';

import '../../capture/models/submission_session.dart';

class StoryPublishService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> publishStory({
    required SubmissionSession session,
    required String title,
    required String body,
    required String curatorNotes,
  }) async {
    // TODO:
    // Later migrate this direct write to:
    // Flutter -> publishStory callable -> Firestore
    //
    // This will allow:
    // - validation
    // - permissions
    // - translation trigger control
    // - cover image workflow

    await _firestore.collection('stories').add({
      'title': title.trim(),
      'body': body.trim(),
      'curatorNotes': curatorNotes.trim(),
      'contributorName': session.contributorName,
      'countryName': session.countryName,
      'countryCode': session.countryCode,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'approved',
    });
  }
}
