#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🎯 HEAVYWEIGHT Immediate UX Improvements');
  print('=======================================');

  // 1. Fix error handler theme consistency
  await fixErrorHandler();
  
  // 2. Add loading states to auth screen
  await addAuthLoadingStates();
  
  // 3. Fix auth screen theme consistency
  await fixAuthScreenTheme();
  
  print('\n✅ All immediate improvements completed!');
  print('🚀 Run "flutter hot restart" to see changes');
}

Future<void> fixErrorHandler() async {
  print('\n1. Fixing error handler theme consistency...');
  
  final file = File('lib/core/error_handler.dart');
  String content = await file.readAsString();
  
  // Fix the missing message variable
  content = content.replaceAll(
    '  static void showError(BuildContext context, Object error, {VoidCallback? onRetry}) {\n    \n    \n    ScaffoldMessenger.of(context).showSnackBar(',
    '  static void showError(BuildContext context, Object error, {VoidCallback? onRetry}) {\n    final message = getErrorMessage(error);\n    \n    ScaffoldMessenger.of(context).showSnackBar('
  );
  
  // Replace hardcoded colors with theme
  content = content.replaceAll('Colors.red.shade900', 'HeavyweightTheme.danger');
  content = content.replaceAll('Colors.white', 'HeavyweightTheme.primary');
  
  // Add theme import if not present
  if (!content.contains("import '../core/theme/heavyweight_theme.dart';")) {
    content = content.replaceAll(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport '../core/theme/heavyweight_theme.dart';"
    );
  }
  
  await file.writeAsString(content);
  print('   ✅ Error handler fixed');
}

Future<void> addAuthLoadingStates() async {
  print('\n2. Adding loading states to auth screen...');
  
  final file = File('lib/screens/onboarding/auth_screen.dart');
  String content = await file.readAsString();
  
  // Add loading state variable
  if (!content.contains('bool _isLoading = false;')) {
    content = content.replaceAll(
      'class _AuthScreenState extends State<AuthScreen> {',
      'class _AuthScreenState extends State<AuthScreen> {\n  bool _isLoading = false;'
    );
  }
  
  // Add loading state to _handleAuth method
  content = content.replaceAll(
    '  void _handleAuth() async {',
    '  void _handleAuth() async {\n    setState(() {\n      _isLoading = true;\n    });'
  );
  
  // Reset loading state at the end
  content = content.replaceAll(
    '    } else if (mounted && _authService.error != null) {\n      _showError(_authService.error!);\n    }',
    '    } else if (mounted && _authService.error != null) {\n      _showError(_authService.error!);\n    }\n    \n    if (mounted) {\n      setState(() {\n        _isLoading = false;\n      });\n    }'
  );
  
  await file.writeAsString(content);
  print('   ✅ Auth loading states added');
}

Future<void> fixAuthScreenTheme() async {
  print('\n3. Fixing auth screen theme consistency...');
  
  final file = File('lib/screens/onboarding/auth_screen.dart');
  String content = await file.readAsString();
  
  // Replace hardcoded error color with theme
  content = content.replaceAll(
    'backgroundColor: Colors.red.shade900,',
    'backgroundColor: HeavyweightTheme.danger,'
  );
  
  await file.writeAsString(content);
  print('   ✅ Auth screen theme fixed');
}
