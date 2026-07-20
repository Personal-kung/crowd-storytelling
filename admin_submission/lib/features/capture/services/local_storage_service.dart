import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Future<Directory> _getRootDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    final root = Directory(path.join(directory.path, 'submissions'));

    if (!await root.exists()) {
      await root.create(recursive: true);
    }

    return root;
  }

  Future<Directory> createSubmissionDirectory(String submissionId) async {
    final root = await _getRootDirectory();

    final submissionDirectory = Directory(path.join(root.path, submissionId));

    if (!await submissionDirectory.exists()) {
      await submissionDirectory.create(recursive: true);
    }

    return submissionDirectory;
  }

  Future<Directory> createImageDirectories(String submissionId) async {
    final submissionDirectory = await createSubmissionDirectory(submissionId);

    final original = Directory(path.join(submissionDirectory.path, 'original'));

    final processed = Directory(
      path.join(submissionDirectory.path, 'processed'),
    );

    await original.create(recursive: true);

    await processed.create(recursive: true);

    return submissionDirectory;
  }

  Future<String> saveImage(
    File image, {
    required String submissionId,
    required int pageNumber,
    required bool processed,
  }) async {
    final submissionDirectory = await createImageDirectories(submissionId);

    final folder = processed ? 'processed' : 'original';

    final filename =
        'page_${pageNumber.toString().padLeft(3, '0')}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final destination = File(
      path.join(submissionDirectory.path, folder, filename),
    );

    await image.copy(destination.path);

    return destination.path;
  }

  Future<void> deleteSubmission(String submissionId) async {
    final root = await _getRootDirectory();

    final directory = Directory(path.join(root.path, submissionId));

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<String> createSubmissionFolder(String submissionId) async {
    final directory = await createImageDirectories(submissionId);

    return directory.path;
  }
}
