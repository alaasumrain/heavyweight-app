/// Result pattern implementation following Flutter architecture best practices
/// Provides type-safe error handling for async operations
sealed class Result<T> {
  const Result();
  
  /// Create a successful result
  static Result<T> success<T>(T value) => Ok<T>(value);
  
  /// Create an error result  
  static Result<T> failure<T>(Exception error) => Error<T>(error);
  
  /// Transform the result value if successful
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<T>(value: final value) => Ok(transform(value)),
      Error<T>(error: final error) => Error(error),
    };
  }
  
  /// Chain async operations
  Future<Result<R>> flatMap<R>(Future<Result<R>> Function(T value) transform) async {
    return switch (this) {
      Ok<T>(value: final value) => await transform(value),
      Error<T>(error: final error) => Error(error),
    };
  }
  
  /// Get value or default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Ok<T>(value: final value) => value,
      Error<T>() => defaultValue,
    };
  }
  
  /// Get value or null
  T? getOrNull() {
    return switch (this) {
      Ok<T>(value: final value) => value,
      Error<T>() => null,
    };
  }
  
  /// Check if result is successful
  bool get isSuccess => this is Ok<T>;
  
  /// Check if result is error
  bool get isError => this is Error<T>;
  
  /// Get error if exists
  Exception? get error {
    return switch (this) {
      Ok<T>() => null,
      Error<T>(error: final error) => error,
    };
  }
  
  /// Execute action based on result type
  R when<R>({
    required R Function(T value) success,
    required R Function(Exception error) error,
  }) {
    return switch (this) {
      Ok<T>(value: final value) => success(value),
      Error<T>(error: final e) => error(e),
    };
  }
}

/// Successful result containing a value
final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) || 
      (other is Ok<T> && other.value == value);
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'Ok($value)';
}

/// Error result containing an exception
final class Error<T> extends Result<T> {
  final Exception error;
  const Error(this.error);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Error<T> && other.error == error);
  
  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'Error($error)';
}

/// Extension to convert nullable values to Results
extension NullableResult<T> on T? {
  Result<T> toResult([Exception? error]) {
    final value = this;
    if (value != null) {
      return Ok(value);
    } else {
      return Error(error ?? Exception('Value was null'));
    }
  }
}

/// Extension to wrap functions in Result
extension FunctionResult on Function {
  /// Wrap a sync function to return Result
  static Result<R> wrap<R>(R Function() fn) {
    try {
      return Ok(fn());
    } catch (e) {
      return Error(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// Wrap an async function to return Result
  static Future<Result<R>> wrapAsync<R>(Future<R> Function() fn) async {
    try {
      final value = await fn();
      return Ok(value);
    } catch (e) {
      return Error(e is Exception ? e : Exception(e.toString()));
    }
  }
}

/// Common exceptions for the app
class HeavyweightException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const HeavyweightException(this.message, {this.code, this.details});
  
  @override
  String toString() => 'HeavyweightException: $message${code != null ? ' (code: $code)' : ''}';
}

class NetworkException extends HeavyweightException {
  const NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class ValidationException extends HeavyweightException {
  const ValidationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

class DataException extends HeavyweightException {
  const DataException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}