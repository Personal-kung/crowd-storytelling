import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_processor_provider.dart';
import '../providers/camera_provider.dart';

class CameraTestScreen extends ConsumerStatefulWidget {
  const CameraTestScreen({super.key});

  @override
  ConsumerState<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends ConsumerState<CameraTestScreen> {
  bool ready = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    await ref.read(cameraServiceProvider).initialize();

    setState(() {
      ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(cameraServiceProvider).controller;

    if (!ready || controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CameraPreview(controller),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),

        onPressed: () async {
          final file = await ref.read(cameraServiceProvider).takePhoto();

          if (file != null) {
            final processed = await ref
                .read(imageProcessorProvider)
                .process(file);

            debugPrint("Original: ${file.path}");

            debugPrint("Processed: ${processed.path}");
          }
          debugPrint(file?.path);
        },
      ),
    );
  }
}
