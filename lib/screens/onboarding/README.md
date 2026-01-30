/// Onboarding Feature
/// 
/// Manages first-time app setup and permission requests:
/// - Welcome screens and app introduction
/// - Permission request flows for iOS Screen Time API access
/// - Permission denial handling and fallback UX
/// - Completion of onboarding flow
/// 
/// Files in this feature:
/// - screens/onboarding/: Onboarding flow screens, permission request screens
/// - widgets/: Onboarding-specific components
/// - providers/onboarding_provider.dart: Onboarding progress tracking
/// - models/permission_status.dart: Permission status models
/// - services/native_blocking_service.dart: Native platform channel communication for permissions
