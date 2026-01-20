/// Onboarding Feature
/// 
/// Manages first-time app setup and permission requests:
/// - Welcome screens and app introduction
/// - Permission request flows for:
///   - iOS: Screen Time API access
///   - Android: Device Admin permissions, Usage Stats, VPN (if applicable)
/// - Permission denial handling and fallback UX
/// - Completion of onboarding flow
/// 
/// Files in this feature:
/// - screens/: Onboarding flow screens, permission request screens
/// - providers/: Onboarding progress tracking
/// - models/: Permission status models
/// - services/: Native platform channel communication for permissions
