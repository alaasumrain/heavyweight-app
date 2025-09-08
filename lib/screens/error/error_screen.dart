import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/error_handler.dart';

/// Generic error screen for unrecoverable errors
class ErrorScreen extends StatelessWidget {
  final Object? error;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? retryRoute;

  const ErrorScreen({
    Key? key,
    this.error,
    this.errorMessage,
    this.onRetry,
    this.retryRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = errorMessage ?? 
        (error != null ? HeavyweightErrorHandler.getErrorMessage(error!) : 'UNKNOWN_ERROR');

    return HeavyweightScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SystemBanner(),
          
          const Spacer(),
          
          // Error icon
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          
          const SizedBox(height: 24),
          
          // Error title
          const Text(
            'SYSTEM_FAULT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Error message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const Spacer(),
          
          // Action buttons
          if (onRetry != null || retryRoute != null) ...[
            CommandButton(
              text: 'COMMAND: RETRY',
              onPressed: () {
                if (onRetry != null) {
                  onRetry!();
                } else if (retryRoute != null) {
                  context.go(retryRoute!);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
          
          CommandButton(
            text: 'COMMAND: HOME',
            variant: ButtonVariant.secondary,
            onPressed: () => context.go('/assignment'),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Network error screen
class NetworkErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorScreen({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      errorMessage: 'CONNECTION_LOST.\nCHECK_NETWORK_AND_RETRY.',
      onRetry: onRetry,
      retryRoute: '/assignment',
    );
  }
}

/// Authentication error screen
class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      errorMessage: 'AUTHENTICATION_FAILED.\nPLEASE_LOGIN_AGAIN.',
      retryRoute: '/auth',
    );
  }
}
