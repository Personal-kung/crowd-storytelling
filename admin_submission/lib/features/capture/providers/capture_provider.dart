import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/captured_page.dart';
import '../models/local_submission_status.dart';
import '../models/submission_session.dart';

import '../services/camera_service.dart';
import '../services/image_processor.dart';
import '../services/local_storage_service.dart';

import '../repositories/submission_repository.dart';

import 'camera_provider.dart';
import 'image_processor_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SubmissionRepository();
});

final captureControllerProvider =
    StateNotifierProvider<CaptureController, SubmissionSession?>((ref) {
      return CaptureController(
        camera: ref.read(cameraServiceProvider),

        processor: ref.read(imageProcessorProvider),

        storage: ref.read(localStorageServiceProvider),

        repository: ref.read(submissionRepositoryProvider),
      );
    });

class CaptureController extends StateNotifier<SubmissionSession?> {
  final CameraService camera;

  final ImageProcessor processor;

  final LocalStorageService storage;

  final SubmissionRepository repository;

  CaptureController({
    required this.camera,
    required this.processor,
    required this.storage,
    required this.repository,
  }) : super(null);

  Future<void> rejectSubmission() async {
    await resetCaptureSession();
  }

  Future<void> startSession({
    required String name,

    required String country,
  }) async {
    final uuid = const Uuid().v4();

    final session = SubmissionSession(
      uuid: uuid,
      contributorName: name,
      countryName: country,
      countryCode: '',
      createdAt: DateTime.now(),
      status: LocalSubmissionStatus.capturing.name,
      pages: [],
    );

    state = session;

    await repository.saveSubmission(session);

    await storage.createSubmissionFolder(uuid);
  }

  Future<void> capturePage() async {
    final session = state;

    if (session == null) {
      throw Exception('No active submission');
    }

    final original = await camera.takePhoto();

    if (original == null) {
      return;
    }

    final processed = await processor.process(original);
    final pageNumber = session.pageCount + 1;
    final originalPath = await storage.saveImage(
      original,
      submissionId: session.uuid,
      pageNumber: pageNumber,
      processed: false,
    );

    final processedPath = await storage.saveImage(
      processed,
      submissionId: session.uuid,
      pageNumber: pageNumber,
      processed: true,
    );

    await repository.saveSubmission(session);

    state = session;
    final page = CapturedPage(
      submissionId: session.uuid,
      pageNumber: pageNumber,
      originalPath: originalPath,
      processedPath: processedPath,
    );

    await repository.savePage(page);

    final updatedSession = session.copyWith(pages: [...session.pages, page]);

    await repository.saveSubmission(updatedSession);

    state = updatedSession;
  }

  Future<void> finishCapture() async {
    await updateStatus(LocalSubmissionStatus.reviewing);
  }

  Future<void> updateStatus(LocalSubmissionStatus status) async {
    final session = state;

    if (session == null) {
      return;
    }

    session.status = status.name;

    await repository.saveSubmission(session);

    state = session;
  }

  Future<void> approveSubmission() async {
    await updateStatus(LocalSubmissionStatus.readyToUpload);
  }

  Future<void> resetCaptureSession() async {
    final session = state;

    if (session == null) {
      return;
    }

    await repository.deletePages(session.uuid);

    await storage.deleteSubmission(session.uuid);

    await storage.createSubmissionFolder(session.uuid);

    final resetSession = session.copyWith(
      pages: [],
      status: LocalSubmissionStatus.capturing.name,
    );

    state = resetSession;

    await repository.saveSubmission(resetSession);
  }
}
