# Routing & Navigation Guide

Complete guide to NotAgain's routing architecture, navigation patterns, and stack-based navigation with iOS swipe-back gesture support.

## Overview

NotAgain uses **GoRouter** for declarative routing with **stack-based navigation** that maintains iOS native swipe-back gesture support. All routes are protected by a global redirect function that enforces authentication and onboarding status.

### Core Concepts

**Navigation Stack Model**: The app maintains a navigation stack where each screen can either:
- **Push** onto the stack (adds a new page, maintains history for back navigation)
- **Replace** the current page (via `go()`, clears stack)
- **Pop** from the stack (returns to previous page)

```
Initial State:    Welcome
After push:       [Welcome, Login]
After push again: [Welcome, Login, Signup]
After pop:        [Welcome, Login]
After go:         [Home]  ← replaces entire stack
```

### iOS Swipe-Back Gesture

iOS users expect to swipe from the left edge of the screen to navigate back. In Flutter, this is enabled via `CupertinoPageRoute` with `popGestureEnabled = true`.

**Critical Rule**: The swipe gesture internally calls `pop()`, which removes the page from the stack. If the page was added via `go()` instead of `push()`, there's nothing in the stack to pop back to, causing a crash ("You have popped the last page off of the stack").

---

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

---

## Redirect Logic & Route Guards

The global redirect function in `lib/routing/app_router.dart` enforces the following flow:

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

---

## Navigation Methods

### `context.push(routePath)` - Add to Stack

**When to use:**
- Screen-to-screen navigation within a flow
- Any time you want users to be able to swipe back
- Sequential screens in onboarding, multi-step forms, settings hierarchies

**Examples:**
```dart
// Auth flow
context.push('/signup');      // Welcome → Signup (can swipe back)
context.push('/login');       // Signup → Login (can swipe back)

// Onboarding
context.push('/onboarding/step2');  // Step 1 → Step 2 (can swipe back)

// Settings hierarchy
context.push('/settings/device-settings');  // Can swipe back to settings
```

**Stack behavior:**
```
Before: [Welcome]
After:  [Welcome, Signup]
Swipe:  [Welcome]  ← User can swipe back
```

### `context.go(routePath)` - Replace Current Route

**When to use:**
- Authentication state changes (login complete, logout)
- Major app state transitions
- When you DON'T want users to return to the previous screen

**Examples:**
```dart
// Auth completion - navigate away from auth screens
context.go('/home');          // Login complete → Home (can't swipe back)
context.go('/onboarding');    // Signup complete → Onboarding

// Logout - return to auth flow
context.go('/');              // Logout → Welcome (can't swipe back)
```

**Stack behavior:**
```
Before: [Welcome, Login]
After:  [Home]  ← Previous stack cleared, can't swipe back
```

### `context.pop()` - Remove from Stack

**When to use:**
- Back buttons on screens
- Dismissing modal dialogs
- Explicitly going back to previous page

**Examples:**
```dart
// Back button
FHeaderAction.back(onPress: () => context.pop()),

// Dismiss dialog
Navigator.pop(context);
```

**Stack behavior:**
```
Before: [Welcome, Login, Signup]
After:  [Welcome, Login]  ← Popped Signup, back to Login
```

---

## Route Configuration

### Root Routes (Cannot Swipe Back)

Root/initial routes should use plain `CupertinoPage` without gesture support:

```dart
GoRoute(
  path: '/',
  name: 'welcome',
  pageBuilder: (BuildContext context, GoRouterState state) {
    return CupertinoPage<void>(  // Plain CupertinoPage
      name: 'welcome',
      child: const WelcomeScreen(),
    );
  },
),
```

**Why:** Users can't swipe back from the root because there's no previous page. Enabling swipe would crash the app.

### Nested Routes (Can Swipe Back)

Screens that can be reached via `push()` should use `CupertinoPageWithGesture`:

```dart
GoRoute(
  path: '/login',
  name: 'login',
  pageBuilder: (BuildContext context, GoRouterState state) {
    return CupertinoPageWithGesture<void>(  // Enables swipe gesture
      name: 'login',
      child: const LoginScreen(),
    );
  },
),
```

**Why:** These screens are always pushed onto an existing stack, so swiping back is safe.

---

## Navigation Patterns by Feature

### Authentication Flow

```
Welcome (/) [CupertinoPage - no swipe]
  ├─ "Sign In" button: push('/login')
  │   └─ Login Screen [CupertinoPageWithGesture]
  │       ├─ Back button: pop() → Welcome
  │       ├─ Swipe gesture: pop() → Welcome
  │       └─ Successful login: go('/home') or go('/onboarding')
  │
  └─ "Sign Up" button: push('/signup')
      └─ Signup Screen [CupertinoPageWithGesture]
          ├─ Back button: pop() → Welcome
          ├─ "Already have account?" link: push('/login')
          └─ Successful signup: go('/onboarding') or go('/home')
```

