# NotAgain — Template Foundation Improvements

## Overview
NotAgain is being built as a **reusable Flutter template** for screen time management apps. This document tracks improvements to solidify the foundation for future projects using this as a starting point.

Current state: ✅ Secure, well-architected, tested for auth flow. Ready for template hardening.

---

## Priority Improvements

### 1. Testing Infrastructure (HIGH PRIORITY)
**Why**: Templates need test scaffolding so future projects don't start from zero.

**Scope** (simplified for template stage):
- Add `test/helpers/test_helpers.dart` - Mock providers, mock Supabase client, test utilities
- Add `test/unit/providers/auth_provider_test.dart` - Auth flow (signup, login, logout)
- Add `test/unit/services/supabase_service_test.dart` - Service methods with mocked client
- Add `test/widget/screens/login_screen_test.dart` - UI interactions (form validation, button taps)
- Add GitHub Actions workflow `.github/workflows/test.yml` - Run `flutter analyze && flutter test`
- Update `pubspec.yaml` with test dependencies: `mockito`, `mocktail`

**Impact**: Future projects get a working test suite to extend.
**Status**: Not started
**Effort**: Medium (2-3 hours)

---

### 2. Logger Abstraction (MEDIUM PRIORITY)
**Why**: Current `debugPrint()` with emoji is dev-only. Production apps need structured logging.

**Actions**:
- Create `lib/core/logging/app_logger.dart` - Abstraction for different log levels (debug, info, warn, error)
- Support multiple outputs: console (dev), file (production), external service (Sentry, future)
- Centralized formatting with context (timestamp, level, module)
- Replace all `debugPrint()` calls with `AppLogger.debug()`, `AppLogger.info()`, etc.
- Document log levels in `docs/LOGGING.md`

**Pattern**:
```dart
AppLogger.info('User signed in', tag: 'AuthProvider');
AppLogger.error('Network request failed', error: e, stackTrace: st);
```

**Status**: Not started
**Effort**: Small (1.5 hours)

---

### 3. Constants & Config Management (MEDIUM PRIORITY)
**Why**: Scattered constants and hardcoded values make maintenance harder.

**Actions**:
- Create `lib/core/constants/app_constants.dart` - Timeouts, limits, API settings, strings
- Create `lib/core/config/app_config.dart` - Build-specific config (dev, staging, production)
- Move hardcoded values (toast duration, button sizes, API timeouts) to constants
- Document which constants are environment-specific
- Add to `.env` for runtime override where needed

**Constants to capture**:
```dart
// Timeouts
static const Duration loginTimeout = Duration(seconds: 30);
static const Duration networkTimeout = Duration(seconds: 15);

// UI
static const Duration toastDuration = Duration(seconds: 4);
static const double minButtonWidth = 300;

// Validation
static const int minPasswordLength = 6;
static const int maxPasswordLength = 128;

// API
static const String supabaseApiPath = '/auth/v1';
static const int maxRetries = 3;
```

**Status**: Not started
**Effort**: Small (1 hour)

---

### 4. Routing Guards & Middleware (MEDIUM PRIORITY)
**Why**: Current routing handles auth, but not permissions or feature gates.

**Actions**:
- Create `lib/routing/route_guards.dart` - Guards for auth, permissions, feature flags
- Update `lib/routing/app_router.dart` to use guards on protected routes
- Implement permission checks (e.g., "Screen Time access required")
- Implement feature flag checks
- Redirect to permission request or feature unavailable screens
- Document guard patterns in `docs/ROUTING.md`

**Pattern**:
```dart
GoRoute(
  path: '/blocking-rules',
  redirect: _requiresScreenTimePermission,
  builder: (context, state) => StartScreen(),
)

String? _requiresScreenTimePermission(context, state) {
  if (!hasScreenTimePermission) {
    return '/permissions-request?next=/blocking-rules';
  }
  return null;
}
```

