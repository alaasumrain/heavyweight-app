#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🧪 HEAVYWEIGHT Quick Health Check');
  print('=================================');

  // 1. Check if app is running
  print('\n1. Checking app status...');
  final result = await Process.run('lsof', ['-i', ':8080']);
  if (result.stdout.toString().contains('dart')) {
    print('   ✅ App is running on http://localhost:8080');
  } else {
    print('   ❌ App is not running. Start with: flutter run -d web-server --web-port=8080');
    return;
  }

  // 2. Check for compilation errors
  print('\n2. Checking for errors...');
  final analyzeResult = await Process.run('flutter', ['analyze', '--no-fatal-infos']);
  final errors = analyzeResult.stdout.toString();
  if (errors.contains('error •')) {
    print('   ❌ Compilation errors found');
    print('   Run: flutter analyze');
  } else {
    print('   ✅ No compilation errors');
  }

  // 3. Check key files exist
  print('\n3. Checking key files...');
  final keyFiles = [
    'lib/main.dart',
    'lib/screens/onboarding/splash_screen.dart',
    'lib/screens/training/assignment_screen.dart',
    'lib/fortress/protocol/protocol_screen.dart',
    'lib/core/theme/heavyweight_theme.dart',
    'HEAVYWEIGHT_COMPLETE_SYSTEM_MAP.md',
    'HEAVYWEIGHT_TESTING_GUIDE.md',
  ];

  for (final filePath in keyFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      print('   ✅ $filePath');
    } else {
      print('   ❌ Missing: $filePath');
    }
  }

  // 4. Ready to test message
  print('\n🚀 READY TO TEST!');
  print('================');
  print('');
  print('📱 Open your browser: http://localhost:8080');
  print('📋 Follow the testing guide: HEAVYWEIGHT_TESTING_GUIDE.md');
  print('');
  print('🎯 Quick Test Scenarios:');
  print('  1. NEW USER: Complete onboarding flow');
  print('  2. WORKOUT: Try the workout execution');
  print('  3. NAVIGATION: Test all screen transitions');
  print('  4. DATA: Check if workout data saves');
  print('');
  print('💪 The HEAVYWEIGHT app is ready for comprehensive testing!');
}
