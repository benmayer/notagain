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

## Research Findings

### 1. Naming Conventions ✅
**Verified**: The codebase uses **snake_case for database fields** and **camelCase for Dart properties**.

- Database columns: `full_name`, `avatar_url`, `created_at`, `last_sign_in_at`
- Dart model properties: `fullName`, `avatarUrl`, `createdAt`, `lastSignInAt`

**Decision**: Add `onboarding_completed` (snake_case) to database, map to `onboardingCompleted` (camelCase) in Dart User model.

### 2. File Picker Components ✅
**Verified**: Forui **does NOT have file picker or camera/gallery components**.

Found in Forui:
- `FAvatar` - Display avatar with image/fallback
- `FPicker` - iOS-style scroll wheel picker (for dates/times, not files)

**Decision**: Use native Flutter plugin **`image_picker`** (official Flutter package) for camera/gallery access. Added to `pubspec.yaml` dependencies.

### 3. Abandon Handling ✅
**Verified**: Current logout flow clears session and navigates to Welcome screen.

From `auth_provider.dart`:
- `logout()` clears `_user`, sets `_isAuthenticated = false`, calls `SupabaseService.logout()` which signs out from Supabase
- Router redirects unauthenticated users to `/` (Welcome screen)

**Decision**: When user taps "Back" on onboarding, **do NOT logout**—just pause progress and save state to SharedPreferences. User remains authenticated but with incomplete onboarding, so on app restart they're redirected back to `/onboarding`.

### 4. Avatar Display & Upload ✅
**Verified**: Forui has `FAvatar` widget for displaying avatars.

From Forui docs:
```dart
FAvatar(
  image: NetworkImage('https://example.com/profile.jpg'),
  fallback: const Text('JD'),
  size: 40.0,
)
```

**Decision**: 
- Use `FAvatar` to **display** profile pictures throughout the app
- Use `image_picker` package for **capturing/uploading** pictures
- Use Supabase Storage with dedicated `avatars` bucket (public read access)

### 5. SSO Avatar Extraction ✅
**Verified**: Apple/Google SSO already extract `full_name` from `userMetadata`, but **avatar URLs are NOT currently extracted**.

**Decision**: Auto-extract avatar URLs from SSO metadata:
- Google SSO: Check `userMetadata['picture']`
- Apple SSO: Check `userMetadata['picture']` (if available)
- If avatar found, save to user profile and skip Step 2 automatically

---

## Implementation Steps

### 1. Database & User Model Updates
- Add `onboarding_completed` (BOOLEAN DEFAULT false) column to Supabase `profiles` table via Supabase SQL Editor
- Update [lib/models/user.dart](lib/models/user.dart):
  - Add `onboardingCompleted` bool field (camelCase for Dart)
  - Update `copyWith()` method to include new field
  - Add JSON serialization if needed
- Update `SupabaseService._createUserProfile()` to initialize `onboarding_completed = false` for new users
- Create Supabase Storage bucket `avatars` with:
  - Public read access (so avatar URLs work without auth)
  - Authenticated write access (only logged-in users can upload)
  - File size limit: 5MB
  - Allowed MIME types: image/jpeg, image/png, image/webp

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
- Update [lib/services/supabase_service.dart](lib/services/supabase_service.dart) SSO handlers:
  - **Apple Sign-In**: Extract `userMetadata['full_name']` (already done) and `userMetadata['picture']` (new)
  - **Google Sign-In**: Extract `userMetadata['full_name']` (already done) and `userMetadata['picture']` (new)
  - Save extracted avatar URL to `avatar_url` in user profile
  - If both name and avatar are present from SSO, set `onboarding_completed = true` immediately
- Update [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart):
  - Change SSO redirect logic to check `user.onboardingCompleted`:
    - If `true` (both name & avatar from SSO), redirect to `/home`
    - If `false` (missing name or avatar), redirect to `/onboarding`