**Navigation Rules:**
- Welcome → Auth screens: **`push()`** (maintain stack for back)
- Between auth screens: **`push()`** (maintain stack for back)
- Auth back buttons: **`pop()`** (remove from stack)
- Successful auth: **`go()`** (state change - clear stack)

### Onboarding Flow

```
Onboarding Step 1 [CupertinoPageWithGesture]
  ├─ "Next" button: push('/onboarding/step2')
  ├─ Back button: pop()
  ├─ Swipe gesture: pop()
  └─ Logout button: go('/')

Onboarding Step 2 [CupertinoPageWithGesture]
  ├─ "Complete" button: go('/home') [state change]
  ├─ Back button: pop() → Step 1
  ├─ Swipe gesture: pop() → Step 1
  └─ Skip button: go('/home')
```

**Navigation Rules:**
- Step 1 → Step 2: **`push()`** (maintain stack for back)
- Back buttons: **`pop()`** (remove from stack)
- Complete onboarding: **`go()`** (state change to authenticated+onboarded)

### Settings Flow

```
Home/Start/Profile [inside ShellRoute - no navigation]
  └─ Settings button: push('/settings')

Settings Screen [CupertinoPageWithGesture]
  ├─ Device Settings: push('/settings/device-settings')
  ├─ Help & Support: push('/settings/help-support')
  ├─ FAQs: push('/settings/faqs')
  ├─ Feedback: push('/settings/feedback')
  ├─ Terms: push('/settings/terms-of-service')
  ├─ Privacy: push('/settings/privacy-policy')
  ├─ Back button: pop() → Home/Start/Profile
  ├─ Logout button: go('/') [state change]
  └─ Swipe gesture: pop()

Sub-settings Screens [CupertinoPageWithGesture]
  ├─ Back button: pop() → Settings
  └─ Swipe gesture: pop() → Settings
```

**Navigation Rules:**
- Settings → Sub-screen: **`push()`** (maintain stack for hierarchy)
- Back buttons: **`pop()`** (remove from stack)
- Logout: **`go('/')`** (state change to unauthenticated)
- Swipe gesture: **`pop()`** (remove from stack)

---

## Onboarding Flow Details

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

---

## Common Mistakes & Fixes

### ❌ Mistake: Using `go()` for Screen-to-Screen Navigation

```dart
// WRONG - causes swipe gesture to crash
onPress: () => context.go('/login'),
```

**Problem:** Stack is replaced, not added to. Swipe gesture tries to pop from empty stack.

**Fix:**
```dart
// CORRECT - maintains stack for swipe
onPress: () => context.push('/login'),
```

### ❌ Mistake: Using `go()` for Back Button

```dart
// WRONG - inconsistent with swipe gesture
FHeaderAction.back(onPress: () => context.go('/')),
```

**Problem:** Back button replaces route, but swipe gesture pops it. Inconsistent behavior.

**Fix:**
```dart
// CORRECT - consistent with swipe gesture
FHeaderAction.back(onPress: () => context.pop()),
```

### ❌ Mistake: Enabling Swipe on Root Screen

```dart
// WRONG - root screen can't swipe back
GoRoute(
  path: '/',
  pageBuilder: (context, state) => 
    CupertinoPageWithGesture<void>(  // ← Don't do this
      child: const WelcomeScreen(),
    ),
),
```

**Problem:** Swipe gesture enabled on root causes crashes (nothing to swipe back to).

**Fix:**
```dart
// CORRECT - disable swipe on root
GoRoute(
  path: '/',
  pageBuilder: (context, state) => 
    CupertinoPage<void>(  // ← Plain CupertinoPage
      child: const WelcomeScreen(),
    ),
),
```

### ❌ Mistake: Using `context.go()` After Async Operation

```dart
// WRONG - potential stack mismatch
Future<void> onLogin() async {
  await authProvider.login();
  context.go('/home');  // If login already did navigation, conflict
}
```

**Problem:** Multiple code paths could navigate, causing conflicts.

**Fix:**
```dart
// CORRECT - single source of navigation
Future<void> onLogin() async {
  final result = await authProvider.login();
  if (result.isSuccess) {
    context.go('/home');  // Only navigate on success
  }
}
```

---

## Testing Navigation

### Checklist for New Screens

When adding a new screen, verify:

