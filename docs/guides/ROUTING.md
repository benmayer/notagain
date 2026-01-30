# Routing Documentation

This document describes the routing architecture for NotAgain, including authentication-based guards, onboarding flow enforcement, and deep linking patterns.

## Overview

NotAgain uses **GoRouter** for declarative routing with automatic authentication and onboarding status checks. All routes are protected by a global redirect function that enforces:
1. **Authentication** - Users must be logged in to access protected routes
2. **Onboarding Completion** - Authenticated users must complete onboarding before accessing the main app

## Route Structure

### Public Routes (No Auth Required)
- `/` - Welcome screen (landing page)
- `/login` - Email/password login
- `/signup` - Email/password signup

### Onboarding Route (Auth Required, Onboarding Not Complete)
- `/onboarding` - Multi-step onboarding flow (Step 1: Name, Step 2: Picture)

### Protected Routes (Auth + Onboarding Required)
- `/home` - Home screen with bottom navigation
- `/start` - Start blocking screen
- `/profile` - User profile
- `/settings` - Settings and preferences
  - `/settings/device-settings` - Device-specific settings
  - `/settings/notifications` - Notification preferences
  - `/settings/about` - About & version info

## Redirect Logic

The global redirect function in [lib/routing/app_router.dart](lib/routing/app_router.dart) enforces the following flow:

```dart
redirect: (context, state) {
  final authProvider = context.read<AuthProvider>();
  final isAuthenticated = authProvider.isAuthenticated;
  final user = authProvider.user;
  final onboardingCompleted = user?.onboardingCompleted ?? false;

  // 1. Not authenticated - allow auth screens only
  if (!isAuthenticated) {
    if (state.matchedLocation == '/' || 
        state.matchedLocation == '/login' || 
        state.matchedLocation == '/signup') {
      return null; // Allow access
    }
    return '/'; // Redirect to welcome
  }

  // 2. Authenticated but onboarding not complete
  if (isAuthenticated && !onboardingCompleted) {
    if (state.matchedLocation.startsWith('/onboarding')) {
      return null; // Allow onboarding access
    }
    return '/onboarding'; // Redirect to onboarding
  }

  // 3. Authenticated and onboarded - redirect from auth screens
  if (isAuthenticated && onboardingCompleted) {
    if (state.matchedLocation == '/' || 
        state.matchedLocation == '/login' || 
        state.matchedLocation == '/signup') {
      return '/home'; // Redirect to home
    }
    if (state.matchedLocation.startsWith('/onboarding')) {
      return '/home'; // Don't allow re-access to onboarding
    }
  }

  return null; // Allow access
}
```

## Onboarding Flow

### Purpose
Onboarding collects required user information (name) and optional profile setup (picture) for new users.

### Flow Sequence

#### Email/Password Signup
1. User signs up with email + password on `/signup`
2. `onboarding_completed = false` set in database
3. Redirect to `/onboarding` (Step 1)
4. User enters name → Step 2
5. User uploads/skips picture → Complete
6. `onboarding_completed = true` saved to database
7. Redirect to `/home`

#### SSO Sign-In (Google/Apple)
1. User signs in with Google/Apple
2. SSO metadata extracted: `full_name`, `picture` (if available)
3. **Auto-complete logic**:
   - If both `full_name` AND `picture` provided → Set `onboarding_completed = true` → Redirect to `/home`
   - If only `full_name` provided → Set `onboarding_completed = false` → Redirect to `/onboarding` (Step 2)
   - If neither provided → Redirect to `/onboarding` (Step 1)

### Onboarding Screen Details

**Step 1: Name Input**
- Required field (not skippable)
- Pre-populated if SSO provided `full_name`
- "Next" button disabled until name entered
- "Back" button abandons onboarding (user remains authenticated, returns to onboarding on next login)

**Step 2: Picture Upload**
- Optional (skippable)
- Two options:
  - **Camera**: Capture photo via `image_picker`
  - **Gallery**: Select existing photo via `image_picker`
- Pre-populated with SSO avatar if Google/Apple provided `picture`
- "Skip" button marks onboarding as complete without picture
- "Complete" button uploads picture to Supabase Storage `avatars` bucket and saves URL to profile

### Abandon Handling
When user taps "Back" on onboarding:
- Progress saved to SharedPreferences (current step, name draft, picture path)
- User remains **authenticated** (no logout)
- On app restart or re-login → Router redirects to `/onboarding`
- User resumes from last saved step

## Route Guards

Guards are helper functions in [lib/routing/route_guards.dart](lib/routing/route_guards.dart) that can be applied to individual routes for additional protection logic.

### Available Guards

#### `requiresOnboardingCompletion(context, state)`
Returns:
- `/onboarding` if authenticated but `onboarding_completed == false`
- `null` if onboarding complete (allow access)
- `null` if not authenticated (let auth guard handle it)

**Usage**: Apply to protected routes that should only be accessible after onboarding.

```dart
GoRoute(
  path: '/home',
  redirect: (context, state) => requiresOnboardingCompletion(context, state),
  builder: (context, state) => const HomeScreen(),
)
```

