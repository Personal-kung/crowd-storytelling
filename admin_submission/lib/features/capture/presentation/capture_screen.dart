import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/camera_provider.dart';
import '../providers/capture_provider.dart';
import 'capture_review_screen.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final nameController = TextEditingController();
  final countryController = TextEditingController();

  bool cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await ref.read(cameraServiceProvider).initialize();

    if (!mounted) return;

    setState(() {
      cameraReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(cameraServiceProvider).controller;
    final session = ref.watch(captureControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Notebook')),

      body: session == null
          ? _buildStartForm()
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: double.infinity,
                  child: cameraReady && controller != null
                      ? _cameraPreview(controller)
                      : const Center(child: CircularProgressIndicator()),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: session.pages.length,
                    itemBuilder: (context, index) {
                      final page = session.pages[index];

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
                  ),
                ),

                Text(
                  'Pages captured: ${session.pages.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: _capture,
                      child: const Icon(Icons.camera),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CaptureReviewScreen(),
                          ),
                        );
                      },
                      child: const Text('Finish'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildStartForm() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Author name'),
          ),

          TextField(
            controller: countryController,
            decoration: const InputDecoration(labelText: 'Country'),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(captureControllerProvider.notifier)
                  .startSession(
                    name: nameController.text.trim(),
                    country: countryController.text.trim(),
                  );
            },
            child: const Text('Start Story'),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview(CameraController controller) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Future<void> _capture() async {
    await ref.read(captureControllerProvider.notifier).capturePage();
  }

  @override
  void dispose() {
    ref.read(cameraServiceProvider).dispose();

    nameController.dispose();
    countryController.dispose();

    super.dispose();
  }
}
