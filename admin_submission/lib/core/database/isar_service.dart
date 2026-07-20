import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/capture/models/captured_page.dart';
import '../../features/capture/models/submission_session.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> get database async {
    if (_instance != null) {
      return _instance!;
    }

    final directory = await getApplicationDocumentsDirectory();

    _instance = await Isar.open([
      SubmissionSessionSchema,

      CapturedPageSchema,
    ], directory: directory.path);

    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();

    _instance = null;
  }
}
