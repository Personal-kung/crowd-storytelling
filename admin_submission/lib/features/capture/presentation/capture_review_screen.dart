import 'dart:io';

import 'package:admin_submission/features/ocr/services/ocr_test_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/capture_provider.dart';
// import '../repositories/submission_repository.dart';
// import 'capture_screen.dart';

class CaptureReviewScreen extends ConsumerStatefulWidget {
  const CaptureReviewScreen({super.key});

  @override
  ConsumerState<CaptureReviewScreen> createState() =>
      _CaptureReviewScreenState();
}

class _CaptureReviewScreenState extends ConsumerState<CaptureReviewScreen> {
  List<dynamic> _pages = [];
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(captureControllerProvider);
    debugPrint('REVIEW SESSION UUID: ${session?.uuid}');

    debugPrint('REVIEW PAGE COUNT: ${session?.pages.length}');

    final repository = ref.read(submissionRepositoryProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text('No submission found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Story')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.contributorName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                Text(session.countryName),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder(
              future: repository.getPages(session.uuid),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pages = snapshot.data!;
                _pages = pages;

                return ListView.builder(
                  itemCount: pages.length,

                  itemBuilder: (context, index) {
                    final page = pages[index];
                    debugPrint('REVIEW PAGE PATH: ${page.processedPath}');

                    return Card(
                      margin: const EdgeInsets.all(12),

                      child: Column(
                        children: [
                          Text('Page ${page.pageNumber}'),

                          Image.file(
                            File(page.processedPath),
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  child: const Text('Reject'),

                  onPressed: () async {
                    await ref
                        .read(captureControllerProvider.notifier)
                        .rejectSubmission();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),

                ElevatedButton(
                  child: const Text('send to OCR'),

                  onPressed: () async {
                    if (_pages.isEmpty) {
                      debugPrint('No pages available for OCR');
                      return;
                    }

                    final images = _pages
                        .map((page) => File(page.processedPath))
                        .toList();

                    await OcrTestService().sendImages(images);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