**Status**: Not started
**Effort**: Small (1-1.5 hours)

---

### 5. ❌ Make Routing Reactive to Auth State (MEDIUM PRIORITY)
**Why**: Current `AppRouter` uses `context.read()` which can become stale in edge cases.

**Current Issue**:
```dart
// In app_router.dart redirect:
final authProvider = ref.read(authProvider);  // ← Can be stale
```

**Solution**: Use `Listenable.merge()` to make routing reactive:
```dart
GoRouter(
  refreshListenable: Listenable.merge([authProvider]),
  redirect: (context, state) {
    final isAuth = context.watch<AuthProvider>().isAuthenticated;
    // ... redirect logic
  },
)
```

**Requires context**:
- Need to verify current redirect logic and test edge cases (cold start, logout, session expiry)
- May need to add test cases for routing behavior

**Status**: Blocked (need to review `app_router.dart` in detail)
**Effort**: Small (30-45 mins once scoped)

---

### 6. Documentation (HIGH PRIORITY)
**Why**: Templates need guides for developers to extend them.

**Create**:
- `docs/DEVELOPMENT.md` - Local setup, running the app, debugging
- `docs/PATTERNS.md` - Architecture patterns (Result<T>, Service layer, Provider pattern)
- `docs/TESTING.md` - Writing tests, running test suite, CI/CD
- `docs/LOGGING.md` - Logging strategy and usage
- `docs/ROUTING.md` - Routing patterns, guards, deep linking
- `.github/CONTRIBUTING.md` - PR requirements, code style, checklist
- Update `README.md` - Add "Using as a Template" section with copy-paste checklist

**README Template Section**:
```markdown
## Using as a Template

To start a new project from NotAgain:

1. Clone this repo: `git clone https://github.com/benmayer/NotAgain.git new-project`
2. Update `pubspec.yaml`: Change name, description, version
3. Copy `.env.example` to `.env` and add your credentials
4. Run `flutter pub get`
5. Follow `docs/DEVELOPMENT.md` for local setup
6. See `docs/PATTERNS.md` for architecture patterns
```

**Status**: Not started
**Effort**: Small-Medium (2 hours)

---

## Completed ✅

- ✅ Secure credentials management (environment variables)
- ✅ OAuth error handling (Result<User> + Forui toasts)
- ✅ Forui-first UI components
- ✅ Centralized layout (main_layout.dart)
- ✅ State management (Provider)
- ✅ Auth flow (signup, login, logout)

---

## PR Checklist (for all changes)

- [ ] Run `flutter analyze` - No warnings
- [ ] Run `flutter format` - Code formatted
- [ ] Run `flutter test` - All tests pass
- [ ] Update `README.md` or relevant `docs/` files
- [ ] No secrets committed (check `.env` not in git)
- [ ] Code reviewed for template reusability

---

## Implementation Order (Recommended)

1. **Logger Abstraction** (1.5 hours) - Foundation for better debugging
2. **Constants & Config** (1 hour) - Reduces magic numbers
3. **Testing Infrastructure** (2-3 hours) - Gives template test foundation
4. **Documentation** (2 hours) - Essential for template usage
5. **Routing Guards** (1.5 hours) - Improves UX for future features
6. **Reactive Routing** (0.5 hours) - Bug fix, once scoped

**Total**: ~9 hours to production-grade template

---

## Notes for Future Contributors

- Keep the template **focused on auth & state management** - it's not a full app yet
- Each improvement should have **reusable patterns** for future projects
- Document **why** each pattern exists, not just how
- Test coverage should demonstrate patterns, not be exhaustive
2. Implement core `SupabaseService` methods for auth/profile/rules and add unit tests (large effort).
3. Reconcile and stub the iOS native blocking service, then test channel wiring from `lib/services/native_blocking_service.dart`.

---

File created from the analysis run. Use this backlog to create issues or PRs for each item.