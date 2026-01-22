# Copilot Instructions for NotAgain

## Project Overview
NotAgain is a Flutter app for screen time management that blocks distracting apps/websites. Features email/OAuth authentication (Supabase), Provider-based state management, bottom-nav layout with auth-gated routing, and native iOS Screen Time API integration for blocking enforcement.

## Architecture Overview

### Core Layers
- **Presentation**: Screens in `lib/screens/` + reusable widgets in `lib/widgets/` (organized by feature)
- **State Management**: Provider pattern with dedicated providers in `lib/providers/` (auth, theme, settings, usage, rules, analytics)
- **Services**: `SupabaseService` (backend auth/CRUD) and `NativeBlockingService` (iOS Screen Time API)
- **Models**: DTOs in `lib/models/` (User, blocking rules, app usage, etc.)

### Key Entry Points
- `lib/main.dart` - App bootstrap with MultiProvider setup, theme initialization
- `lib/routing/app_router.dart` - GoRouter config with auth redirect logic
- `lib/providers/auth_provider.dart` - Central auth state holder
- `lib/services/supabase_service.dart` - Backend bridge (singleton pattern)

## Critical Patterns & Conventions

### State Management (Provider)
**Pattern**: All state lives in Provider-based ChangeNotifiers in `lib/providers/`. Screens consume via `context.watch<ProviderClass>()` for reactive updates, `context.read<ProviderClass>()` for one-time access.
```dart
// Example: AuthProvider for auth state
class AuthProvider extends ChangeNotifier {
  Future<AuthResponse> login({required String email, required String password})
  // Screens call: authProvider.login() → triggers notifyListeners() → UI rebuilds
}
```

### Navigation & Routing
**Pattern**: Auth-gated routing via GoRouter redirect. Unauthenticated users redirected to `/login`; authenticated users auto-redirected from auth screens to `/home`.
- Routes defined in `lib/routing/app_router.dart`
- Bottom nav implemented in `lib/screens/home/home_screen.dart` with multiple placeholder screens

### Error & Loading States
**Pattern**: Providers expose `isLoading`, `error` fields; screens display loading spinners via `authProvider.isLoading`, errors via SnackBar:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(response.error ?? 'Login failed'))
);
```

### Theming
**Pattern**: Material 3 + Forui theming unified in `lib/core/theme/app_theme.dart`. Primary color `#1fbacb` (teal) applied app-wide. ThemeProvider manages light/dark mode persistence via SharedPreferences.

### Service Layer (Supabase)
**Pattern**: SupabaseService is a singleton that wraps all Supabase SDK calls. Initialized in `main()` with credentials. All auth, CRUD, and analytics queries flow through this service.
- Credentials loaded from environment variables (see `.env.example`)

### Form Validation & Widgets
**Pattern**: Reusable form widgets in `lib/widgets/auth/` (e.g., EmailField, PasswordField). Validation logic in models or utils, displayed inline via FormField.

