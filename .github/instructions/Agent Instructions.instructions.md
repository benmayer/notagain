---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.

# Copilot Instructions for NotAgain

## Project Overview
NotAgain is a Flutter app for screen time management that blocks distracting apps/websites. Features email/OAuth authentication (Supabase), Provider-based state management, bottom-nav layout with auth-gated routing, and native iOS Screen Time API integration for blocking enforcement.

## Architecture Overview

### Core Layers
- **Presentation**: Screens in `lib/screens/` + reusable widgets in `lib/widgets/` (organized by feature)
- **State Management**: Provider pattern with dedicated providers in `lib/providers/` (auth, theme, settings, onboarding, usage, rules, analytics)
- **Services**: `SupabaseService` (backend auth/CRUD/storage) and `NativeBlockingService` (iOS Screen Time API)
- **Models**: DTOs in `lib/models/` (User, blocking rules, app usage, etc.)
- **Routing**: Flattened routes in `lib/routing/app_router.dart` with auth-gated redirects

### Key Entry Points
- `lib/main.dart` - App bootstrap with MultiProvider setup, theme initialization
- `lib/routing/app_router.dart` - GoRouter config with auth redirect logic (see ARCHITECTURE.md for route structure)
- `lib/providers/auth_provider.dart` - Central auth state holder, fetches profile on login
- `lib/services/supabase_service.dart` - Backend bridge (singleton pattern)

### Finding Features in Codebase
When unsure where a feature is located, refer to `ARCHITECTURE.md` for the complete project structure. Key conventions:
- **Screens**: Feature-based folders under `lib/screens/` (auth, onboarding, home, start, profile, settings)
- **Providers**: State management in `lib/providers/` (one provider per domain: auth, theme, onboarding, settings)
- **Widgets**: Reusable components under `lib/widgets/` organized by screen name (auth, home, profile, start, settings)
- **Services**: Backend integration in `lib/services/` (SupabaseService for DB/Auth/Storage, NativeBlockingService for iOS APIs)
- **Models**: Data structures in `lib/models/` (User, AuthResponse, Result<T>, AppError, etc.)

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

### Navigation & Routing (Stack-Based with iOS Swipe-Back Gesture Support)

**Critical Concept**: NotAgain uses **stack-based navigation** with iOS native swipe-back gestures enabled. This requires careful use of `push()` vs `go()`.

#### Navigation Methods & When to Use

**`context.push(routePath)`** - **USE FOR SCREEN-TO-SCREEN NAVIGATION**
- **Purpose**: Adds route to the navigation stack (maintains history)
- **Use when**: Navigating between screens within a flow (auth → settings, step 1 → step 2)
- **Enables**: iOS swipe-back gesture + back button consistency
- **Example**: Welcome → Login, Login → Signup, Settings → Device Settings, Onboarding Step 1 → Step 2
```dart
// ✅ CORRECT - Screen transitions
onPress: () => context.push('/login'),  // Maintains stack for swipe-back
```

