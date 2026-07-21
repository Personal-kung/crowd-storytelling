import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class OcrTestService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> sendImages(List<File> images) async {
    final encodedImages = <String>[];

    for (final image in images) {
      final bytes = await image.readAsBytes();
      encodedImages.add(base64Encode(bytes));
    }

    final callable = _functions.httpsCallable('processStoryOCR');

    final result = await callable.call<Map<String, dynamic>>({
      'images': encodedImages,
    });

    final data = Map<String, dynamic>.from(result.data!);

    debugPrint('OCR RESPONSE: $data');

    return data;
  }
}