### UI Component Guidelines
**Critical Rule**: Always use Forui components first for UI elements (buttons, inputs, cards, etc.). Forui is the primary UI framework for this project.
- Check [forui.dev](https://forui.dev/) documentation before creating custom widgets
- Only create custom components when Forui lacks the needed functionality
- **Ask for permission** before implementing custom UI components—there may be a Forui solution already
- Custom widgets should wrap or extend Forui components when possible to maintain design consistency

## Developer Workflows

### Local Setup
```bash
cd notagain
cp .env.example .env
# Edit .env and add your Supabase credentials
flutter pub get
flutter run
```

### Adding a New Feature
1. Create folder under `lib/screens/[feature]/`
2. Create Provider in `lib/providers/[feature]_provider.dart`
3. Create models in `lib/models/` if needed
4. Create Screen in `lib/screens/[feature]/`
5. Wire route in `lib/routing/app_router.dart`

### Testing on Device
- iOS: `flutter run -d [device_id]`
- Android: Requires Device Admin setup (future; currently iOS-focused)

## Integration Points

### Supabase Backend
Database schema (Postgres) for users, profiles, blocking_rules, app_usage, blocked_attempts. All CRUD via `SupabaseService` methods. Auth via Supabase Auth (email + OAuth providers).

### Native Integration (iOS)
`NativeBlockingService` bridges to `ios/Runner/NativeBlockingService.swift` for Screen Time API calls (permission requests, app blocking). Uses platform channels (method name convention: `native.blockingService`).

### Local Persistence
- User preferences (theme, settings) via SharedPreferences in `lib/core/utils/`
- Future: SQLite via sqflite for offline app lists

## Project-Specific Conventions

- **File Naming**: snake_case for files, PascalCase for classes
- **Imports**: Feature-relative imports preferred; absolute imports from `lib/` for shared code
- **Comments**: Inline doc comments (///) on classes/methods describing purpose, parameters, return
- **Response Models**: Auth operations return `AuthResponse` (success/user/error); handle `.isSuccess` getter
- **Debugging**: Use debugPrint() with emoji prefixes (✅, ❌, ℹ️) for log clarity (see AuthProvider)

## Code Quality Standards

**CRITICAL**: All `flutter analyze` warnings must be resolved. Code quality is not optional—warnings are treated as actionable improvements, not mere suggestions.

### Warnings Categories & Resolution

1. **Unused Code** (unused_element, unused_variable)
   - Remove dead code immediately. Example: unused methods, variables, imports
   - Action: Delete or refactor to use the declaration

2. **Deprecated APIs** (deprecated_member_use)
   - Replace with modern equivalents: `withOpacity()` → `.withValues()`, `background` → `surface`, `onBackground` → `onSurface`
   - Keep the codebase compatible with Flutter 3.18+

3. **Code Style Issues** (sort_child_properties_last, use_build_context_synchronously)
   - Place `child` parameter last in widget constructors
   - Protect `BuildContext` usage across async gaps with `mounted` checks or context preservation patterns
   - These improve readability and prevent runtime errors

4. **Unnecessary Library Directives** (unnecessary_library_name)
   - Remove `library` declarations from files unless explicitly needed for privacy/documentation
   - Modern Dart prefers implicit library names

5. **Logging Best Practices** (avoid_print)
   - Replace `print()` with `debugPrint()` or structured logging frameworks
   - Allows filtering in production and consistent logging across codebase

### Workflow
- Run `flutter analyze` before committing
- Fix **all** warnings, not just errors
- If a warning is unclear, research the best practice and implement it
- Exception: Only skip warnings if explicitly documented with `// ignore:` and a reason

## Common Tasks

### Add a New Auth Method
1. Add method to `SupabaseService` (e.g., `signInWithApple()`)
2. Wire into `AuthProvider` with loading/error state
3. Create UI screen or button with error handling via SnackBar
4. Update routing if new auth route needed

### Add a Settings Toggle
1. Create bool field in `SettingsProvider`
2. Add toggle widget in `lib/widgets/profile/preference_toggle.dart`
3. Persist via SharedPreferences in provider's init/setters

### Query Supabase Data
1. Add method to `SupabaseService` using `_client.from('table').select/insert/update/delete()`
2. Call from appropriate provider (e.g., UsageProvider for app_usage table)
3. Update UI via provider's notifyListeners()

## Caveats & Future Work

- **Production Credentials**: Supabase key/URL now loaded from environment variables (see `.env.example`)
- **Android Support**: Device Admin integration not yet implemented (framework in place; native iOS priority)
- **Offline-First**: App currently online-only; local SQLite caching planned but not wired
- **Testing**: Minimal test coverage; expand unit/widget/integration tests before release
- **Database Setup**: New tables (blocking_rules, app_usage, blocked_attempts, profiles) must be created in Supabase. See `docs/schema.md` for SQL setup instructions and schema details.
