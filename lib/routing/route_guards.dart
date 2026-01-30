/// Routing Guards
///
/// Guard functions for protecting routes based on authentication and onboarding status
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Guard that checks if user has completed onboarding
/// 
/// Returns:
/// - `/onboarding` if authenticated but onboarding not complete
/// - `null` if onboarding is complete (allow access)
/// - `null` if not authenticated (let auth guard handle it)
String? requiresOnboardingCompletion(BuildContext context, GoRouterState state) {
  final authProvider = context.read<AuthProvider>();
  
  // Not authenticated - let auth guard handle redirect
  if (!authProvider.isAuthenticated) {
    return null;
  }
  
  final user = authProvider.user;
  
  // Authenticated but onboarding not complete
  if (user != null && !user.onboardingCompleted) {
    // Don't redirect if already on onboarding route
    if (!state.matchedLocation.startsWith('/onboarding')) {
      return '/onboarding';
    }
  }
  
  return null; // Allow access
}

/// Guard that checks if user is authenticated
/// 
/// Returns:
/// - `/` (welcome screen) if not authenticated
/// - `null` if authenticated (allow access)
String? requiresAuthentication(BuildContext context, GoRouterState state) {
  final authProvider = context.read<AuthProvider>();
  
  if (!authProvider.isAuthenticated) {
    return '/';
  }
  
  return null; // Allow access
}
