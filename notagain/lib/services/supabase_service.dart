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
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../models/blocking_rule.dart';
import '../models/result.dart';

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
  Future<Result<app_user.User>> signup({
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

        final user = app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          fullName: fullName,
          createdAt: _parseDateTime(response.user!.createdAt),
        );
        return Result.success(user);
      }
      debugPrint('❌ SupabaseService: Signup returned null user');
      return Result.failure(
        AppError(message: 'Signup failed: No user returned'),
      );
    } on AuthException catch (e) {
      debugPrint('❌ SupabaseService: Signup auth exception: ${e.message}');
      return Result.failure(
        AppError(
          message: e.message,
          exception: e,
          code: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
          errorCode: e.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('❌ SupabaseService: Signup exception: $e');
      return Result.failure(AppError.fromException(e, message: 'Signup failed'));
    }
  }

  /// Login with email and password
  Future<Result<app_user.User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          createdAt: _parseDateTime(response.user!.createdAt),
        );
        return Result.success(user);
      }
      return Result.failure(
        AppError(message: 'Login failed: No user returned'),
      );
    } on AuthException catch (e) {
      debugPrint('❌ SupabaseService: Login auth exception: ${e.message}');
      return Result.failure(
        AppError(
          message: e.message,
          exception: e,
          code: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
          errorCode: e.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('❌ SupabaseService: Login exception: $e');
      return Result.failure(AppError.fromException(e, message: 'Login failed'));
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
      debugPrint('🔐 SupabaseService: Starting Apple Sign-In');
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );
      
      final authUser = _client.auth.currentUser;
      if (authUser != null) {
        debugPrint('✅ SupabaseService: Apple Sign-In successful for ${authUser.email}');
        return app_user.User(
          id: authUser.id,
          email: authUser.email ?? '',
          createdAt: _parseDateTime(authUser.createdAt),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ SupabaseService: Apple Sign-In failed: $e');
      throw Exception('Apple Sign-In failed: $e');
    }
  }

  /// Sign in with Google
  Future<app_user.User?> signInWithGoogle() async {
    try {
      debugPrint('🔐 SupabaseService: Starting Google Sign-In');
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      
      final authUser = _client.auth.currentUser;
      if (authUser != null) {
        debugPrint('✅ SupabaseService: Google Sign-In successful for ${authUser.email}');
        return app_user.User(
          id: authUser.id,
          email: authUser.email ?? '',
          createdAt: _parseDateTime(authUser.createdAt),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ SupabaseService: Google Sign-In failed: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ============================================================================
  // USER PROFILE METHODS
  // ============================================================================

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      debugPrint('📋 SupabaseService: Fetching profile for user $userId');
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        debugPrint('✅ SupabaseService: Profile found');
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('❌ SupabaseService: Get profile failed: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      debugPrint('✏️  SupabaseService: Updating profile for user $userId');
      await _client.from('profiles').update({
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      debugPrint('✅ SupabaseService: Profile updated successfully');
    } catch (e) {
      debugPrint('❌ SupabaseService: Update profile failed: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // ============================================================================
  // BLOCKING RULES METHODS
  // ============================================================================

  /// Create a new blocking rule
  Future<BlockingRule> createBlockingRule({
    required String appName,
    String? appBundleId,
    String? schedule,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('➕ SupabaseService: Creating blocking rule for $appName');
      final response = await _client.from('blocking_rules').insert({
        'user_id': userId,
        'app_name': appName,
        'app_bundle_id': appBundleId,
        'schedule': schedule,
        'enabled': true,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final rule = BlockingRule.fromJson(response);
      debugPrint('✅ SupabaseService: Blocking rule created: ${rule.id}');
      return rule;
    } catch (e) {
      debugPrint('❌ SupabaseService: Create blocking rule failed: $e');
      throw Exception('Failed to create blocking rule: $e');
    }
  }

  /// Get all blocking rules for the current user
  Future<List<BlockingRule>> getBlockingRules() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('📋 SupabaseService: Fetching blocking rules for user $userId');
      final response = await _client
          .from('blocking_rules')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final rules = (response as List<dynamic>)
          .map((r) => BlockingRule.fromJson(r as Map<String, dynamic>))
          .toList();
      
      debugPrint('✅ SupabaseService: Found ${rules.length} blocking rules');
      return rules;
    } catch (e) {
      debugPrint('❌ SupabaseService: Get blocking rules failed: $e');
      throw Exception('Failed to get blocking rules: $e');
    }
  }

  /// Update a blocking rule
  Future<BlockingRule> updateBlockingRule({
    required String ruleId,
    String? appName,
    String? schedule,
    bool? enabled,
  }) async {
    try {
      debugPrint('✏️  SupabaseService: Updating blocking rule $ruleId');
      final updates = <String, dynamic>{
        if (appName != null) 'app_name': appName,
        if (schedule != null) 'schedule': schedule,
        if (enabled != null) 'enabled': enabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('blocking_rules')
          .update(updates)
          .eq('id', ruleId)
          .select()
          .single();

      final rule = BlockingRule.fromJson(response);
      debugPrint('✅ SupabaseService: Blocking rule updated');
      return rule;
    } catch (e) {
      debugPrint('❌ SupabaseService: Update blocking rule failed: $e');
      throw Exception('Failed to update blocking rule: $e');
    }
  }

  /// Delete a blocking rule
  Future<void> deleteBlockingRule(String ruleId) async {
    try {
      debugPrint('🗑️  SupabaseService: Deleting blocking rule $ruleId');
      await _client.from('blocking_rules').delete().eq('id', ruleId);
      debugPrint('✅ SupabaseService: Blocking rule deleted');
    } catch (e) {
      debugPrint('❌ SupabaseService: Delete blocking rule failed: $e');
      throw Exception('Failed to delete blocking rule: $e');
    }
  }

  /// Toggle a blocking rule enabled/disabled
  Future<BlockingRule> toggleBlockingRule(String ruleId, bool enabled) async {
    try {
      debugPrint('🔄 SupabaseService: Toggling blocking rule $ruleId to $enabled');
      final response = await _client
          .from('blocking_rules')
          .update({
            'enabled': enabled,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ruleId)
          .select()
          .single();

      final rule = BlockingRule.fromJson(response);
      debugPrint('✅ SupabaseService: Blocking rule toggled');
      return rule;
    } catch (e) {
      debugPrint('❌ SupabaseService: Toggle blocking rule failed: $e');
      throw Exception('Failed to toggle blocking rule: $e');
    }
  }

  // ============================================================================
  // ANALYTICS METHODS
  // ============================================================================

  /// Log app usage
  Future<void> logAppUsage({
    required String appName,
    required Duration duration,
    DateTime? date,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final usageDate = date ?? DateTime.now();
      final dateKey = usageDate.toIso8601String().split('T').first;

      debugPrint('📊 SupabaseService: Logging usage for $appName (${duration.inMinutes}m)');

      // Check if a record already exists for this app/date
      final existing = await _client
          .from('app_usage')
          .select('duration_seconds')
          .eq('user_id', userId)
          .eq('app_name', appName)
          .eq('date', dateKey)
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        final currentSeconds = existing['duration_seconds'] as int? ?? 0;
        await _client
            .from('app_usage')
            .update({
              'duration_seconds': currentSeconds + duration.inSeconds,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('app_name', appName)
            .eq('date', dateKey);
      } else {
        // Insert new record
        await _client.from('app_usage').insert({
          'user_id': userId,
          'app_name': appName,
          'duration_seconds': duration.inSeconds,
          'date': dateKey,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      debugPrint('✅ SupabaseService: App usage logged');
    } catch (e) {
      debugPrint('❌ SupabaseService: Log app usage failed: $e');
      // Don't throw for analytics - app should continue if logging fails
    }
  }

  /// Log a blocked attempt
  Future<void> logBlockedAttempt({
    required String ruleId,
    required String appName,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('🚫 SupabaseService: Logging blocked attempt for $appName');
      await _client.from('blocked_attempts').insert({
        'user_id': userId,
        'rule_id': ruleId,
        'app_name': appName,
        'blocked_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ SupabaseService: Blocked attempt logged');
    } catch (e) {
      debugPrint('❌ SupabaseService: Log blocked attempt failed: $e');
      // Don't throw for analytics - app should continue if logging fails
    }
  }

  /// Get user analytics for a time period
  Future<Map<String, dynamic>> getUserAnalytics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('📈 SupabaseService: Fetching analytics for $userId');
      
      // Get total app usage
      final usageData = await _client
          .from('app_usage')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T').first)
          .lte('date', endDate.toIso8601String().split('T').first);

      // Get blocked attempts
      final blockedData = await _client
          .from('blocked_attempts')
          .select()
          .eq('user_id', userId)
          .gte('blocked_at', startDate.toIso8601String())
          .lte('blocked_at', endDate.toIso8601String());

      debugPrint('✅ SupabaseService: Analytics fetched');
      return {
        'usage': usageData,
        'blocked_attempts': blockedData,
      };
    } catch (e) {
      debugPrint('❌ SupabaseService: Get analytics failed: $e');
      throw Exception('Failed to get analytics: $e');
    }
  }
}
