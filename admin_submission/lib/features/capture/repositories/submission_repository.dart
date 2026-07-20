import 'package:isar/isar.dart';

import '../../../core/database/isar_service.dart';

import '../models/submission_session.dart';
import '../models/captured_page.dart';

class SubmissionRepository {
  Future<Isar> get _db => IsarService.database;

  Future<void> saveSubmission(SubmissionSession submission) async {
    final db = await _db;

    await db.writeTxn(() async {
      await db.submissionSessions.put(submission);
    });
  }

  Future<void> savePage(CapturedPage page) async {
    final db = await _db;

    await db.writeTxn(() async {
      await db.capturedPages.put(page);
    });
  }

  Future<List<CapturedPage>> getPages(String submissionId) async {
    final db = await _db;

    return await db.capturedPages
        .filter()
        .submissionIdEqualTo(submissionId)
        .sortByPageNumber()
        .findAll();
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await _db;

    final submission = await db.submissionSessions.get(id);

    if (submission == null) {
      return;
    }

    submission.status = status;

    await db.writeTxn(() async {
      await db.submissionSessions.put(submission);
    });
  }

  Future<void> deleteSubmission(String submissionId) async {
    final db = await _db;

    await db.writeTxn(() async {
      final pages = await db.capturedPages
          .filter()
          .submissionIdEqualTo(submissionId)
          .findAll();

      for (final page in pages) {
        await db.capturedPages.delete(page.id);
      }

      final submission = await db.submissionSessions
          .filter()
          .uuidEqualTo(submissionId)
          .findFirst();

      if (submission != null) {
        await db.submissionSessions.delete(submission.id);
      }
    });
  }

  Future<void> deletePages(String submissionUuid) async {
    final db = await _db;

    final pages = await db.capturedPages
        .filter()
        .submissionIdEqualTo(submissionUuid)
        .findAll();

    await db.writeTxn(() async {
      await db.capturedPages.deleteAll(pages.map((e) => e.id).toList());
    });
  }
}