- [ ] Route defined in `app_router.dart` with correct `CupertinoPage` type
- [ ] Navigation to this screen uses `push()` (unless it's a state change)
- [ ] Back button uses `pop()` (not `go()`)
- [ ] Can swipe back if `CupertinoPageWithGesture` is used
- [ ] Logout returns to welcome with `go('/')`
- [ ] `flutter analyze` passes with no warnings
- [ ] Tested on iOS device with actual swipe gesture

### Manual Testing Steps

1. **Test push navigation:**
   - Tap button to navigate to screen
   - Verify screen appears

2. **Test back button:**
   - Tap back button
   - Verify returns to previous screen

3. **Test swipe gesture:**
   - Swipe from left edge of screen
   - Verify slides back to previous screen
   - Verify animation is smooth

4. **Test auth state changes:**
   - Complete login/signup
   - Verify redirected to correct screen
   - Verify can't swipe back to auth screens

5. **Test logout:**
   - Logout from settings
   - Verify returns to welcome
   - Verify can't swipe back to home

---

## Debugging Navigation Issues

### Issue: Swipe Gesture Crashes App

**Symptoms:** App crashes with "You have popped the last page off of the stack"

**Cause:** Swipe enabled on route that was added via `go()` instead of `push()`

**Fix:**
1. Identify the route where swipe is crashing
2. Find where this route is navigated to (in all screens)
3. Replace `context.go()` with `context.push()`
4. Or change route to use `CupertinoPage` (disable swipe)

### Issue: Back Button Doesn't Work

**Symptoms:** Back button doesn't navigate to previous screen

**Cause:** Back button using `go()` instead of `pop()`, or route not in stack

**Fix:**
1. Check back button handler uses `context.pop()`
2. Verify screen was navigated to via `push()`, not initial route
3. Check route is not disabled in redirect logic

### Issue: Inconsistent Navigation Behavior

**Symptoms:** Swipe gesture and back button go to different places

**Cause:** Back button uses `go()` while swipe uses `pop()`

**Fix:**
1. Back button MUST use `context.pop()`
2. This ensures consistency with swipe gesture

### Issue: User Stuck on Onboarding Screen

**Symptoms:** User can't progress past onboarding

**Cause:** `onboarding_completed` not saved to database after completion

**Solution:** Verify `SupabaseService.updateOnboardingStatus()` is called and succeeds. Check database for updated `onboarding_completed` value.

### Issue: SSO Doesn't Skip Onboarding

**Symptoms:** SSO sign-in doesn't bypass onboarding

**Cause:** SSO metadata not extracted or `onboarding_completed` not set correctly

**Solution:** Check `SupabaseService.signInWithGoogle/Apple()` for metadata extraction. Verify `userMetadata['full_name']` and `userMetadata['picture']` are present.

---

## Best Practices

1. **Always use `context.push()`** for screen-to-screen navigation (not `go()`) unless it's a state change
2. **Use `context.go()`** only for auth state changes and major transitions
3. **Always use `context.pop()`** for back buttons and dismissals
4. **Check isAuthenticated before showing protected UI** (e.g., profile data, settings)
5. **Don't hardcode routes** - use route names from `app_router.dart`
6. **Test all auth states**: unauthenticated, authenticated+not-onboarded, authenticated+onboarded
7. **Handle logout properly** - clears `AuthProvider` user, triggers redirect to `/`
8. **Persist onboarding progress** via SharedPreferences for abandoned flows

---

## Architecture Decisions

### Why Stack-Based Navigation?

1. **User Expectation**: iOS users expect swipe-back gesture - it's a standard UX pattern
2. **History Preservation**: Stack maintains navigation history for natural back behavior
3. **State Clarity**: Clear distinction between navigation (push/pop) and state changes (go)
4. **Performance**: Reduces unnecessary state updates from replacing routes

### Why Separate `push()` from `go()`?

1. **Auth State Changes**: Auth state transitions need to clear stack to prevent returning to auth screens
2. **Gesture Consistency**: `push()` maintains stack for safe swipe gestures
3. **Intent Clarity**: Code explicitly shows whether navigation is within a flow or a state change

### Why Disable Swipe on Root?

1. **Crash Prevention**: Swipe on root (nothing to go back to) crashes GoRouter
2. **User Safety**: Prevents users from accidentally crashing the app
3. **Android Compatibility**: Android doesn't have swipe gesture, so root routes don't need it

---

## References

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [CupertinoPageRoute Documentation](https://api.flutter.dev/flutter/cupertino/CupertinoPageRoute-class.html)
- [Flutter Navigation Patterns](https://flutter.dev/docs/development/ui/navigation)
