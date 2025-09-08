import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Updated with correct project credentials
  static const String url = 'https://oqsmbngbgvlnehcxvcto.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9xc21ibmdiZ3ZsbmVoY3h2Y3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MTg4NzksImV4cCI6MjA3MjM5NDg3OX0.SR7cN_wR5feN_aXMzxl4I6LIE6soAt-VNF8dPCcY6WA';
  
  static Future<void> initialize() async {
    try {
      // Try to load from .env if available
      await dotenv.load(fileName: ".env");
      
      final envUrl = dotenv.env['SUPABASE_URL'];
      final envKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      await Supabase.initialize(
        url: envUrl?.isNotEmpty == true ? envUrl! : url,
        anonKey: envKey?.isNotEmpty == true ? envKey! : anonKey,
      );
      
      print('✅ Supabase initialized successfully');
    } catch (e) {
      // Fallback to hardcoded values if .env fails
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        print('✅ Supabase initialized with fallback credentials');
      } catch (fallbackError) {
        print('❌ Failed to initialize Supabase: $fallbackError');
        rethrow;
      }
    }
  }
}

final supabase = Supabase.instance.client;