#### `requiresAuthentication(context, state)`
Returns:
- `/` (welcome screen) if not authenticated
- `null` if authenticated (allow access)

**Usage**: Apply to routes that require login but don't care about onboarding status.

```dart
GoRoute(
  path: '/settings',
  redirect: (context, state) => requiresAuthentication(context, state),
  builder: (context, state) => const SettingsScreen(),
)
```

**Note**: Global redirect in `app_router.dart` already handles both guards, so individual guard functions are optional for most routes.

## Deep Linking (Future)

### Planned Deep Link Structure
- `notagain://home` → Home screen (auth + onboarding required)
- `notagain://profile` → User profile
- `notagain://start` → Start blocking
- `notagain://settings` → Settings

### Implementation Notes
When implementing deep links:
1. Deep link routes must respect global redirect logic
2. Unauthenticated users should be redirected to `/` (welcome)
3. Authenticated but non-onboarded users should complete onboarding first
4. Store intended destination in query params to redirect after auth/onboarding

Example:
```dart
// User taps deep link while not authenticated
// Router redirects: notagain://profile → /login?next=/profile
// After login, check onboarding status:
//   - If onboarded → Redirect to /profile
//   - If not onboarded → Redirect to /onboarding?next=/profile
// After onboarding → Redirect to /profile
```

## Navigation Patterns

### Programmatic Navigation

```dart
// Navigate to a route
context.go('/home');

// Navigate with replacement (no back stack)
context.go('/home');

// Navigate back
context.pop();

// Check current route
GoRouter.of(context).location
```

### Bottom Navigation

Bottom navigation is implemented in [lib/main_layout.dart](lib/main_layout.dart) and wraps routes via `ShellRoute`:

```dart
ShellRoute(
  builder: (context, state, child) => MainLayout(
    currentRoute: state.matchedLocation,
    child: child,
  ),
  routes: [
    GoRoute(path: '/home', ...),
    GoRoute(path: '/start', ...),
    GoRoute(path: '/profile', ...),
  ],
)
```

Bottom nav is **not shown** on:
- Auth screens (`/`, `/login`, `/signup`)
- Onboarding screen (`/onboarding`)
- Settings screens (`/settings/*`)

## Testing Routes

### Manual Test Cases

#### 1. Email/Password Signup Flow
- Sign up → Should redirect to `/onboarding` (Step 1)
- Enter name → Step 2
- Upload/skip picture → Should redirect to `/home`
- Verify `onboarding_completed = true` in database

#### 2. SSO with Full Metadata (Google)
- Sign in with Google (name + picture) → Should skip onboarding, redirect to `/home`
- Verify `onboarding_completed = true` in database

#### 3. SSO with Partial Metadata (Apple)
- Sign in with Apple (name only, no picture) → Should redirect to `/onboarding` (Step 2)
- Upload/skip picture → Should redirect to `/home`

#### 4. Onboarding Abandonment
- Sign up, enter name, tap "Back" → Should remain authenticated
- Close app, reopen → Should redirect to `/onboarding` (Step 1 with name pre-filled)

#### 5. Route Protection
- While unauthenticated, attempt to navigate to `/home` → Should redirect to `/`
- While authenticated but not onboarded, attempt to navigate to `/profile` → Should redirect to `/onboarding`
- After onboarding complete, attempt to navigate to `/onboarding` → Should redirect to `/home`

## Troubleshooting

### Issue: Infinite redirect loop
**Cause**: Global redirect returns a route that itself triggers another redirect.

**Solution**: Ensure redirect logic has explicit `return null` for allowed routes.

### Issue: User stuck on onboarding screen
**Cause**: `onboarding_completed` not saved to database after completion.

**Solution**: Verify `SupabaseService.updateOnboardingStatus()` is called and succeeds. Check database for updated `onboarding_completed` value.

### Issue: SSO doesn't skip onboarding
**Cause**: SSO metadata not extracted or `onboarding_completed` not set correctly.

**Solution**: Check `SupabaseService.signInWithGoogle/Apple()` for metadata extraction. Verify `userMetadata['full_name']` and `userMetadata['picture']` are present.

## Best Practices

1. **Always use context.go()** for navigation (not context.push()) to respect redirect logic
2. **Check isAuthenticated before showing protected UI** (e.g., profile data, settings)
3. **Don't hardcode routes** - use route names from `app_router.dart`
4. **Test all auth states**: unauthenticated, authenticated+not-onboarded, authenticated+onboarded
5. **Handle logout properly** - clears `AuthProvider` user, triggers redirect to `/`
6. **Persist onboarding progress** via SharedPreferences for abandoned flows

## Future Enhancements

- **Permission-based guards**: Block routes requiring iOS Screen Time permission
- **Feature flags**: Conditionally show/hide routes based on `AppConstants.enableExperimentalFeatures`
- **Analytics**: Track route transitions for user flow optimization
- **Error routes**: Add custom 404 page for invalid routes
