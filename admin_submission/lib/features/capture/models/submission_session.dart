import 'package:isar/isar.dart';

import 'captured_page.dart';

part 'submission_session.g.dart';

@collection
class SubmissionSession {
  Id id = Isar.autoIncrement;
  late String uuid;
  late String contributorName;
  late String countryName;
  late String countryCode;
  late DateTime createdAt;

  /// capturing
  /// readyToUpload
  /// uploading
  /// uploaded
  /// rejected
  late String status;

  @ignore
  List<CapturedPage> pages = [];

  SubmissionSession({
    required this.uuid,
    required this.contributorName,
    required this.countryName,
    required this.countryCode,
    required this.createdAt,
    required this.status,
    List<CapturedPage>? pages,
  }) {
    this.pages = pages ?? [];
  }

  int get pageCount => pages.length;
  SubmissionSession copyWith({
    String? uuid,
    String? contributorName,
    String? countryName,
    String? countryCode,
    DateTime? createdAt,
    String? status,
    List<CapturedPage>? pages,
  }) {
    return SubmissionSession(
      uuid: uuid ?? this.uuid,
      contributorName: contributorName ?? this.contributorName,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      pages: pages ?? this.pages,
    );
  }
}
