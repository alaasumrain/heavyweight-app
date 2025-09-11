import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';

/// Secure Supabase initialization using compile-time constants
/// 
/// This implementation follows Flutter 2025 security best practices:
/// - Uses --dart-define-from-file for credentials
/// - No hardcoded secrets in source code
/// - Validates credentials before initialization
class SupabaseService {
  static bool _isInitialized = false;
  
  /// Initialize Supabase with secure credentials from compile-time constants
  /// 
  /// Credentials must be provided via --dart-define-from-file=env.json
  /// 
  /// Throws [StateError] if credentials are not properly configured
  static Future<void> initialize() async {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Validate credentials before attempting initialization
    await SupabaseConfig.validate();
    
    try {
      await Supabase.initialize(
        url: await SupabaseConfig.url,
        anonKey: await SupabaseConfig.anonKey,
      );
      
      _isInitialized = true;
      
      // Only print success in debug mode
      if (kDebugMode) {
        debugPrint('✅ Supabase initialized securely');
      }
      
    } catch (e) {
      throw StateError(
        'Failed to initialize Supabase: $e\n'
        'Ensure SUPABASE_URL and SUPABASE_ANON_KEY are set via --dart-define-from-file'
      );
    }
  }

  /// Check if Supabase has been initialized
  static bool get isInitialized => _isInitialized;
}

/// Global Supabase client instance
/// 
/// Use this after calling SupabaseService.initialize()
final supabase = Supabase.instance.client;