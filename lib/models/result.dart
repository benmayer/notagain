/// Shared result type for async operations across the app
/// 
/// Provides a consistent success/failure payload with structured error handling.
library;

/// Generic result wrapper for service operations
class Result<T> {
  final T? data;
  final AppError? error;

  const Result({this.data, this.error});

  /// Creates a successful result
  factory Result.success(T data) => Result(data: data, error: null);

  /// Creates a failed result
  factory Result.failure(AppError error) => Result(data: null, error: error);

  bool get isSuccess => error == null && data != null;
  bool get isFailure => !isSuccess;
}

/// Structured error type for consistent error handling
class AppError {
  final String message;
  final Object? exception;
  final int? code;
  final String? errorCode;

  const AppError({
    required this.message,
    this.exception,
    this.code,
    this.errorCode,
  });

  factory AppError.fromException(Object exception, {String? message}) {
    return AppError(
      message: message ?? exception.toString(),
      exception: exception,
      code: null,
      errorCode: null,
    );
  }

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}
