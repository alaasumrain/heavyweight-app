import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';
import '../../core/logging.dart';

/// Secure Supabase initialization using compile-time constants
///
/// This implementation follows Flutter 2025 security best practices:
/// - Uses --dart-define-from-file for credentials
/// - No hardcoded secrets in source code
/// - Validates credentials before initialization
/// - Gracefully handles initialization failures
class SupabaseService {
  static bool _isInitialized = false;
  static bool _initializationFailed = false;

  /// Initialize Supabase with secure credentials from compile-time constants
  ///
  /// Returns true if initialization succeeded, false otherwise
  /// Does NOT throw exceptions - handles failures gracefully
  static Future<bool> initialize() async {
    if (_isInitialized) {
      return true; // Already initialized successfully
    }

    if (_initializationFailed) {
      return false; // Already tried and failed
    }

    try {
      // Check if configuration is valid
      final isConfigValid = await SupabaseConfig.isValid;
      if (!isConfigValid) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ HEAVYWEIGHT: Supabase config invalid, running in offline mode');
        }
        HWLog.event('supabase_config_invalid');
        _initializationFailed = true;
        return false;
      }

      await Supabase.initialize(
        url: await SupabaseConfig.url,
        anonKey: await SupabaseConfig.anonKey,
      );

      _isInitialized = true;

      // Only print success in debug mode
      if (kDebugMode) {
        debugPrint('✅ HEAVYWEIGHT: Supabase initialized securely');
      }
      HWLog.event('supabase_init_success');

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HEAVYWEIGHT: Supabase initialization failed: $e');
        debugPrint('📱 HEAVYWEIGHT: App will continue in offline mode');
      }
      HWLog.event('supabase_init_failed', data: {'error': e.toString()});
      _initializationFailed = true;
      return false;
    }
  }

  /// Check if Supabase has been initialized
  static bool get isInitialized => _isInitialized;

  /// Check if Supabase initialization failed
  static bool get initializationFailed => _initializationFailed;

  /// Check if Supabase is available for use
  static bool get isAvailable => _isInitialized && !_initializationFailed;
}

/// Global Supabase client instance
///
/// Use this after calling SupabaseService.initialize()
final supabase = Supabase.instance.client;
