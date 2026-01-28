# Onboarding Flow with Routing Guards & Middleware — Implementation Plan

## Overview
Transform the onboarding from a placeholder into a functional multi-step flow that captures user setup preferences and enforces progression. New users will be routed to `/onboarding` after signup/SSO, progress through Name → Picture upload steps, and only reach `/home` after completion. Routing guards will prevent unauthorized access to home without onboarding completion, and tracking will ensure users return to onboarding if they abandon it mid-flow.

## User Flow

1. **Welcome screen** → "Get Started" button
2. **Sign up screen** (email & password only; name moved to onboarding)
3. **Onboarding Step 1 - Name** (not skippable)
   - Auto-populated if user signed up via SSO (Google/Apple)
   - Skips automatically for SSO users
4. **Onboarding Step 2 - Upload Picture** (skippable)
   - Can use camera or gallery
   - If SSO user, can auto-populate with SSO profile picture
   - "Skip" button allows progression without picture
5. **Redirect to Home** after completion
6. **Abandon Handling**: If onboarding abandoned, user returns to onboarding on re-login

---

## Implementation Steps

### 1. Database & User Model Updates
- Add `onboarding_completed` (BOOLEAN DEFAULT false) column to Supabase `profiles` table
- Update [lib/models/user.dart](lib/models/user.dart) to add `onboardingCompleted` bool field and update `fromJson()`/`toJson()` methods
- Update `SupabaseService._createUserProfile()` to initialize `onboarding_completed = false` for new users

### 2. Create Onboarding Provider
- Create [lib/providers/onboarding_provider.dart](lib/providers/onboarding_provider.dart) as ChangeNotifier tracking:
  - Current step (1-2)
  - Name input
  - Picture file/URL
  - Completion status
- Expose methods: `setName(String)`, `setPicture(File)`, `completeOnboarding()`, `abandonOnboarding()`, `resetProgress()`
- Persist step progress to SharedPreferences so abandoned onboarding resumes from last step

### 3. Update SignUp & Auth Flow
- Modify [lib/screens/auth/signup_screen.dart](lib/screens/auth/signup_screen.dart):
  - Remove name field from signup form (email & password only)
  - Redirect to `/onboarding` instead of `/home` after successful signup
- Update SSO handlers (Apple/Google) to also redirect to `/onboarding`
  - For SSO users with provided name, consider skipping directly to Step 2 or pre-populating Step 1

### 4. Build Onboarding Screens
- Update [lib/screens/onboarding/onboarding_screen.dart](lib/screens/onboarding/onboarding_screen.dart) or create separate step screens:
  
  **Step 1** (`/onboarding/step-1` or embedded in main onboarding screen):
  - Text input for name (required, not skippable)
  - Progress indicator showing "Step 1 of 2"
  - "Back" button to abandon/pause flow
  - "Next" button (enabled only when name is entered)
  - Uses `FTextFormField` and `FButton` from Forui
  
  **Step 2** (`/onboarding/step-2`):
  - Camera/gallery file picker for profile picture
  - Progress indicator showing "Step 2 of 2"
  - "Skip" button (allows progression without picture, still marks onboarding as completed)
  - "Back" button to return to Step 1
  - "Finish" or "Complete" button after picture selected
  - File picker widget (native or Forui-compatible)

### 5. Create Routing Guards
- Create [lib/routing/route_guards.dart](lib/routing/route_guards.dart) with guard function:
  ```dart
  String? requiresOnboardingCompletion(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) {
      return null; // Not authenticated, let auth guard handle it
    }
    
    final user = authProvider.user;
    if (user != null && !user.onboardingCompleted) {
      return '/onboarding'; // Redirect to onboarding
    }
    
    return null; // Allow access
  }
  ```
- Apply guard to all protected routes: `/home`, `/start`, `/profile`, `/settings/*`

### 6. Update Router Redirect Logic
- Modify [lib/routing/app_router.dart](lib/routing/app_router.dart) redirect to sequence:
  1. Check authentication (existing logic)
  2. Check onboarding completion (new)
  3. Route to appropriate destination
  
  ```dart
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    
    // Not authenticated
    if (!isAuthenticated) {
      if (state.matchedLocation == '/' || state.matchedLocation.startsWith('/home')) {
        return '/';
      }
      return null;
    }
    
    // Authenticated but onboarding not complete
    if (!authProvider.user?.onboardingCompleted ?? false) {
      if (!state.matchedLocation.startsWith('/onboarding')) {
        return '/onboarding';
      }
    }
    
    // Redirect from auth screens to home if authenticated and onboarded
    if ((state.matchedLocation == '/' || state.matchedLocation.startsWith('/auth')) &&
        authProvider.user?.onboardingCompleted ?? false) {
      return '/home';
    }
    
    return null;
  }
  ```
- Ensure `/onboarding` and `/onboarding/*` routes are accessible only when authenticated but `onboarding_completed == false`

### 7. Add to MultiProvider
- Register `OnboardingProvider` in [lib/main.dart](lib/main.dart) `MultiProvider` so state is app-wide and persists across navigation

### 8. Create Routing Documentation
- Create [docs/ROUTING.md](docs/ROUTING.md) documenting:
  - Onboarding guard flow with sequence diagram
  - Route structure and protection logic
  - Abandon/resume handling
  - SSO auto-skip logic
  - Code examples for guards and redirect

