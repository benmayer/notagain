/// Supabase Service
/// 
/// Centralized service for all Supabase backend interactions:
/// - Authentication (sign up, login, logout, session management)
/// - User profile data management
/// - Blocking rules CRUD operations
/// - App usage analytics tracking
/// - Blocked attempt logging
/// 
/// This service acts as the bridge between the app and Supabase backend,
/// abstracting away Supabase SDK details and providing a clean API for
/// other parts of the application.

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Initialize Supabase client
  /// Call this in main() before running the app
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // TODO: Implement authentication methods
  // - signUp(email, password)
  // - signIn(email, password)
  // - signInWithApple()
  // - signInWithGoogle()
  // - signOut()
  // - resetPassword(email)

  // TODO: Implement user profile methods
  // - getUserProfile(userId)
  // - updateUserProfile(userData)
  // - deleteAccount()

  // TODO: Implement blocking rules methods
  // - createBlockingRule(rule)
  // - getBlockingRules(userId)
  // - updateBlockingRule(ruleId, updates)
  // - deleteBlockingRule(ruleId)

  // TODO: Implement analytics methods
  // - logAppUsage(appName, duration)
  // - logBlockedAttempt(appName, ruleName)
  // - getUserAnalytics(userId, period)

  // TODO: Implement database schema interaction
  // Tables to set up in Supabase:
  // - users: id, email, created_at, updated_at
  // - profiles: id, user_id, full_name, avatar_url
  // - blocking_rules: id, user_id, app_name/url, schedule, created_at
  // - app_usage: id, user_id, app_name, duration, date
  // - blocked_attempts: id, user_id, rule_id, blocked_at
}
