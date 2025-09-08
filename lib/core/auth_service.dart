import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Get initial session (Supabase handles persistence automatically)
      _currentUser = Supabase.instance.client.auth.currentUser;
      
      // Set up auth state listener for real-time updates
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        _handleAuthStateChange(event, session);
      });
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize auth service: $e');
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
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user != null) {
        // Session persistence is automatic with Supabase Flutter
        _setLoading(false);
        return true;
      } else {
        _setError('Sign in failed: No user returned');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _setError(_getReadableAuthError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      _setLoading(false);
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
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
      );
      
      if (response.user != null) {
        // Session persistence is automatic with Supabase Flutter
        _setLoading(false);
        return true;
      } else {
        _setError('Sign up failed: No user returned');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _setError(_getReadableAuthError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      _setLoading(false);
      return false;
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      await Supabase.instance.client.auth.signOut();
      // Session cleanup is automatic with Supabase Flutter
      _setLoading(false);
    } catch (e) {
      _setError('Sign out failed: $e');
      _setLoading(false);
    }
  }
  
  /// Reset password for email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.heavyweight.app://reset-password', // Deep link for mobile
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(_getReadableAuthError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
      _setLoading(false);
      return false;
    }
  }
  
  /// Refresh the current session
  Future<bool> refreshSession() async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.refreshSession();
      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Session refresh failed: $e');
      return false;
    }
  }
  
  /// Handle auth state changes
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
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
        _currentUser = session?.user;
        break;
      case AuthChangeEvent.passwordRecovery:
        // Handle password recovery if needed
        break;
      case AuthChangeEvent.tokenRefreshed:
        _currentUser = session?.user;
        break;
      case AuthChangeEvent.userDeleted:
        _currentUser = null;
        break;
      case AuthChangeEvent.mfaChallengeVerified:
        // Handle MFA if implemented
        break;
      case AuthChangeEvent.initialSession:
        _currentUser = session?.user;
        break;
    }
    notifyListeners();
  }
  
  /// Convert AuthException to user-friendly message
  String _getReadableAuthError(AuthException e) {
    switch (e.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'INVALID_CREDENTIALS: Check your email and password';
      case 'email not confirmed':
        return 'EMAIL_NOT_CONFIRMED: Check your email for confirmation link';
      case 'user not found':
        return 'USER_NOT_FOUND: No account found with this email';
      case 'weak password':
        return 'WEAK_PASSWORD: Password must be at least 6 characters';
      case 'email already registered':
        return 'EMAIL_EXISTS: Account already exists with this email';
      case 'signup disabled':
        return 'SIGNUP_DISABLED: New registrations are currently disabled';
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
    if (password.length >= 8 && RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(password)) {
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
