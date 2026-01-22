/// Theme provider using Provider package and Forui themes
/// 
/// Manages light/dark mode theme switching using Forui's built-in FThemes.
/// Persists theme preference using shared_preferences.
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  late FThemeData _currentTheme;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  FThemeData get currentTheme => _currentTheme;

  /// Initialize theme provider and load saved preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _currentTheme = _isDarkMode ? FThemes.slate.dark : FThemes.slate.light;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? FThemes.slate.dark : FThemes.slate.light;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// Set theme explicitly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _currentTheme = isDark ? FThemes.slate.dark : FThemes.slate.light;
      await _prefs.setBool('isDarkMode', isDark);
      notifyListeners();
    }
  }
}
