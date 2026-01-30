/// Settings Provider
/// 
/// Manages user preferences and settings persistence
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _language = 'en';
  
  // Getters
  String get language => _language;

  /// Initialize settings provider
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _language = _prefs.getString('app_language') ?? 'en';
    notifyListeners();
  }

  /// Set app language
  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    await _prefs.setString('app_language', langCode);
    notifyListeners();
  }

  /// Get available languages
  List<MapEntry<String, String>> get availableLanguages => [
    const MapEntry('en', 'English'),
    const MapEntry('es', 'Español'),
    const MapEntry('fr', 'Français'),
    const MapEntry('de', 'Deutsch'),
  ];
}
