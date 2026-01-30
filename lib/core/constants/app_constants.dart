/// Application Constants
///
/// Centralized configuration for app-level constants including timeouts,
/// UI dimensions, validation rules, API settings, and feature flags.
///
/// These constants are separate from the theme system and represent
/// behavioral configuration rather than design tokens.
library;

class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ============================================================================
  // TIMEOUTS & DELAYS
  // ============================================================================

  /// Maximum duration for login/signup operations
  static const Duration loginTimeout = Duration(seconds: 30);

  /// Maximum duration for general network requests
  static const Duration networkTimeout = Duration(seconds: 15);

  /// How long a toast notification stays visible
  static const Duration toastDuration = Duration(seconds: 4);

  /// Minimum duration before allowing retry after failure
  static const Duration retryDelay = Duration(milliseconds: 500);

  /// Debounce duration for user input (search, form validation)
  static const Duration debounceDelay = Duration(milliseconds: 300);

  // ============================================================================
  // UI DIMENSIONS
  // ============================================================================

  /// Standard horizontal padding for screens
  static const double standardPadding = 16.0;

  /// Extra small gap for subtle spacing
  static const double extraSmallGap = 8.0;

  /// Small gap for minor spacing
  static const double smallGap = 12.0;

  /// Standard gap between vertical elements
  static const double standardGap = 16.0;

  /// Large gap between sections (e.g., buttons, form sections)
  static const double largeGap = 24.0;

  /// Minimum width for buttons (mainly used in forms)
  static const double minButtonWidth = 300.0;

  /// Maximum width for form containers (improves UX on wide screens)
  static const double maxFormWidth = 500.0;

  /// Minimum width for toast notifications
  static const double toastMinWidth = 400.0;

  /// Standard border radius for cards and inputs
  static const double borderRadius = 8.0;

  /// Standard icon size
  static const double iconSize = 24.0;

  /// Large icon size (headers, featured elements)
  static const double iconSizeLarge = 32.0;

  /// Small icon size (secondary, decorative)
  static const double iconSizeSmall = 16.0;

  // ============================================================================
  // VALIDATION RULES
  // ============================================================================

  /// Minimum password length
  static const int minPasswordLength = 6;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Minimum user name length
  static const int minNameLength = 2;

  /// Maximum user name length
  static const int maxNameLength = 100;

  // ============================================================================
  // API & NETWORK SETTINGS
  // ============================================================================

  /// Maximum number of retry attempts for failed requests
  static const int maxRetries = 3;

  /// Default page size for paginated API responses
  static const int apiPageSize = 50;

  /// Maximum number of blocking rules per user
  static const int maxBlockingRules = 100;

  /// Maximum number of app usage records to fetch in single query
  static const int maxAnalyticsRecords = 365; // One year of daily records

  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================

  /// Enable analytics tracking (Firebase, Sentry, etc.)
  static const bool enableAnalytics = true;

  /// Enable crash reporting
  static const bool enableCrashReporting = true;

  /// Enable offline mode (cached data, local first)
  static const bool enableOfflineMode = false;

  /// Enable experimental features
  static const bool enableExperimentalFeatures = false;

  // ============================================================================
  // STRINGS & LABELS
  // ============================================================================

  /// Default empty state message
  static const String defaultEmptyMessage = 'No data available';

  /// Default error message for unhandled exceptions
  static const String defaultErrorMessage = 'Something went wrong.';
}
