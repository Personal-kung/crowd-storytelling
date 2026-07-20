import 'package:isar/isar.dart';

part 'captured_page.g.dart';

@collection
class CapturedPage {
  Id id = Isar.autoIncrement;

  late String submissionId;

  late int pageNumber;

  late String originalPath;

  late String processedPath;

  CapturedPage({
    required this.submissionId,

    required this.pageNumber,

    required this.originalPath,

    required this.processedPath,
  });
}