### 4. Build Onboarding Screens
- Update [lib/screens/onboarding/onboarding_screen.dart](lib/screens/onboarding/onboarding_screen.dart) or create separate step screens:
  
  **Step 1** (`/onboarding/step-1` or embedded in main onboarding screen):
  - Text input for name (required, not skippable)
  - Progress indicator showing "Step 1 of 2"
  - "Back" button to abandon/pause flow
  - "Next" button (enabled only when name is entered)
  - Uses `FTextFormField` and `FButton` from Forui
  
  **Step 2** (`/onboarding/step-2`):
  - Camera/gallery file picker using `image_picker` package
  - Show current avatar preview using `FAvatar` widget (if SSO provided one)
  - Progress indicator showing "Step 2 of 2"
  - "Skip" button (allows progression without picture, still marks onboarding as completed)
  - "Back" button to return to Step 1
  - "Finish" or "Complete" button after picture selected
  - Upload to Supabase Storage `avatars` bucket:
    - File name: `{userId}_{timestamp}.{ext}`
    - Update `avatar_url` in user profile with public URL
  - Use `FButton` for actions, `FAvatar` for preview

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

## Design Decisions (Confirmed)

### 1. SSO Auto-Skip Logic ✅
**Confirmed**: Auto-extract avatar from SSO metadata.

- If user signs in with Google/Apple and name is provided:
  - Auto-complete Step 1 with SSO name and skip directly to Step 2
- If user signs in with Google/Apple and both name AND picture are provided:
  - Auto-complete both steps, set `onboarding_completed = true`, redirect to `/home`
- SSO avatar extraction:
  - Google: `userMetadata['picture']` (commonly available)
  - Apple: `userMetadata['picture']` (rarely available, fallback to Step 2)

### 2. Abandon Handling ✅
**Confirmed**: Pause onboarding, do NOT logout.

- When user taps "Back" on onboarding:
  - Silently pause and save progress to SharedPreferences
  - User remains authenticated but `onboarding_completed = false`
  - On app restart or re-login, router redirects back to `/onboarding`
- Example: User enters name, taps back → on re-login returns to Step 1 with name pre-filled from SharedPreferences

### 3. Picture Upload Storage ✅
**Confirmed**: Create dedicated `avatars` bucket in Supabase Storage.

- Bucket configuration:
  - Name: `avatars`
  - Public read access (URLs work without auth)
  - Authenticated write access (only logged-in users can upload)
  - File size limit: 5MB
  - Allowed types: image/jpeg, image/png, image/webp
- File naming: `{userId}_{timestamp}.{ext}` for uniqueness
- URL saved to `avatar_url` field in `profiles` table

### 4. File Picker Implementation ✅
**Confirmed**: Use `image_picker` package (official Flutter plugin).

- Forui does NOT provide file picker components
- `image_picker` supports:
  - Camera capture
  - Gallery selection
  - Image compression/quality options
  - Cross-platform (iOS, Android, Web)
- Display avatars with Forui's `FAvatar` widget

### 5. Progress Persistence ✅
**Confirmed**: Store progress in SharedPreferences.

- Step progress stored locally (fast resume, no sync needed)
- Handles app restarts or crashes during onboarding
- Keys:
  - `onboarding_current_step` (1 or 2)
  - `onboarding_name_draft` (temporary name storage)
  - `onboarding_picture_path` (local file path before upload)
- Clear SharedPreferences data after onboarding completion

---

## Files to Create/Modify

### New Files
- [ ] [lib/providers/onboarding_provider.dart](lib/providers/onboarding_provider.dart) — Onboarding state management
- [ ] [lib/routing/route_guards.dart](lib/routing/route_guards.dart) — Guard functions
- [ ] [docs/ROUTING.md](docs/ROUTING.md) — Routing patterns documentation
- [ ] Database migration for `onboarding_completed` column (Supabase SQL Editor)
- [ ] Supabase Storage bucket `avatars` (via Supabase Dashboard)

### New Dependencies
- [x] `image_picker: ^1.0.7` — Camera/gallery file picker (added to pubspec.yaml)

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

## Implementation Checklist

### Pre-Implementation
- [x] Research Forui components (FAvatar, no file picker)
- [x] Verify naming conventions (snake_case DB, camelCase Dart)
- [x] Confirm abandon behavior (pause, not logout)
- [x] Select file picker solution (image_picker package)
- [x] Choose storage solution (Supabase Storage avatars bucket)
- [x] Decide SSO avatar extraction strategy (auto-extract from metadata)
- [x] Add image_picker dependency to pubspec.yaml

### Database Setup
- [ ] Create `onboarding_completed` column in Supabase `profiles` table
- [ ] Create `avatars` storage bucket in Supabase Dashboard
- [ ] Configure bucket policies (public read, auth write, 5MB limit)

### Ready for Implementation
All research complete. Proceed with implementation steps 1-8 above.
