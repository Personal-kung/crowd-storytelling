import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();

  ref.onDispose(service.dispose);

  return service;
});
