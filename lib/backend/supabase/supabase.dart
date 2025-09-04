import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Warning: .env file not found. Create .env file with SUPABASE_URL and SUPABASE_ANON_KEY');
      // Continue with empty values for development
    }
    
    if (url.isEmpty || anonKey.isEmpty) {
      print('Warning: Supabase credentials not configured. App will run in offline mode.');
      print('To enable Supabase:');
      print('1. Create .env file in project root');
      print('2. Add SUPABASE_URL=your-project-url');
      print('3. Add SUPABASE_ANON_KEY=your-anon-key');
      return; // Don't initialize Supabase if credentials missing
    }
    
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}

final supabase = Supabase.instance.client;