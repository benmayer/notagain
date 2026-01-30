/// App theming configuration
/// 
/// Provides light and dark theme data for the Notagain app using Material Design 3 and Forui.
/// Applies the primary brand color (#1fbacb) across the theme and ensures
/// consistent styling across light and dark modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary.withValues(alpha: 0.7),
        surface: AppColors.lightSurface,
        surfaceDim: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnBackground,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary.withValues(alpha: 0.7),
        surface: AppColors.darkSurface,
        surfaceDim: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnBackground,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Forui light theme
  /// Configured with the Notagain brand color and light mode styling
  static FThemeData forLightTheme() {
    return FThemeData(
      colors: FColors(
        brightness: Brightness.light,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        primary: AppColors.primary,
        background: AppColors.lightBackground,
        foreground: AppColors.lightOnBackground,
        barrier: Colors.black26,
        border: AppColors.lightBorder,
        muted: AppColors.gray200,
        mutedForeground: AppColors.gray600,
        secondary: AppColors.primary.withValues(alpha: 0.7),
        secondaryForeground: Colors.white,
        destructive: AppColors.error,
        destructiveForeground: Colors.white,
        error: AppColors.error,
        errorForeground: Colors.white,
        primaryForeground: Colors.white,
      ),
    );
  }

  /// Forui dark theme
  /// Configured with the Notagain brand color and dark mode styling
  static FThemeData forDarkTheme() {
    return FThemeData(
      colors: FColors(
        brightness: Brightness.dark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        primary: AppColors.primary,
        background: AppColors.darkBackground,
        foreground: AppColors.darkOnBackground,
        barrier: Colors.black54,
        border: AppColors.darkBorder,
        muted: AppColors.gray700,
        mutedForeground: AppColors.gray400,
        secondary: AppColors.primary.withValues(alpha: 0.7),
        secondaryForeground: Colors.white,
        destructive: AppColors.error,
        destructiveForeground: Colors.white,
        error: AppColors.error,
        errorForeground: Colors.white,
        primaryForeground: Colors.white,
      ),
    );
  }
}
