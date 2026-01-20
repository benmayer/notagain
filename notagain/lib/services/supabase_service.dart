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

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;
  bool _initialized = false;

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
    if (!_initialized) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      _client = Supabase.instance.client;
      _initialized = true;
    }
  }

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  /// Get current authenticated user
  app_user.User? get currentUser {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    
    return app_user.User(
      id: authUser.id,
      email: authUser.email ?? '',
      createdAt: _parseDateTime(authUser.createdAt),
    );
  }

  /// Helper to parse DateTime from any type
  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Sign up with email and password
  Future<app_user.User?> signup({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      debugPrint('🔐 SupabaseService: Attempting signup for $email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('✅ SupabaseService: User created in auth.users: ${response.user!.id}');
        // Create user profile in database
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );

        return app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          fullName: fullName,
          createdAt: _parseDateTime(response.user!.createdAt),
        );
      }
      debugPrint('❌ SupabaseService: Signup returned null user');
      return null;
    } catch (e) {
      debugPrint('❌ SupabaseService: Signup exception: $e');
      throw Exception('Signup failed: $e');
    }
  }

  /// Login with email and password
  Future<app_user.User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          createdAt: _parseDateTime(response.user!.createdAt),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Create user profile in database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    try {
      debugPrint('📝 SupabaseService: Creating profile for user $userId');
      await _client.from('profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ SupabaseService: Profile created successfully');
    } catch (e) {
      // Profile might already exist, or table doesn't exist yet
      // This is okay for MVP - we'll handle it gracefully
      debugPrint('⚠️  SupabaseService: Profile creation warning: $e');
    }
  }

  /// Sign in with Apple
  Future<app_user.User?> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );

      if (response) {
        return currentUser;
      }
      return null;
    } catch (e) {
      throw Exception('Apple Sign-In failed: $e');
    }
  }

  /// Sign in with Google
  Future<app_user.User?> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      if (response) {
        return currentUser;
      }
      return null;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // TODO: Implement additional methods
  // - getUserProfile(userId)
  // - updateUserProfile(userId, updates)
  // - createBlockingRule(rule)
  // - updateBlockingRule(ruleId, updates)
  // - deleteBlockingRule(ruleId)
  // - trackAppUsage(appId, duration)
  // - logBlockedAttempt(appId, timestamp)
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
