import 'package:flutter/foundation.dart';

class BrowserLocaleService {
  String getBrowserLanguage() {
    try {
      if (kIsWeb) {
        // PlatformDispatcher gets the browser's locale in Flutter Web safely
        return PlatformDispatcher.instance.locale.toLanguageTag();
      } else {
        return PlatformDispatcher.instance.locale.toLanguageTag();
      }
    } catch (e) {
      return 'en';
    }
  }
}
