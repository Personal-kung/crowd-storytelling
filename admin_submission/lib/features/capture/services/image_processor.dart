import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageProcessor {
  static const int maxDimension = 2500;

  static const int quality = 90;

  Future<File> process(File original) async {
    final directory = await getTemporaryDirectory();

    final outputPath = path.join(
      directory.path,
      'processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      original.absolute.path,

      outputPath,

      minWidth: maxDimension,

      minHeight: maxDimension,

      quality: quality,

      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Image processing failed');
    }

    return File(result.path);
  }
}
