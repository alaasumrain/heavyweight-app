// The Fortress Entry Point - Complete ideological takeover
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fortress/mandate/mandate_screen.dart';
import 'fortress/manifesto/manifesto_screen.dart';

/// FORTRESS MODE ACTIVE
/// All legacy code has been walled off
/// Only the mandate exists
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences for fortress data
  await SharedPreferences.getInstance();
  
  runApp(const FortressApp());
}

class FortressApp extends StatelessWidget {
  const FortressApp({super.key});
  
  Future<bool> _checkCommitment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fortress_committed') ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FORTRESS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF00),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: false,
        
        // Typography
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          bodyMedium: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        
        // Colors
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF00),
          secondary: Colors.amber,
          error: Colors.red,
          surface: Color(0xFF1A1A1A),
        ),
        
        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF00),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      
      // Check commitment first
      home: FutureBuilder<bool>(
        future: _checkCommitment(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00FF00),
                ),
              ),
            );
          }
          
          // Show manifesto if not committed
          if (snapshot.data != true) {
            return const ManifestoScreen();
          }
          
          // Show mandate if committed
          return const MandateScreen();
        },
      ),
      
      // Routes
      routes: {
        '/fortress/manifesto': (context) => const ManifestoScreen(),
        '/fortress/mandate': (context) => const MandateScreen(),
      },
    );
  }
}