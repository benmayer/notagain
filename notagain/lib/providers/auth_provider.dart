/// Authentication Provider
/// 
/// Manages authentication state including:
/// - User session
/// - Login/signup/logout operations
/// - Auth status (authenticated, loading, error)

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
        _user = User(
          id: currentUser.id,
          email: currentUser.email ?? '',
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Failed to check session: $e';
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

      // TODO: Implement Supabase signup
      // This will be connected to SupabaseService.signup() once implemented
      
      _error = 'Signup not yet implemented';
      notifyListeners();
      return AuthResponse.failure(error: _error!);
    } catch (e) {
      _error = 'Signup failed: $e';
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

      // TODO: Implement Supabase login
      // This will be connected to SupabaseService.login() once implemented

      _error = 'Login not yet implemented';
      notifyListeners();
      return AuthResponse.failure(error: _error!);
    } catch (e) {
      _error = 'Login failed: $e';
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

      // TODO: Implement Apple Sign-In with Supabase

      _error = 'Apple Sign-In not yet implemented';
      notifyListeners();
      return AuthResponse.failure(error: _error!);
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

      // TODO: Implement Google Sign-In with Supabase

      _error = 'Google Sign-In not yet implemented';
      notifyListeners();
      return AuthResponse.failure(error: _error!);
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

      // TODO: Implement Supabase logout
      
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
