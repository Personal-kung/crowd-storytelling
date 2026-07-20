import 'dart:io';

import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  Future<File?> takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    final image = await _controller!.takePicture();

    return File(image.path);
  }

  Future<void> dispose() async {
    await _controller?.dispose();

    _controller = null;
  }
}
