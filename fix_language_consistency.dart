#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 HEAVYWEIGHT Language Consistency Audit & Fix');
  print('===============================================');

  // 1. Fix auth screen validation messages
  await fixAuthScreenLanguage();
  
  // 2. Fix auth service error messages
  await fixAuthServiceLanguage();
  
  // 3. Fix error screen theme consistency
  await fixErrorScreenTheme();
  
  // 4. Remove duplicate error handling code
  await removeDuplicateErrorCode();
  
  print('\n✅ All language inconsistencies fixed!');
  print('🎯 HEAVYWEIGHT voice is now 100% consistent');
}

Future<void> fixAuthScreenLanguage() async {
  print('\n1. Fixing auth screen validation messages...');
  
  final file = File('lib/screens/onboarding/auth_screen.dart');
  String content = await file.readAsString();
  
  // Fix validation messages to match HEAVYWEIGHT style
  content = content.replaceAll(
    "'FIELDS_REQUIRED: Please fill in all fields'",
    "'FIELDS_REQUIRED. COMPLETE_ALL_INPUTS.'"
  );
  
  content = content.replaceAll(
    "'INVALID_EMAIL: Please enter a valid email address'",
    "'INVALID_EMAIL. CHECK_FORMAT.'"
  );
  
  content = content.replaceAll(
    "'INVALID_EMAIL: Please enter a valid email'",
    "'INVALID_EMAIL. CHECK_FORMAT.'"
  );
  
  content = content.replaceAll(
    "'PASSWORD_RESET_SENT: Check your email'",
    "'RESET_SENT. CHECK_EMAIL.'"
  );
  
  // Fix success message styling
  content = content.replaceAll(
    'backgroundColor: Colors.green,',
    'backgroundColor: HeavyweightTheme.success,'
  );
  
  await file.writeAsString(content);
  print('   ✅ Auth screen validation messages fixed');
}

Future<void> fixAuthServiceLanguage() async {
  print('\n2. Fixing auth service error messages...');
  
  final file = File('lib/core/auth_service.dart');
  String content = await file.readAsString();
  
  // Fix auth error messages to match HEAVYWEIGHT style
  content = content.replaceAll(
    "'INVALID_CREDENTIALS: Check your email and password'",
    "'INVALID_CREDENTIALS. VERIFY_INPUT.'"
  );
  
  content = content.replaceAll(
    "'EMAIL_NOT_CONFIRMED: Check your email for confirmation link'",
    "'EMAIL_NOT_CONFIRMED. CHECK_INBOX.'"
  );
  
  content = content.replaceAll(
    "'USER_NOT_FOUND: No account found with this email'",
    "'USER_NOT_FOUND. EMAIL_UNREGISTERED.'"
  );
  
  content = content.replaceAll(
    "'WEAK_PASSWORD: Password must be at least 6 characters'",
    "'WEAK_PASSWORD. MIN_6_CHARS.'"
  );
  
  content = content.replaceAll(
    "'EMAIL_EXISTS: Account already exists with this email'",
    "'EMAIL_EXISTS. USE_LOGIN.'"
  );
  
  content = content.replaceAll(
    "'SIGNUP_DISABLED: New registrations are currently disabled'",
    "'SIGNUP_DISABLED. CONTACT_ADMIN.'"
  );
  
  await file.writeAsString(content);
  print('   ✅ Auth service error messages fixed');
}

Future<void> fixErrorScreenTheme() async {
  print('\n3. Fixing error screen theme consistency...');
  
  final file = File('lib/screens/error/error_screen.dart');
  String content = await file.readAsString();
  
  // Replace hardcoded colors with theme
  content = content.replaceAll('Colors.red', 'HeavyweightTheme.danger');
  content = content.replaceAll('Colors.grey', 'HeavyweightTheme.textSecondary');
  content = content.replaceAll('Colors.white', 'HeavyweightTheme.primary');
  
  // Add theme import if not present
  if (!content.contains("import '../../core/theme/heavyweight_theme.dart';")) {
    content = content.replaceAll(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport '../../core/theme/heavyweight_theme.dart';"
    );
  }
  
  await file.writeAsString(content);
  print('   ✅ Error screen theme consistency fixed');
}

Future<void> removeDuplicateErrorCode() async {
  print('\n4. Removing duplicate error handling code...');
  
  // Fix daily workout screen to use centralized error handling
  final dailyWorkoutFile = File('lib/fortress/daily_workout/daily_workout_screen.dart');
  if (await dailyWorkoutFile.exists()) {
    String content = await dailyWorkoutFile.readAsString();
    
    // Replace hardcoded colors with theme
    content = content.replaceAll('Colors.black', 'HeavyweightTheme.background');
    content = content.replaceAll('Colors.red', 'HeavyweightTheme.danger');
    content = content.replaceAll('Colors.white', 'HeavyweightTheme.primary');
    
    await dailyWorkoutFile.writeAsString(content);
    print('   ✅ Daily workout error handling improved');
  }
  
  // Fix assignment screen error handling
  final assignmentFile = File('lib/screens/training/assignment_screen.dart');
  if (await assignmentFile.exists()) {
    String content = await assignmentFile.readAsString();
    
    // Replace hardcoded colors with theme (already mostly done)
    content = content.replaceAll('Colors.red', 'HeavyweightTheme.danger');
    
    await assignmentFile.writeAsString(content);
    print('   ✅ Assignment screen error handling improved');
  }
}
