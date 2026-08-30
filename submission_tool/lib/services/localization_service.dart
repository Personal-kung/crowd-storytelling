import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'browser_locale_service.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, dynamic>? _translations;
  String _currentLocale = 'en';

  Future<void> init() async {
    try {
      String jsonString = await rootBundle.loadString('assets/translations/ui.json');
      _translations = jsonDecode(jsonString);
      
      String browserLocale = BrowserLocaleService().getBrowserLanguage();
      _currentLocale = _resolveLocale(browserLocale);
    } catch (e) {
      debugPrint('Error loading translations: $e');
      _translations = {};
    }
  }

  String _resolveLocale(String browserLocale) {
    if (_translations == null || _translations!.isEmpty) return 'en';
    
    // Attempt to match an actual key just to check if locale exists in at least one entry
    // A better approach is checking if the locale exists in the app.title entry
    var testEntry = _translations!['app.title'];
    if (testEntry is Map) {
      if (testEntry.containsKey(browserLocale)) return browserLocale;
      
      String langOnly = browserLocale.split('-')[0];
      if (testEntry.containsKey(langOnly)) return langOnly;
    }
    
    return 'en';
  }

  String t(String key, {Map<String, String>? params}) {
    if (_translations == null) return key;
    
    var entry = _translations![key];
    if (entry == null || entry is! Map) return key;

    String? text = entry[_currentLocale] ?? entry[_currentLocale.split('-')[0]] ?? entry['en'];
    
    if (text == null) return key;

    if (params != null) {
      params.forEach((k, v) {
        text = text!.replaceAll('{$k}', v);
      });
    }

    return text!;
  }
}