**`context.go(routePath)`** - **USE FOR STATE-CHANGE NAVIGATION ONLY**
- **Purpose**: Replaces current route (doesn't maintain stack history)
- **Use when**: Authentication state changes (login complete, logout, signup with OAuth)
- **Enables**: Auth redirect logic without stack pollution
- **Example**: Successful login → Home, Logout → Welcome, Signup → Onboarding
```dart
// ✅ CORRECT - Auth state changes
context.go('/home'),        // Replace current route with home
context.go('/onboarding'),  // Replace current route with onboarding
context.go('/'),            // Logout - return to welcome
```

**`context.pop()`** - **USE FOR BACK BUTTON + SWIPE CONSISTENCY**
- **Purpose**: Removes current route from stack (reverse of push)
- **Use when**: Back buttons, dismiss dialogs
- **Ensures**: Back button matches swipe gesture behavior
- **Example**: All back buttons in non-root screens
```dart
// ✅ CORRECT - Back button using pop
FHeaderAction.back(onPress: () => context.pop()),
```

#### Route Configuration Rules

**Root/Initial Routes** (use `CupertinoPage` - NO swipe gesture):
```dart
GoRoute(
  path: '/',
  name: 'welcome',
  pageBuilder: (BuildContext context, GoRouterState state) {
    return CupertinoPage<void>(  // ← Plain CupertinoPage, no gesture
      name: 'welcome',
      child: const WelcomeScreen(),
    );
  },
),
```

**Nested/Modal Routes** (use `CupertinoPageWithGesture` - HAS swipe gesture):
```dart
GoRoute(
  path: '/login',
  name: 'login',
  pageBuilder: (BuildContext context, GoRouterState state) {
    return CupertinoPageWithGesture<void>(  // ← Enables iOS swipe-back
      name: 'login',
      child: const LoginScreen(),
    );
  },
),
```

#### Navigation Pattern by Screen Type

**Auth Screens** (Welcome, Login, Signup):
- Welcome → Login/Signup: **USE `push()`** (adds to stack)
- Login → Signup (or vice versa): **USE `push()`** (adds to stack)
- Back button on Login/Signup: **USE `pop()`** (removes from stack)
- Successful login/signup with incomplete onboarding: **USE `push('/onboarding')`** (adds to stack, critical for UI updates)
- Successful login/signup with complete onboarding: **USE `go('/home')`** (state change - replaces route)

**⚠️ CRITICAL: Navigation to `/onboarding` after Auth Success**
When login or signup completes and onboarding is incomplete, **always use `push('/onboarding')` NOT `go('/onboarding')`**. GoRouter has issues with `go()` when called from within a route that's being built. Using `push()` properly adds the route to the stack and allows the UI to update correctly. The redirect logic will allow the navigation even though `push()` adds to the stack.

**Onboarding Screens**:
- Step 1 → Step 2: **USE `push()`** (adds to stack)
- Back button on Step 2: **USE `pop()`** (removes from stack)
- Complete onboarding: **USE `go('/home')`** (state change)

**Settings Screens**:
- Settings → Sub-screen (Device, Help, FAQs, etc.): **USE `push()`** (adds to stack)
- Back button on sub-screens: **USE `pop()`** (removes from stack)
- Logout from Settings: **USE `go('/')`** (state change - return to welcome)

**Bottom Nav Screens** (Home, Start, Profile):
- Never use navigation between them - use bottom nav switching
- Settings access: **USE `push('/settings')`** (adds to stack above nav)

#### Critical Rules

1. **Never `go()` for screen-to-screen navigation** - causes swipe gesture to crash (empty stack)
2. **Always `pop()` on back buttons** - ensures consistency with swipe gesture
3. **Always disable swipe on root route** - root screen can't swipe back to nothing
4. **Always enable swipe on nested screens** - provides iOS-native UX
5. **Use `go()` only for auth state changes to home** - login/signup → home when onboarding complete
6. **Use `push()` to onboarding after auth** - GoRouter has issues with `go()` from within route builders
7. **Auth handlers must check onboarding status** - Return user with updated profile data including onboarding status

#### Critical Fixes (Verified Working)

**Issue: Login/Signup navigation to onboarding not working**
- **Cause**: AuthProvider returning old `result.data` instead of updated `_user` with profile data
- **Fix**: Return `_user!` instead of `result.data!` from auth methods
- **Evidence**: User object must have `fullName` set from profile fetch for handler to work correctly

**Issue: Navigation to /onboarding freezes UI**
- **Cause**: `context.go('/onboarding')` fails when called from route being built (GoRouter limitation)
- **Fix**: Use `context.push('/onboarding')` instead for onboarding navigation
- **Why**: `push()` adds to stack, allowing UI updates; redirect logic allows it despite stack-based routing

#### Testing Navigation Flow

```
Welcome (/)[CupertinoPage - no swipe]
  ├─ push → Login (/login)[CupertinoPageWithGesture]
  │   ├─ swipe back → Welcome ✅
  │   ├─ pop() button → Welcome ✅
  │   ├─ push('/onboarding') on login incomplete → Onboarding ✅
  │   └─ go('/home') on login complete → Home ✅
  │
  └─ push → Signup (/signup)[CupertinoPageWithGesture]
      ├─ swipe back → Welcome ✅
      ├─ pop() button → Welcome ✅
      └─ push('/onboarding') on signup → Onboarding ✅

Onboarding Step 1 (/onboarding)[CupertinoPageWithGesture]
  ├─ push → Onboarding Step 2 (/onboarding/step2)[CupertinoPageWithGesture]
  │   ├─ pop() → Step 1 ✅
  │   └─ Complete → go('/home') ✅
  │
  └─ go('/home') on completion → Home ✅

Home/Start/Profile [inside ShellRoute - no swipe needed]
  ├─ push → Settings → Device Settings [CupertinoPageWithGesture]
  │   └─ pop() → Settings → pop() → Home ✅
  │
````
  └─ Logout: go('/') → Welcome ✅
```

### Auth Handler Pattern (Screen Layer)

**When handling login/signup results in screen handlers, ALWAYS:**

1. **Check onboarding status** and navigate to correct screen:
```dart
void _handleLogin(AuthProvider authProvider) async {
  final result = await authProvider.login(email: email, password: password);
  if (!mounted) return;

  if (result.isSuccess) {
    final user = result.data;
    final onboardingCompleted = user?.onboardingCompleted ?? false;
    
    if (onboardingCompleted) {
      context.go('/home');      // ← Use go() for state change
    } else {
      context.push('/onboarding');  // ← Use push() for onboarding! Critical
    }
  } else {
    // Show error
  }
}
```

2. **Why `push()` not `go()` for onboarding?**
   - GoRouter has issues calling `go()` from within a route being built
   - `push()` adds to stack and allows UI updates properly
   - Redirect logic still enforces auth/onboarding rules
   - Pattern: `push()` for onboarding flows, `go()` for home/auth complete

3. **Return complete user object from AuthProvider**
```dart
// ❌ WRONG - Returns old Supabase object without profile data
return Result.success(result.data!);

// ✅ CORRECT - Returns _user with full profile data
_user = _user!.copyWith(
  onboardingCompleted: onboardingCompleted,
  fullName: fullName,
  avatarUrl: avatarUrl,
);
return Result.success(_user!);
```

### Error & Loading States
**Pattern**: Providers expose `isLoading`, `error` fields; screens display loading spinners via `authProvider.isLoading`, errors via SnackBar:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(response.error ?? 'Login failed'))
);
```

### Theming
`**Pattern**: Pure Forui theming with `FThemes.slate.light`/`.dark`. **NO Material theming** — Forui is the single source of truth for all UI styling.
- `ThemeProvider` in `lib/providers/` manages theme state and persistence via SharedPreferences
- `lib/main.dart` wraps app with `FAnimatedTheme` (from Forui's theme switcher) and `FToaster` (toast notifications)
- Theme switching: `context.read<ThemeProvider>().setDarkMode(true/false)` triggers FAnimatedTheme transition
- **Critical**: All UI components must be Forui components; Material components are NOT used for styling

### Service Layer (Supabase)
**Pattern**: SupabaseService is a singleton that wraps all Supabase SDK calls. Initialized in `main()` with credentials. All auth, CRUD, and analytics queries flow through this service.
- Credentials loaded from environment variables (see `.env.example`)

### Form Validation & Widgets
**Pattern**: Reusable form widgets in `lib/widgets/auth/` (e.g., EmailField, PasswordField). Validation logic in models or utils, displayed inline via FormField.

### UI Component Guidelines
**CRITICAL RULE - Forui ONLY**: All UI components must be from Forui library. Material, Cupertino, and custom widgets are strictly forbidden.
- **Mandatory**: Check [forui.dev](https://forui.dev/) documentation for Themes and Controls **before** adding ANY component
- Forui provides 40+ components: buttons, inputs, cards, navigation, overlays, dialogs, progress, avatars, badges, etc.
- Common Forui controls: `FButton`, `FTextFormField`, `FCheckbox`, `FSwitch`, `FCard`, `FScaffold`, `FHeader`, `FBottomNavigationBar`, `FToaster`, `FDialog`
- Icon system: Use `FIcons` class (e.g., `FIcons.settings`, `FIcons.mail`, `FIcons.house`)
- **Exception**: GoRouter requires `MaterialApp.router` at root for navigation—keep minimal; all UI inside is Forui-only
- Style customization: Use `style: (style) => style.copyWith(...)` pattern on Forui components
- **Never** create custom widgets for standard UI patterns—Forui already covers them

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

### Forui Documentation Reference
**ALWAYS check Forui docs before implementing any UI**:
- [Forui Themes](https://forui.dev/) - Theme customization and FAnimatedTheme patterns
- [Forui Controls](https://forui.dev/) - Complete component library reference
- Available theme families: `FThemes.slate`, `.zinc`, `.amber`, `.emerald`, `.rose` (each with `.light` and `.dark` variants)
- Component naming: All Forui components use `F` prefix (e.g., `FButton`, `FTextFormField`, `FCard`)
- Custom styling: Use `style: (style) => style.copyWith(...)` pattern for component-level customization
- Theme access in widgets: `context.theme` for `FThemeData`, `context.theme.colors` for color palette
- If a component isn't in Forui documentation, it doesn't exist—research alternative Forui patterns or ask

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
