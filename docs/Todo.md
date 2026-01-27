# NotAgain — Improvements Backlog

Summary

NotAgain has a clear, well-documented architecture, Provider-based state management, and a strong theming strategy using Forui + Material 3. The highest risks are exposed secrets and incomplete backend/native integrations that block core functionality.

Prioritized improvements

1. ✅ Remove hardcoded Supabase credentials
- Why: Keys in source are a security risk and invalidate safe release practices.
- Actions:
  - Move `supabaseUrl`/`supabaseKey` to environment variables and load with `flutter_dotenv`.
  - Update `lib/main.dart` to read env vars and fail fast when missing.
  - Add `.env.example` and update README with setup steps.
- Severity: High · Effort: Small

2. ✅ Implement missing `SupabaseService` methods
- Why: Core CRUD/analytics methods are incomplete, blocking rules and analytics flows.
- Actions:
  - Complete CRUD for `blocking_rules`, `profiles`, `app_usage` in `lib/services/supabase_service.dart`.
  - Add typed DTOs under `lib/models/` and unit tests in `test/`.
  - Add sample SQL or migration notes in a new `docs/schema.md`.
- Severity: High · Effort: Large

3. Fix OAuth and auth-response handling
- Why: Current checks may mis-handle Supabase SDK responses, hiding failures.
- Actions:
  - Inspect Supabase SDK response types and update `signInWithApple()`/`signInWithGoogle()` in `lib/services/supabase_service.dart`.
  - Surface explicit errors to `lib/providers/auth_provider.dart` and UI snackbars.
  - Add integration tests against a test Supabase project.
- Severity: Medium · Effort: Small

4. Reconcile native blocking docs vs implementation
- Why: The architecture references iOS native bridging, but the native file is missing or not wired.
- Actions:
  - Add or restore `ios/Runner/NativeBlockingService.swift` and ensure Flutter channel wiring in `lib/services/native_blocking_service.dart`.
  - Add device verification steps to README and test on a real device.
- Severity: High · Effort: Medium

5. Make routing reactive to auth state
- Why: `AppRouter` uses `context.read` in redirect logic, which can be stale.
- Actions:
  - Use `GoRouter`'s `refreshListenable` or `GoRouterRefreshStream` tied to `AuthProvider` in `lib/routing/app_router.dart`.
  - Add tests for cold-start and logged-in redirect behavior.
- Severity: Medium · Effort: Small

6. ✅ Standardize result/error types
- Why: Inconsistent error handling complicates UI and tests.
- Actions:
  - Define a shared `Result<T>` or extend `AuthResponse` in `lib/models/user.dart`.
  - Refactor `SupabaseService` to return structured results and update providers.
- Severity: Medium · Effort: Small

7. Add automated tests and CI
- Why: Low test coverage for core flows increases regressions risk.
- Actions:
  - Add unit tests for `AuthProvider` and `SupabaseService` (mocking Supabase client).
  - Add widget tests for `LoginScreen` and `RuleCreationScreen` and a GitHub Actions workflow to run `flutter analyze` and `flutter test`.
- Severity: Medium · Effort: Medium

8. ✅ Enforce Forui-first component usage
- Why: Project requires Forui UI consistency and the agent guidance mandates Forui-first components.
- Actions:
  - Audit `lib/widgets/` and refactor custom buttons/inputs to wrap Forui equivalents.
  - Add a PR checklist item to verify Forui usage and update `.github/copilot-instructions.md` (already added).
- Severity: Medium · Effort: Medium

9. ✅ Apply Forui theme at app root
- Why: `AppTheme` provides Forui themes but the app root must apply them for consistency.
- Actions:
  - Wrap `MyApp` with Forui theme provider and apply `AppTheme.forLightTheme()` / `forDarkTheme()` in `lib/main.dart` and `lib/core/theme/app_theme.dart`.
- Severity: Low · Effort: Small

10. ✅ Rotate leaked secrets & add prevention
- Why: If keys were committed, they should be rotated and prevented from recurrence.
- Actions:
  - Rotate Supabase keys in the dashboard, add secret-detection to CI, and document the secrets policy in README.
- Severity: High · Effort: Small

11. Consolidate TODOs and track issues
- Why: Scattered TODOs increase maintenance friction.
- Actions:
  - Move TODOs from `lib/services/supabase_service.dart` into tracked GitHub issues and reference issue numbers in code comments.
- Severity: Low · Effort: Small

12. ✅  Create main Layout file, so th homepage doesn't need to import all pages: 


PR checklist

- Run `flutter analyze` and `flutter format`.
- Run `flutter test` (unit + widget) locally; include tests for changed logic.
- Ensure no secrets committed; add/update `.env.example`.
- Update `README.md` and `docs/` for any behavioral changes.
- If native code changed, verify builds on device: `flutter build ios` or `flutter build appbundle`.
- Bump version in `pubspec.yaml` for breaking changes.

Next steps (pick one to start)

1. Immediately move Supabase credentials to env and add `.env.example` (high impact, small effort).
2. Implement core `SupabaseService` methods for auth/profile/rules and add unit tests (large effort).
3. Reconcile and stub the iOS native blocking service, then test channel wiring from `lib/services/native_blocking_service.dart`.

---

File created from the analysis run. Use this backlog to create issues or PRs for each item.