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

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
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
      AppLogger.info('Attempting signup for $email', tag: 'SupabaseService');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        AppLogger.info('User created in auth.users: ${response.user!.id}', tag: 'SupabaseService');
        // Create user profile in database (onboarding not completed for email/password signup)
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          onboardingCompleted: false,
        );

        final user = app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          fullName: fullName,
          createdAt: _parseDateTime(response.user!.createdAt),
          onboardingCompleted: false,
        );
        return Result.success(user);
      }
      AppLogger.warning('Signup returned null user', tag: 'SupabaseService');
      return Result.failure(
        AppError(message: 'Signup failed: No user returned'),
      );
    } on AuthException catch (e) {
      AppLogger.error('Signup auth exception: ${e.message}', tag: 'SupabaseService');
      return Result.failure(
        AppError(
          message: e.message,
          exception: e,
          code: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
          errorCode: e.statusCode,
        ),
      );
    } catch (e) {
      AppLogger.error('Signup exception: $e', tag: 'SupabaseService');
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
      AppLogger.error('Login auth exception: ${e.message}', tag: 'SupabaseService');
      return Result.failure(
        AppError(
          message: e.message,
          exception: e,
          code: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
          errorCode: e.statusCode,
        ),
      );
    } catch (e) {
      AppLogger.error('Login exception: $e', tag: 'SupabaseService');
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
    String? avatarUrl,
    bool onboardingCompleted = false,
  }) async {
    try {
      AppLogger.info('Creating profile for user $userId', tag: 'SupabaseService');
      await _client.from('profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'onboarding_completed': onboardingCompleted,
        'created_at': DateTime.now().toIso8601String(),
      });
      AppLogger.info('Profile created successfully', tag: 'SupabaseService');
    } catch (e) {
      // Profile might already exist, or table doesn't exist yet
      // This is okay for MVP - we'll handle it gracefully
      AppLogger.warning('Profile creation warning: $e', tag: 'SupabaseService');
    }
  }

  /// Sign in with Apple
  /// Returns Result<User> with structured error handling
  Future<Result<app_user.User>> signInWithApple() async {
    try {
      AppLogger.info('Starting Apple Sign-In', tag: 'SupabaseService');
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );
      
      final authUser = _client.auth.currentUser;
      if (authUser != null) {
        AppLogger.info('Apple Sign-In successful for ${authUser.email}', tag: 'SupabaseService');
        
        // Extract SSO metadata
        final fullName = authUser.userMetadata?['full_name'] as String?;
        final avatarUrl = authUser.userMetadata?['picture'] as String?;
        
        // If both name and avatar provided, onboarding is complete
        final onboardingCompleted = fullName != null && avatarUrl != null;
        
        // Create user profile in database if it doesn't exist
        await _createUserProfile(
          userId: authUser.id,
          email: authUser.email ?? '',
          fullName: fullName,
          avatarUrl: avatarUrl,
          onboardingCompleted: onboardingCompleted,
        );
        
        AppLogger.info(
          'Apple SSO profile created: name=$fullName, avatar=${avatarUrl != null}, onboarding=$onboardingCompleted',
          tag: 'SupabaseService',
        );
        
        return Result.success(
          app_user.User(
            id: authUser.id,
            email: authUser.email ?? '',
            fullName: fullName,
            avatarUrl: avatarUrl,
            createdAt: _parseDateTime(authUser.createdAt),
            onboardingCompleted: onboardingCompleted,
          ),
        );
      }
      AppLogger.warning('Apple Sign-In returned null user', tag: 'SupabaseService');
      return Result.failure(
        AppError(message: 'Apple Sign-In failed: No user returned'),
      );
    } on AuthException catch (e) {
      AppLogger.error('Apple Sign-In auth exception: ${e.message}', tag: 'SupabaseService');
      return Result.failure(
        AppError(
          message: e.message,
          exception: e,
          code: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
          errorCode: e.statusCode,
        ),
      );
    } catch (e) {
      AppLogger.error('Apple Sign-In exception: $e', tag: 'SupabaseService');
      return Result.failure(AppError.fromException(e, message: 'Apple Sign-In failed'));
    }
  }

  /// Sign in with Google
  /// Returns Result<User> with structured error handling
  Future<Result<app_user.User>> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-In', tag: 'SupabaseService');
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      
      final authUser = _client.auth.currentUser;
      if (authUser != null) {
        AppLogger.info('Google Sign-In successful for ${authUser.email}', tag: 'SupabaseService');
        
        // Extract SSO metadata
        final fullName = authUser.userMetadata?['full_name'] as String?;
        final avatarUrl = authUser.userMetadata?['picture'] as String?;
        
        // If both name and avatar provided, onboarding is complete
        final onboardingCompleted = fullName != null && avatarUrl != null;
        
        // Create user profile in database if it doesn't exist
        await _createUserProfile(
          userId: authUser.id,
          email: authUser.email ?? '',
          fullName: fullName,
          avatarUrl: avatarUrl,
          onboardingCompleted: onboardingCompleted,
        );
        
        AppLogger.info(
          'Google SSO profile created: name=$fullName, avatar=${avatarUrl != null}, onboarding=$onboardingCompleted',
          tag: 'SupabaseService',
        );
        
        return Result.success(
          app_user.User(
            id: authUser.id,
            email: authUser.email ?? '',
            fullName: fullName,
            avatarUrl: avatarUrl,
            createdAt: _parseDateTime(authUser.createdAt),
            onboardingCompleted: onboardingCompleted,
          ),
        );
      }
      AppLogger.warning('Google Sign-In returned null user', tag: 'SupabaseService');
      return Result.failure(
        AppError(message: 'Google Sign-In failed: No user returned'),
      );
    } on AuthException catch (e) {
      AppLogger.error('Google Sign-In auth exception: ${e.message}', tag: 'SupabaseService');
      return Result.failure(
        AppError(
          message: e.message,
          exception: e,
          code: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
          errorCode: e.statusCode,
        ),
      );
    } catch (e) {
      AppLogger.error('Google Sign-In exception: $e', tag: 'SupabaseService');
      return Result.failure(AppError.fromException(e, message: 'Google Sign-In failed'));
    }
  }

  // ============================================================================
  // USER PROFILE METHODS
  // ============================================================================

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      AppLogger.info('Fetching profile for user $userId', tag: 'SupabaseService');
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        AppLogger.info('Profile found', tag: 'SupabaseService');
        return response;
      }
      return null;
    } catch (e) {
      AppLogger.error('Get profile failed: $e', tag: 'SupabaseService');
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
      AppLogger.info('Updating profile for user $userId', tag: 'SupabaseService');
      await _client.from('profiles').update({
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      }).eq('id', userId);
      
      AppLogger.info('Profile updated successfully', tag: 'SupabaseService');
    } catch (e) {
      AppLogger.error('Update profile failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update onboarding completion status
  Future<void> updateOnboardingStatus({
    required String userId,
    required bool completed,
  }) async {
    try {
      AppLogger.info(
        'Updating onboarding status for user $userId: $completed',
        tag: 'SupabaseService',
      );
      await _client.from('profiles').update({
        'onboarding_completed': completed,
      }).eq('id', userId);
      
      AppLogger.info('Onboarding status updated successfully', tag: 'SupabaseService');
    } catch (e) {
      AppLogger.error('Update onboarding status failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to update onboarding status: $e');
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

      AppLogger.info('Creating blocking rule for $appName', tag: 'SupabaseService');
      final response = await _client.from('blocking_rules').insert({
        'user_id': userId,
        'app_name': appName,
        'app_bundle_id': appBundleId,
        'schedule': schedule,
        'enabled': true,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final rule = BlockingRule.fromJson(response);
      AppLogger.info('Blocking rule created: ${rule.id}', tag: 'SupabaseService');
      return rule;
    } catch (e) {
      AppLogger.error('Create blocking rule failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to create blocking rule: $e');
    }
  }

  /// Get all blocking rules for the current user
  Future<List<BlockingRule>> getBlockingRules() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      AppLogger.info('Fetching blocking rules for user $userId', tag: 'SupabaseService');
      final response = await _client
          .from('blocking_rules')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final rules = (response as List<dynamic>)
          .map((r) => BlockingRule.fromJson(r as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Found ${rules.length} blocking rules', tag: 'SupabaseService');
      return rules;
    } catch (e) {
      AppLogger.error('Get blocking rules failed: $e', tag: 'SupabaseService');
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
      AppLogger.info('Updating blocking rule $ruleId', tag: 'SupabaseService');
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
      AppLogger.info('Blocking rule updated', tag: 'SupabaseService');
      return rule;
    } catch (e) {
      AppLogger.error('Update blocking rule failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to update blocking rule: $e');
    }
  }

  /// Delete a blocking rule
  Future<void> deleteBlockingRule(String ruleId) async {
    try {
      AppLogger.info('Deleting blocking rule $ruleId', tag: 'SupabaseService');
      await _client.from('blocking_rules').delete().eq('id', ruleId);
      AppLogger.info('Blocking rule deleted', tag: 'SupabaseService');
    } catch (e) {
      AppLogger.error('Delete blocking rule failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to delete blocking rule: $e');
    }
  }

  /// Toggle a blocking rule enabled/disabled
  Future<BlockingRule> toggleBlockingRule(String ruleId, bool enabled) async {
    try {
      AppLogger.info('Toggling blocking rule $ruleId to $enabled', tag: 'SupabaseService');
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
      AppLogger.info('Blocking rule toggled', tag: 'SupabaseService');
      return rule;
    } catch (e) {
      AppLogger.error('Toggle blocking rule failed: $e', tag: 'SupabaseService');
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

      AppLogger.info('Logging usage for $appName (${duration.inMinutes}m)', tag: 'SupabaseService');

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

      AppLogger.info('App usage logged', tag: 'SupabaseService');
    } catch (e) {
      AppLogger.error('Log app usage failed: $e', tag: 'SupabaseService');
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

      AppLogger.info('Logging blocked attempt for $appName', tag: 'SupabaseService');
      await _client.from('blocked_attempts').insert({
        'user_id': userId,
        'rule_id': ruleId,
        'app_name': appName,
        'blocked_at': DateTime.now().toIso8601String(),
      });

      AppLogger.info('Blocked attempt logged', tag: 'SupabaseService');
    } catch (e) {
      AppLogger.error('Log blocked attempt failed: $e', tag: 'SupabaseService');
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
      AppLogger.info('Fetching analytics for $userId', tag: 'SupabaseService');
      
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

      AppLogger.info('Analytics fetched', tag: 'SupabaseService');
      return {
        'usage': usageData,
        'blocked_attempts': blockedData,
      };
    } catch (e) {
      AppLogger.error('Get analytics failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to get analytics: $e');
    }
  }

  // ============================================================================
  // STORAGE METHODS
  // ============================================================================

  /// Upload avatar image to Supabase Storage
  /// Requires 'avatars' bucket to exist in Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      AppLogger.info('Uploading avatar for user $userId', tag: 'SupabaseService');
      
      final file = File(filePath);
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$userId/$fileName';

      // Upload to storage
      await _client.storage.from('avatars').upload(
        storagePath,
        file,
      );

      // Get public URL
      final publicUrl = _client.storage.from('avatars').getPublicUrl(storagePath);
      
      AppLogger.info('Avatar uploaded successfully: $publicUrl', tag: 'SupabaseService');
      return publicUrl;
    } catch (e) {
      AppLogger.error('Avatar upload failed: $e', tag: 'SupabaseService');
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
