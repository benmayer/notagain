/// Theme provider using Provider package
/// 
/// Manages light/dark mode theme switching for the app.
/// Persists theme preference using shared_preferences.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  /// Initialize theme provider and load saved preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// Set theme explicitly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _prefs.setBool('isDarkMode', _isDarkMode);
      notifyListeners();
    }
  }
}
