import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class OcrTestService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> test() async {
    final callable = _functions.httpsCallable('helloWorld');

    final result = await callable();

    debugPrint(result.data);
  }
}
