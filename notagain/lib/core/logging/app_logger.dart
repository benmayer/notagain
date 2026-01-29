/// Application Logger
///
/// Centralized logging abstraction using the `logger` package.
/// Provides a simple API for structured logging across the app.
///
/// Usage:
/// ```dart
/// AppLogger.info('User signed in', tag: 'AuthProvider');
/// AppLogger.error('Login failed', error: e, stackTrace: st);
/// ```
library;

import 'package:logger/logger.dart';

/// Enumeration of log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Application-wide logger
///
/// Wraps the `logger` package to provide a consistent API
/// and configurable output formatting.
class AppLogger {
  static late Logger _logger;
  static LogLevel _minLevel = LogLevel.debug;

  /// Initialize the logger
  ///
  /// Call this in `main()` before running the app.
  /// [minLevel] determines which messages are logged (default: debug in dev, info in prod)
  static void init({LogLevel minLevel = LogLevel.debug}) {
    _minLevel = minLevel;
    _logger = Logger(
      printer: SimplePrinter(colors: true),
      level: _logLevelToLoggerLevel(minLevel),
    );
  }

  /// Log a debug message
  static void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (_shouldLog(LogLevel.debug)) {
      _logger.d(
        _formatMessage(message, tag),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log an info message
  static void info(
    String message, {
    String? tag,
  }) {
    if (_shouldLog(LogLevel.info)) {
      _logger.i(_formatMessage(message, tag));
    }
  }

  /// Log a warning message
  static void warning(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (_shouldLog(LogLevel.warning)) {
      _logger.w(
        _formatMessage(message, tag),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log an error message
  static void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Check if logger is initialized
  static bool get isInitialized => true;

  /// Format message with optional tag
  static String _formatMessage(String message, String? tag) {
    if (tag != null) {
      return '[$tag] $message';
    }
    return message;
  }

  /// Check if a message at this level should be logged
  static bool _shouldLog(LogLevel level) {
    return level.index >= _minLevel.index;
  }

  /// Convert AppLogger LogLevel to logger package Level
  static Level _logLevelToLoggerLevel(LogLevel level) {
    return switch (level) {
      LogLevel.debug => Level.debug,
      LogLevel.info => Level.info,
      LogLevel.warning => Level.warning,
      LogLevel.error => Level.error,
    };
  }
}
