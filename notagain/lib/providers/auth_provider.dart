/// Authentication Provider
/// 
/// Manages authentication state including:
/// - User session
/// - Login/signup/logout operations
/// - Auth status (authenticated, loading, error)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
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
        debugPrint('✅ AuthProvider: Restored existing session for ${currentUser.email}');
      } else {
        debugPrint('ℹ️  AuthProvider: No existing session found (this is normal on first launch)');
      }
    } catch (e) {
      // It's normal to have no session on first launch or after logout
      debugPrint('ℹ️  AuthProvider: Session check result: $e (this is normal)');
      _error = null; // Don't show this as an error to the user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signup({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🔐 AuthProvider: Starting signup for $email');
      final user = await _supabaseService.signup(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        debugPrint('✅ AuthProvider: Signup successful for $email');
        notifyListeners();
        return AuthResponse.success(user: user);
      } else {
        _error = 'Signup failed: Unknown error';
        debugPrint('❌ AuthProvider: Signup returned null for $email');
        notifyListeners();
        return AuthResponse.failure(error: _error!);
      }
    } catch (e) {
      _error = 'Signup failed: $e';
      debugPrint('❌ AuthProvider: Signup exception: $e');
      notifyListeners();
      return AuthResponse.failure(error: _error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('🔐 AuthProvider: Starting login for $email');
      final user = await _supabaseService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        debugPrint('✅ AuthProvider: Login successful for $email');
        notifyListeners();
        return AuthResponse.success(user: user);
      } else {
        _error = 'Login failed: Unknown error';
        debugPrint('❌ AuthProvider: Login returned null for $email');
        notifyListeners();
        return AuthResponse.failure(error: _error!);
      }
    } catch (e) {
      _error = 'Login failed: $e';
      debugPrint('❌ AuthProvider: Login exception: $e');
      notifyListeners();
      return AuthResponse.failure(error: _error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _supabaseService.signInWithApple();

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        notifyListeners();
        return AuthResponse.success(user: user);
      } else {
        _error = 'Apple Sign-In failed';
        notifyListeners();
        return AuthResponse.failure(error: _error!);
      }
    } catch (e) {
      _error = 'Apple Sign-In failed: $e';
      notifyListeners();
      return AuthResponse.failure(error: _error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _supabaseService.signInWithGoogle();

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        notifyListeners();
        return AuthResponse.success(user: user);
      } else {
        _error = 'Google Sign-In failed';
        notifyListeners();
        return AuthResponse.failure(error: _error!);
      }
    } catch (e) {
      _error = 'Google Sign-In failed: $e';
      notifyListeners();
      return AuthResponse.failure(error: _error!);
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

      await _supabaseService.logout();
      
      _user = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
