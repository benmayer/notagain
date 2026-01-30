/// User model representing an authenticated user
/// 
/// This model holds the user's profile information and authentication state.
library;

class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final bool onboardingCompleted;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    this.lastSignInAt,
    this.onboardingCompleted = false,
  });

  /// Create a copy of this user with optional fields replaced
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? onboardingCompleted,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, onboardingCompleted: $onboardingCompleted)';
  }
}

/// Request model for user signup
class SignupRequest {
  final String email;
  final String password;
  final String? fullName;

  SignupRequest({
    required this.email,
    required this.password,
    this.fullName,
  });
}

/// Request model for user login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });
}

/// Response model for authentication operations
class AuthResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? error;

  AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.error,
  });

  /// Check if the response indicates success
  bool get isSuccess => success;

  factory AuthResponse.success({
    required User user,
    String? message,
  }) {
    return AuthResponse(
      success: true,
      user: user,
      message: message ?? 'Authentication successful',
    );
  }

  factory AuthResponse.failure({
    required String error,
  }) {
    return AuthResponse(
      success: false,
      error: error,
      message: error,
    );
  }
}
