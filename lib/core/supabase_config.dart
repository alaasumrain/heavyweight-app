import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Automatic Supabase configuration that loads from env.json 
/// No command line bullshit needed!
class SupabaseConfig {
  static String? _url;
  static String? _anonKey;
  static bool _isLoaded = false;

  /// Auto-load config from env.json file
  static Future<void> _loadConfig() async {
    if (_isLoaded) return;
    
    try {
      // Try compile-time first (for production builds)
      _url = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      _anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      
      // If empty, load from env.json file (for development)
      if (_url!.isEmpty || _anonKey!.isEmpty) {
        final String envString = await rootBundle.loadString('env.json');
        final Map<String, dynamic> envData = json.decode(envString);
        _url = envData['SUPABASE_URL'] ?? '';
        _anonKey = envData['SUPABASE_ANON_KEY'] ?? '';
      }
      
      _isLoaded = true;
    } catch (e) {
      throw StateError('Failed to load config: $e');
    }
  }

  static Future<String> get url async {
    await _loadConfig();
    return _url!;
  }

  static Future<String> get anonKey async {
    await _loadConfig();
    return _anonKey!;
  }

  /// Validates that all required credentials are loaded
  static Future<void> validate() async {
    await _loadConfig();
    
    if (kDebugMode) {
      debugPrint('🔍 HEAVYWEIGHT: Validating Supabase configuration...');
      debugPrint('📊 SUPABASE_URL: ${_url!.isNotEmpty ? "✅ Set (${_url!.substring(0, 20)}...)" : "❌ Empty"}');
      debugPrint('📊 SUPABASE_ANON_KEY: ${_anonKey!.isNotEmpty ? "✅ Set (${_anonKey!.length} chars)" : "❌ Empty"}');
    }
    
    if (_url!.isEmpty) {
      throw StateError('SUPABASE_URL not found in env.json');
    }
    
    if (_anonKey!.isEmpty) {
      throw StateError('SUPABASE_ANON_KEY not found in env.json');
    }

    if (!_url!.startsWith('https://')) {
      throw StateError('SUPABASE_URL must start with https://');
    }

    if (_anonKey!.length < 10) {
      throw StateError('SUPABASE_ANON_KEY appears to be invalid (too short)');
    }
    
    if (kDebugMode) {
      debugPrint('✅ HEAVYWEIGHT: Supabase configuration valid');
    }
  }

  /// Returns true if configuration appears valid
  static Future<bool> get isValid async {
    try {
      await validate();
      return true;
    } catch (_) {
      return false;
    }
  }
}