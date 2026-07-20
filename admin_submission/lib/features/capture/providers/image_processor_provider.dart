import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/image_processor.dart';

final imageProcessorProvider = Provider<ImageProcessor>((ref) {
  return ImageProcessor();
});
