# Logging Strategy

NotAgain uses a centralized logging system via the `logger` package, wrapped with `AppLogger` for consistency and customization.

## Overview

Logs provide visibility into app behavior for debugging and monitoring. The logging system supports:
- **Multiple log levels** (DEBUG, INFO, WARNING, ERROR)
- **Configurable output** (formatted console output)
- **Structured tags** (identify source of log messages)
- **Error context** (original exception and stack traces)

## Log Levels

| Level | Use Case | Example |
|-------|----------|---------|
| **DEBUG** | Low-level details, verbose information | `AppLogger.debug('Parsing response', tag: 'API')` |
| **INFO** | Important milestones, user actions | `AppLogger.info('User signed in', tag: 'Auth')` |
| **WARNING** | Unexpected but recoverable situations | `AppLogger.warning('Retry attempt 2/3', tag: 'Network')` |
| **ERROR** | Failures and exceptions | `AppLogger.error('Login failed', error: e, tag: 'Auth')` |

## Usage

### Basic Logging

```dart
import 'package:notagain/core/logging/app_logger.dart';

// Info message
AppLogger.info('User started signup', tag: 'SignupScreen');

// Warning with context
AppLogger.warning('Network timeout, retrying', tag: 'SupabaseService');

// Error with exception
try {
  await someAsyncCall();
} catch (e, st) {
  AppLogger.error(
    'API call failed',
    tag: 'SupabaseService',
    error: e,
    stackTrace: st,
  );
}

// Debug (only in debug builds)
AppLogger.debug('User credentials cached', tag: 'AuthProvider');
```

### Tag Naming Convention

Use the **class name** or **feature name** as the tag:
```dart
// Good
AppLogger.info('Logging in', tag: 'AuthProvider');
AppLogger.error('Failed to fetch rules', tag: 'SupabaseService');

// Avoid
AppLogger.info('Logging in', tag: 'screen');
AppLogger.error('Failed', tag: 'api');
```

## Configuration

### Initialize in `main.dart`

```dart
import 'package:notagain/core/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger (before other setup)
  AppLogger.init(minLevel: LogLevel.debug);
  
  // ... rest of setup
}
```

### Log Level by Build

Set log level based on build variant in `.env` or code:

```dart
// In main.dart
final logLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
AppLogger.init(minLevel: logLevel);
```

### Environment Variable

Optionally, use `.env` to configure:

```dotenv
# .env
LOG_LEVEL=debug  # debug, info, warning, error
```

Then in `main.dart`:
```dart
final logLevelStr = dotenv.env['LOG_LEVEL'] ?? 'info';
final logLevel = LogLevel.values.firstWhere(
  (e) => e.name == logLevelStr,
  orElse: () => LogLevel.info,
);
AppLogger.init(minLevel: logLevel);
```

## Best Practices

### 1. **Use Tags Consistently**
Always include a tag to identify the source:
```dart
AppLogger.info('User logged in', tag: 'AuthProvider');  // ✅ Good
AppLogger.info('User logged in');  // ❌ Less useful
```

### 2. **Log at Appropriate Levels**
- **DEBUG**: Detailed diagnostic info (function entry/exit, variable values)
- **INFO**: Confirmations of expected behavior (successful operations)
- **WARNING**: Unexpected but handled situations (retries, fallbacks)
- **ERROR**: Failures that need attention (exceptions, authentication failures)

```dart
// Good
AppLogger.debug('Checking cached user', tag: 'AuthProvider');
AppLogger.info('Cached user found, skipping network call', tag: 'AuthProvider');
AppLogger.warning('Cache expired, fetching fresh data', tag: 'AuthProvider');
AppLogger.error('Network request failed', error: e, tag: 'AuthProvider');

// Poor
AppLogger.info('Checking cache');  // Too vague
AppLogger.error('All operations');  // Not specific
```

### 3. **Include Context for Errors**
Always provide the original exception and stack trace:
```dart
// ✅ Good
try {
  await api.login();
} catch (e, st) {
  AppLogger.error('Login failed', error: e, stackTrace: st, tag: 'Auth');
}

// ❌ Not enough info
catch (e) {
  AppLogger.error('Login failed');
}
```

### 4. **Avoid Logging Sensitive Data**
Never log passwords, tokens, or PII:
```dart
// ✅ Safe
AppLogger.info('User signed up: $email', tag: 'Auth');

// ❌ Dangerous
AppLogger.info('Login with password: $password', tag: 'Auth');
AppLogger.info('Session token: $sessionToken', tag: 'Auth');
```

### 5. **Use for Important User Actions**
Log key events that help understand user flow:
```dart
// SignupScreen
AppLogger.info('User started signup', tag: 'SignupScreen');
AppLogger.info('User clicked terms checkbox', tag: 'SignupScreen');
AppLogger.info('User submitted signup form', tag: 'SignupScreen');

// AuthProvider
AppLogger.info('Signup successful for $email', tag: 'AuthProvider');
AppLogger.error('Signup failed', error: e, tag: 'AuthProvider');
```

## Viewing Logs

### In Console
Logs appear in the Flutter console with pretty formatting:
```
💡 [INFO] [AuthProvider] User signed in
❌ [ERROR] [SupabaseService] Login failed
```

### Future: File Logging
To add file logging for production:
1. Extend `AppLogger` with file output
2. Store logs in `getApplicationDocumentsDirectory()`
3. Rotate logs when size exceeds threshold

## Troubleshooting

### Logs Not Appearing
- Ensure `AppLogger.init()` is called in `main()` before other setup
- Check that `isInitialized` returns `true`
- Verify log level is set appropriately (DEBUG vs INFO)

### Too Many Logs
- Reduce log level to INFO or WARNING
- Verify no DEBUG statements in production code
- Remove old print statements that duplicate AppLogger calls

## Future Enhancements

- [ ] File output for production debugging
- [ ] Log rotation (max file size/age)
- [ ] Sentry integration for crash reporting
- [ ] Performance monitoring (API call timing)
- [ ] User session tracking (device ID, user ID)
