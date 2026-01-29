/// Authentication Provider
/// 
/// Manages authentication state including:
/// - User session
/// - Login/signup/logout operations
/// - Auth status (authenticated, loading, error)
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/logging/app_logger.dart';
import '../models/user.dart';
import '../models/result.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  final SupabaseService _supabaseService = SupabaseService();

  /// Initialize the auth provider
  /// Checks for existing session
  Future<void> init() async {
    await _checkExistingSession();
  }

  /// Check if there's an existing authenticated session
  Future<void> _checkExistingSession() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = _supabaseService.currentUser;
      if (currentUser != null) {
        _user = currentUser;
        _isAuthenticated = true;
        
        // Fetch profile to get onboarding_completed status
        try {
          final profile = await _supabaseService.getUserProfile(currentUser.id);
          AppLogger.info('Profile loaded: $profile', tag: 'AuthProvider');
          if (profile != null) {
            final onboardingCompleted = profile['onboarding_completed'] as bool? ?? false;
            final fullName = profile['full_name'] as String?;
            final avatarUrl = profile['avatar_url'] as String?;
            
            AppLogger.info('Profile data: onboardingCompleted=$onboardingCompleted, fullName=$fullName', tag: 'AuthProvider');
            
            _user = currentUser.copyWith(
              onboardingCompleted: onboardingCompleted,
              fullName: fullName,
              avatarUrl: avatarUrl,
            );
            
            AppLogger.info('User updated with onboarding status: ${_user?.onboardingCompleted}', tag: 'AuthProvider');
          }
        } catch (e) {
          AppLogger.warning('Failed to load profile data: $e', tag: 'AuthProvider');
          // Continue with basic user info if profile fetch fails
        }
        
        AppLogger.info('Restored existing session for ${currentUser.email}', tag: 'AuthProvider');
      } else {
        AppLogger.info('No existing session found (normal on first launch)', tag: 'AuthProvider');
      }
    } catch (e) {
      // It's normal to have no session on first launch or after logout
      AppLogger.debug('Session check result: $e (normal)', tag: 'AuthProvider');
      _error = null; // Don't show this as an error to the user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<Result<User>> signup({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Starting signup for $email', tag: 'AuthProvider');
      final result = await _supabaseService.signup(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (result.isSuccess && result.data != null) {
        // Ensure onboardingCompleted is false for new signups
        _user = result.data!.copyWith(onboardingCompleted: false);
        _isAuthenticated = true;
        AppLogger.info('Signup successful for $email', tag: 'AuthProvider');
        notifyListeners();
        return Result.success(_user!);
      } else {
        _error = result.error?.message ?? 'Signup failed';
        AppLogger.warning('Signup failed: $_error', tag: 'AuthProvider');
        notifyListeners();
        return Result.failure(
          result.error ?? AppError(message: 'Signup failed'),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Starting login for $email', tag: 'AuthProvider');
      final result = await _supabaseService.login(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.data != null) {
        _user = result.data;
        _isAuthenticated = true;
        
        // Fetch profile to get onboarding_completed status
        try {
          final profile = await _supabaseService.getUserProfile(_user!.id);
          if (profile != null) {
            final onboardingCompleted = profile['onboarding_completed'] as bool? ?? false;
            final fullName = profile['full_name'] as String?;
            final avatarUrl = profile['avatar_url'] as String?;
            
            _user = _user!.copyWith(
              onboardingCompleted: onboardingCompleted,
              fullName: fullName,
              avatarUrl: avatarUrl,
            );
          }
        } catch (e) {
          AppLogger.warning('Failed to load profile data during login: $e', tag: 'AuthProvider');
          // Continue with basic user info if profile fetch fails
        }
        
        AppLogger.info('Login successful for $email', tag: 'AuthProvider');
        debugPrint('🔍 [AUTH] Login success - Building result object');
        debugPrint('   User: $_user');
        debugPrint('   User.onboardingCompleted: ${_user?.onboardingCompleted}');
        notifyListeners();
        final successResult = Result.success(_user!);
        debugPrint('🔍 [AUTH] Result.isSuccess: ${successResult.isSuccess}');
        debugPrint('   Result.data: ${successResult.data}');
        debugPrint('   Result.data?.onboardingCompleted: ${successResult.data?.onboardingCompleted}');
        return successResult;
      } else {
        _error = result.error?.message ?? 'Login failed';
        AppLogger.warning('Login failed: $_error', tag: 'AuthProvider');
        notifyListeners();
        return Result.failure(
          result.error ?? AppError(message: 'Login failed'),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Apple
  /// Returns Result&lt;User&gt; with structured error handling
  Future<Result<User>> signInWithApple() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Starting Apple Sign-In', tag: 'AuthProvider');
      final result = await _supabaseService.signInWithApple();

      if (result.isSuccess && result.data != null) {
        _user = result.data;
        _isAuthenticated = true;
        AppLogger.info('Apple Sign-In successful for ${result.data!.email}', tag: 'AuthProvider');
        notifyListeners();
        return Result.success(_user!);
      } else {
        _error = result.error?.message ?? 'Apple Sign-In failed';
        AppLogger.warning('Apple Sign-In failed: $_error', tag: 'AuthProvider');
        notifyListeners();
        return Result.failure(
          result.error ?? AppError(message: 'Apple Sign-In failed'),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  /// Returns Result&lt;User&gt; with structured error handling
  Future<Result<User>> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Starting Google Sign-In', tag: 'AuthProvider');
      final result = await _supabaseService.signInWithGoogle();

      if (result.isSuccess && result.data != null) {
        _user = result.data;
        _isAuthenticated = true;
        AppLogger.info('Google Sign-In successful for ${result.data!.email}', tag: 'AuthProvider');
        notifyListeners();
        return Result.success(_user!);
      } else {
        _error = result.error?.message ?? 'Google Sign-In failed';
        AppLogger.warning('Google Sign-In failed: $_error', tag: 'AuthProvider');
        notifyListeners();
        return Result.failure(
          result.error ?? AppError(message: 'Google Sign-In failed'),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out the current user
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      AppLogger.info('Starting logout for ${_user?.email}', tag: 'AuthProvider');
      await _supabaseService.logout();
      
      _user = null;
      _isAuthenticated = false;
      _error = null;
      AppLogger.info('Logout successful', tag: 'AuthProvider');
    } catch (e) {
      _error = 'Logout failed: $e';
      AppLogger.error('Logout failed: $e', tag: 'AuthProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user data (used after onboarding completion)
  void updateUser(User updatedUser) {
    _user = updatedUser;
    AppLogger.info('User data updated: onboarding=${updatedUser.onboardingCompleted}', tag: 'AuthProvider');
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
