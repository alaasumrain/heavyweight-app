import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error handling system for HEAVYWEIGHT app
/// Provides consistent error handling across the entire application
class HeavyweightErrorHandler {
  static final HeavyweightErrorHandler _instance = HeavyweightErrorHandler._internal();
  factory HeavyweightErrorHandler() => _instance;
  HeavyweightErrorHandler._internal();

  /// Initialize global error handling
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Async Error', error, stack);
      return true;
    };
  }

  /// Log error with context
  static void _logError(String type, Object error, StackTrace? stack) {
    if (kDebugMode) {
      print('🔴 HEAVYWEIGHT ERROR [$type]: $error');
      if (stack != null) {
        print('Stack trace: $stack');
      }
    }
    
    // TODO: Send to crash reporting service in production
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }

  /// Handle specific error types with user-friendly messages
  static String getErrorMessage(Object error) {
    if (error.toString().contains('network') || 
        error.toString().contains('connection') ||
        error.toString().contains('timeout')) {
      return 'CONNECTION_LOST. CHECK_NETWORK.';
    }
    
    if (error.toString().contains('auth') || 
        error.toString().contains('permission') ||
        error.toString().contains('unauthorized')) {
      return 'AUTHENTICATION_FAILED. RETRY_LOGIN.';
    }
    
    if (error.toString().contains('validation') ||
        error.toString().contains('invalid')) {
      return 'INPUT_INVALID. CHECK_DATA.';
    }
    
    if (error.toString().contains('storage') ||
        error.toString().contains('database')) {
      return 'DATA_SYNC_FAILED. CACHED_LOCALLY.';
    }
    
    // Generic error
    return 'SYSTEM_FAULT. RETRY_OPERATION.';
  }

  /// Show error to user with consistent styling
  static void showError(BuildContext context, Object error, {VoidCallback? onRetry}) {
    final message = getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade900,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'IBMPlexMono',
                  letterSpacing: 1,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Error boundary widget to catch widget build errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? _buildDefaultError();
    }
    
    return widget.child;
  }

  Widget _buildDefaultError() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'SYSTEM_FAULT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              HeavyweightErrorHandler.getErrorMessage(_error!),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _error = null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('COMMAND: RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _error = null; // Reset error when widget updates
  }
}

/// Mixin for handling async operations with error handling
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  /// Execute async operation with automatic error handling
  Future<R?> executeWithErrorHandling<R>(
    Future<R> Function() operation, {
    String? errorContext,
    VoidCallback? onRetry,
  }) async {
    try {
      return await operation();
    } catch (error, stack) {
      HeavyweightErrorHandler._logError(
        errorContext ?? 'Operation', 
        error, 
        stack,
      );
      
      if (mounted) {
        HeavyweightErrorHandler.showError(
          context, 
          error, 
          onRetry: onRetry,
        );
      }
      
      return null;
    }
  }
}

/// Extension for easy error handling on Future
extension FutureErrorHandling<T> on Future<T> {
  Future<T?> handleErrors(BuildContext context, {VoidCallback? onRetry}) async {
    try {
      return await this;
    } catch (error) {
      HeavyweightErrorHandler.showError(context, error, onRetry: onRetry);
      return null;
    }
  }
}
