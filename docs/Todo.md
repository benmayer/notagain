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

### 2. Logger Abstraction (DONE ✅)
**Why**: Current `debugPrint()` with emoji is dev-only. Production apps need structured logging.

**Completed Actions**:
- ✅ Created `lib/core/logging/app_logger.dart` - Abstraction for different log levels (debug, info, warn, error)
- ✅ Integrated `logger` package with SimplePrinter (colors configurable)
- ✅ Support multiple log levels with tag-based organization
- ✅ Replaced all debug logging with structured AppLogger calls throughout codebase
- ✅ Added screen initialization logging for navigation flow debugging
- ✅ Removed ANSI color escape codes from logs for cleaner output

**Pattern**:
```dart
AppLogger.info('User signed in', tag: 'AuthProvider');
AppLogger.error('Network request failed', error: e, stackTrace: st);
```

**Implementation Details**:
- All auth screens log init events: `AppLogger.info('XyzScreen initialized', tag: 'Navigation')`
- Removed 26+ debug print statements from auth/routing logic
- Logger initialized in `main.dart` with configurable log levels
- Production-ready: can easily switch to file/external service logging

**Status**: ✅ Completed - All logging centralized and cleaned
**Effort**: 1.5 hours (completed)

---

### 3. Constants & Config Management (DONE ✅)
**Why**: Scattered constants and hardcoded values make maintenance harder.

**Actions**:
- ✅ Create `lib/core/constants/app_constants.dart` - Comprehensive constants across 6 categories
- ✅ Integrated throughout codebase - 47 total replacements across 6 screens
- ✅ Gap spacing constants - Added largeGap, smallGap, extraSmallGap for consistent spacing
- Create `lib/core/config/app_config.dart` - Build-specific config (dev, staging, production) - future enhancement

**Implementation Summary**:
- **UI Padding**: standardPadding, largeGap, standardGap, smallGap, extraSmallGap
- **Toast**: toastDuration, toastMinWidth
- **Border Radius**: borderRadius (8.0)
- **Validation**: minPasswordLength (replaced in login/signup)
- **9 constants actively used** throughout auth screens and settings

**Files Updated**:
- lib/screens/auth/signup_screen.dart (17 replacements)
- lib/screens/auth/login_screen.dart (10 replacements)
- lib/screens/auth/welcome_screen.dart (5 replacements)
- lib/screens/auth/login_screen.dart (5 replacements)
- lib/screens/settings/settings_screen.dart (1 replacement)
- lib/screens/profile/profile_screen.dart (5 replacements)

**Status**: ✅ Completed - All hardcoded values replaced
**Effort**: Small (1 hour)

---

### 4. ✅ Routing Guards & Middleware (DONE ✅)
**Why**: Protect routes based on auth and onboarding state, prevent invalid navigation sequences.

**Completed Implementation**:
- ✅ Comprehensive redirect logic in `lib/routing/app_router.dart` (lines 20-68)
- ✅ Auth guard: Unauthenticated users can only access auth screens (/, /login, /signup)
- ✅ Onboarding guard: Incomplete onboarding users cannot access home/start/profile
- ✅ Session restore: Returns existing user with profile data to onboarding if incomplete
- ✅ Prevents navigation stack corruption (infinite auth stacks fixed)
- ✅ Proper error handling with structured Result<T> responses

**Guard Pattern Implemented**:
```dart
// Not authenticated - allow access to auth screens
if (!isAuthenticated) {
  if (state.matchedLocation == '/' || state.matchedLocation == '/login' || state.matchedLocation == '/signup') {
    return null; // Allow access
  }
  return '/'; // Redirect to welcome
}

// Authenticated but onboarding not complete - redirect to onboarding
if (isAuthenticated && !onboardingCompleted) {
  if (state.matchedLocation == '/onboarding' || state.matchedLocation == '/onboarding/step2') {
    return null; // Allow access to onboarding
  }
  return '/onboarding'; // Redirect all other routes
}
```

**Files Updated**:
- `lib/routing/app_router.dart` - Centralized redirect logic
- `lib/screens/auth/login_screen.dart` - Fixed push/go for proper stack management
- `lib/screens/auth/signup_screen.dart` - Fixed navigation between auth screens

**Status**: ✅ Completed and tested with live iOS app
**Effort**: 2 hours (completed)

---

### 5. ✅ Make Routing Reactive to Auth State (DONE)
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
