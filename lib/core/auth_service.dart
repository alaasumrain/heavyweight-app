import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logging.dart';

/// Comprehensive authentication service following Supabase best practices
/// Handles sign in, sign up, session management, and persistence
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<AuthState>? _authSubscription;

  /// Initialize the auth service and set up listeners
  Future<void> initialize() async {
    try {
      // Get current user with retry mechanism for session recovery
      await _tryRecoverSession(maxRetries: 3);
    } catch (error) {
      HWLog.event('auth_initialize_failed', data: {
        'error': error.toString(),
      });
      _setError('Authentication initialization failed');
    }

    _setupAuthListener();
  }

  /// Attempt to recover session with retry mechanism
  Future<void> _tryRecoverSession({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _currentUser = Supabase.instance.client.auth.currentUser;

        // If we have a user, try to refresh the session
        if (_currentUser != null) {
          await Supabase.instance.client.auth.refreshSession();
        }

        HWLog.event('auth_session_recovery_success', data: {
          'attempt': attempt,
          'hasUser': _currentUser != null,
        });

        return; // Success, exit retry loop
      } catch (error) {
        HWLog.event('auth_session_recovery_attempt_failed', data: {
          'attempt': attempt,
          'maxRetries': maxRetries,
          'error': error.toString(),
        });

        if (attempt == maxRetries) {
          // Final attempt failed
          _currentUser = null;
          HWLog.event('auth_session_recovery_failed', data: {
            'totalAttempts': maxRetries,
            'finalError': error.toString(),
          });
        } else {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }
  }

  /// Set up auth state listener
  void _setupAuthListener() {
    try {
      // Set up auth state listener for real-time updates
      _authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        _handleAuthStateChange(event, session);
      }, onError: (error) {
        // Handle auth state change errors with retry
        HWLog.event('auth_state_change_error', data: {
          'error': error.toString(),
        });
        _setError('Auth state error: $error');
        HWLog.event('auth_listener_error', data: {
          'error': error.toString(),
        });
      });

      HWLog.event('auth_initialize_done', data: {
        'hasUser': _currentUser != null,
      });
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize auth service: $e');
      HWLog.event('auth_initialize_failed', data: {
        'error': e.toString(),
      });
    }
  }

  /// Dispose of resources
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      HWLog.event('auth_sign_in_start');
      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Session persistence is automatic with Supabase Flutter
        _setLoading(false);
        HWLog.event('auth_sign_in_success');
        return true;
      } else {
        _setError('Sign in failed: No user returned');
        _setLoading(false);
        HWLog.event('auth_sign_in_no_user');
        return false;
      }
    } on AuthException catch (e) {
      _setError(_getReadableAuthError(e));
      _setLoading(false);
      HWLog.event('auth_sign_in_auth_exception', data: {
        'message': e.message,
      });
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      _setLoading(false);
      HWLog.event('auth_sign_in_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      HWLog.event('auth_sign_up_start');
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
      );

      if (response.user != null) {
        // Session persistence is automatic with Supabase Flutter
        _setLoading(false);
        HWLog.event('auth_sign_up_success');
        return true;
      } else {
        _setError('Sign up failed: No user returned');
        _setLoading(false);
        HWLog.event('auth_sign_up_no_user');
        return false;
      }
    } on AuthException catch (e) {
      _setError(_getReadableAuthError(e));
      _setLoading(false);
      HWLog.event('auth_sign_up_auth_exception', data: {
        'message': e.message,
      });
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      _setLoading(false);
      HWLog.event('auth_sign_up_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      HWLog.event('auth_sign_out_start');
      await Supabase.instance.client.auth.signOut();
      // Session cleanup is automatic with Supabase Flutter
      _setLoading(false);
      HWLog.event('auth_sign_out_success');
    } catch (e) {
      _setError('Sign out failed: $e');
      _setLoading(false);
      HWLog.event('auth_sign_out_error', data: {
        'error': e.toString(),
      });
    }
  }

  /// Reset password for email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      HWLog.event('auth_reset_password_start');
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        // Align with app URL scheme configured on iOS/Android
        redirectTo: 'heavyweight://heavyweight.app/reset-password',
      );
      _setLoading(false);
      HWLog.event('auth_reset_password_success');
      return true;
    } on AuthException catch (e) {
      _setError(_getReadableAuthError(e));
      _setLoading(false);
      HWLog.event('auth_reset_password_auth_exception', data: {
        'message': e.message,
      });
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
      _setLoading(false);
      HWLog.event('auth_reset_password_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Refresh the current session
  Future<bool> refreshSession() async {
    try {
      HWLog.event('auth_refresh_session_start');
      final AuthResponse response =
          await Supabase.instance.client.auth.refreshSession();
      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
        HWLog.event('auth_refresh_session_success');
        return true;
      }
      HWLog.event('auth_refresh_session_no_user');
      return false;
    } catch (e) {
      _setError('Session refresh failed: $e');
      HWLog.event('auth_refresh_session_error', data: {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Handle auth state changes
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    HWLog.event('auth_state_change', data: {
      'event': event.name,
      'hasUser': session?.user != null,
    });
    switch (event) {
      case AuthChangeEvent.signedIn:
        _currentUser = session?.user;
        _clearError();
        break;
      case AuthChangeEvent.signedOut:
        _currentUser = null;
        _clearError();
        break;
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.initialSession:
        _currentUser = session?.user;
        break;
      case AuthChangeEvent.passwordRecovery:
      case AuthChangeEvent.mfaChallengeVerified:
        // Handle password recovery/MFA if needed
        break;
      default:
        break;
    }

    if (event.name == 'user_deleted') {
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Convert AuthException to user-friendly message
  String _getReadableAuthError(AuthException e) {
    switch (e.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'INVALID_CREDENTIALS. VERIFY_INPUT.';
      case 'email not confirmed':
        return 'EMAIL_NOT_CONFIRMED. CHECK_INBOX.';
      case 'user not found':
        return 'USER_NOT_FOUND. EMAIL_UNREGISTERED.';
      case 'weak password':
        return 'WEAK_PASSWORD. MIN_6_CHARS.';
      case 'email already registered':
        return 'EMAIL_EXISTS. USE_LOGIN.';
      case 'signup disabled':
        return 'SIGNUP_DISABLED. CONTACT_ADMIN.';
      default:
        return 'AUTH_ERROR: ${e.message}';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 6 characters, contains letter and number
    return password.length >= 6 &&
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }

  /// Get password strength feedback
  static String getPasswordFeedback(String password) {
    if (password.length < 6) {
      return 'PASSWORD_TOO_SHORT: Minimum 6 characters required';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'PASSWORD_NEEDS_LETTER: Must contain at least one letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'PASSWORD_NEEDS_NUMBER: Must contain at least one number';
    }
    if (password.length >= 8 &&
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(password)) {
      return 'PASSWORD_STRONG: Good password strength';
    }
    return 'PASSWORD_MODERATE: Consider adding special characters';
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
