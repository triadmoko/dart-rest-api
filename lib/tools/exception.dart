/// Custom exception for application errors.
///
/// Used throughout the application to provide consistent error messages.
class AppException implements Exception {
  /// The error message.
  final String message;

  /// The original exception that caused this error, if any.
  final Exception? originalError;

  AppException(this.message, [this.originalError]);

  @override
  String toString() => 'AppException: $message';
}

/// Mixin for generic error handling.
///
/// Provides [safeExecute] methods to wrap operations with try-catch.
mixin ErrorHandler {
  /// Wraps a synchronous operation with error handling.
  ///
  /// Converts any caught exception into an [AppException].
  T safeExecute<T>(T Function() action, {String? errorMessage}) {
    try {
      return action();
    } catch (e) {
      final message = errorMessage ?? 'An error occurred';
      throw AppException(
        '$message: $e',
        e is Exception ? e : null,
      );
    }
  }

  /// Wraps an asynchronous operation with error handling.
  ///
  /// Converts any caught exception into an [AppException].
  Future<T> safeExecuteAsync<T>(
    Future<T> Function() action, {
    String? errorMessage,
  }) async {
    try {
      return await action();
    } catch (e) {
      final message = errorMessage ?? 'An error occurred';
      throw AppException(
        '$message: $e',
        e is Exception ? e : null,
      );
    }
  }
}