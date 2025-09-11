import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/logging.dart';
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
    HWLog.screen('Error/Generic');
    final message = errorMessage ?? 
        (error != null ? HeavyweightErrorHandler.getErrorMessage(error!) : 'UNKNOWN_ERROR');

    return HeavyweightScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Error icon
          const Icon(
            Icons.error_outline,
            color: HeavyweightTheme.danger,
            size: 64,
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingLg),
          
          // Error title
          const Text(
            'SYSTEM_FAULT',
            style: TextStyle(
              color: HeavyweightTheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          // Error message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingXxl),
            child: Text(
              message,
              style: const TextStyle(
                color: HeavyweightTheme.textSecondary,
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
                HWLog.event('error_retry_tap', data: {
                  'hasOnRetry': onRetry != null,
                  'retryRoute': retryRoute ?? '',
                });
                if (onRetry != null) {
                  onRetry!();
                } else if (retryRoute != null) {
                  context.go(retryRoute!);
                }
              },
            ),
            const SizedBox(height: HeavyweightTheme.spacingMd),
          ],
          
          CommandButton(
            text: 'COMMAND: HOME',
            variant: ButtonVariant.secondary,
            onPressed: () {
              HWLog.event('error_home_tap');
              context.go('/assignment');
            },
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXxl),
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