---

## Design Decisions to Finalize

### 1. SSO Auto-Skip Logic
**Question**: If user signs in with Google/Apple and name is provided, should we:
- **Option A**: Auto-complete Step 1 with SSO name and skip directly to Step 2?
- **Option B**: Always require manual name confirmation on Step 1?
- **Option C**: Pre-populate Step 1 name but require "Next" tap to proceed?

**Recommendation**: Option A (auto-skip) for best UX; name is provided by SSO provider, so trust it and skip Step 1.

### 2. Abandon Handling
**Question**: When user taps "Back" on onboarding, should we:
- **Option A**: Show confirmation dialog ("Discard setup?" with "Continue", "Discard" buttons)?
- **Option B**: Silently pause and resume from same step on re-login?
- **Option C**: Soft warning toast ("Progress saved") and resume from last step?

**Recommendation**: Option A (confirmation dialog) for clarity; makes it explicit that onboarding isn't complete if discarded.

### 3. Picture Upload Storage
**Question**: Should profile pictures be:
- **Option A**: Uploaded to Supabase Storage (tightly integrated, same auth)?
- **Option B**: Uploaded to Firebase Storage (more established)?
- **Option C**: Stored locally only, synced later (MVP approach)?

**Recommendation**: Option A (Supabase Storage) for simplicity in a template; aligns with existing backend.

### 4. Google Avatar Extraction
**Question**: Google SSO returns `picture` URL in metadata—should we:
- **Option A**: Auto-populate Step 2 preview with Google's avatar?
- **Option B**: Require user to capture/upload their own photo for consistency?
- **Option C**: Show Google avatar as default but allow replacement?

**Recommendation**: Option C (show Google avatar as preview/default) to streamline UX while allowing user control.

### 5. Progress Persistence
**Question**: Should step progress be stored:
- **Option A**: In SharedPreferences (fast resume, no sync)?
- **Option B**: In database (multi-device consistency)?
- **Option C**: Both (local cache + sync)?

**Recommendation**: Option A (SharedPreferences) matching existing template pattern (theme persistence); aligns with MVP approach.

---

## Files to Create/Modify

### New Files
- [ ] [lib/providers/onboarding_provider.dart](lib/providers/onboarding_provider.dart) — Onboarding state management
- [ ] [lib/routing/route_guards.dart](lib/routing/route_guards.dart) — Guard functions
- [ ] [docs/ROUTING.md](docs/ROUTING.md) — Routing patterns documentation
- [ ] Database migration for `onboarding_completed` column (Supabase)

### Files to Modify
- [ ] [lib/models/user.dart](lib/models/user.dart) — Add `onboardingCompleted` field
- [ ] [lib/screens/auth/signup_screen.dart](lib/screens/auth/signup_screen.dart) — Remove name field, redirect to onboarding
- [ ] [lib/screens/onboarding/onboarding_screen.dart](lib/screens/onboarding/onboarding_screen.dart) — Implement 2-step flow
- [ ] [lib/services/supabase_service.dart](lib/services/supabase_service.dart) — Initialize `onboarding_completed = false`, add update method
- [ ] [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) — Update SSO redirects to `/onboarding`
- [ ] [lib/routing/app_router.dart](lib/routing/app_router.dart) — Implement onboarding guard logic
- [ ] [lib/main.dart](lib/main.dart) — Register `OnboardingProvider`

---

## Testing & Validation

### Manual Test Cases
1. **Email/Password Signup**:
   - Sign up → Step 1 (enter name) → Step 2 (upload/skip picture) → Home ✓
   - Verify `onboarding_completed = true` in database

2. **SSO Signup (Google)**:
   - Google sign-in → Auto-populate name → Step 2 (upload/skip) → Home ✓
   - Verify name was captured from SSO metadata

3. **Abandon & Resume**:
   - Start onboarding → Tap "Back" on Step 1 → Confirm discard → Logged out?
   - Re-login → Return to onboarding (or redirect to home if auto-completed?)

4. **Route Guards**:
   - Attempt to navigate to `/home` while `onboarding_completed = false` → Redirect to `/onboarding` ✓
   - Complete onboarding → Can access `/home` ✓

5. **SSO with Picture**:
   - Google sign-in → Auto-populate name → Show Google avatar in Step 2 → Skip or replace ✓

### Code Quality
- [ ] Run `flutter analyze` — No warnings
- [ ] Run `flutter format` — Code formatted
- [ ] All constants used from `AppConstants` where applicable
- [ ] All logging via `AppLogger` with proper tags (`'OnboardingProvider'`, `'OnboardingScreen'`)

---

## Effort Estimate
- **Provider + Screens**: 2-2.5 hours
- **Router Guards + Redirects**: 1 hour
- **Database Migration + Model Updates**: 0.5 hours
- **Documentation**: 0.5 hours
- **Testing & Refinement**: 1 hour

**Total**: ~5 hours

---

## Notes for Refinement
- Confirm naming conventions match existing codebase (e.g., `onboarding_completed` vs. `setupComplete`)
- Verify Forui has file picker components or if native plugin needed
- Clarify whether "abandon" should fully log user out or just pause onboarding
- Define default picture handling (Forui avatar component or custom widget?)
