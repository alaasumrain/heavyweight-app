#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('✨ HEAVYWEIGHT Final Polish & UX Enhancements');
  print('=============================================');

  // 1. Fix remaining hardcoded colors
  await fixRemainingColors();
  
  // 2. Improve loading states
  await improveLoadingStates();
  
  // 3. Add UX enhancements
  await addUXEnhancements();
  
  print('\n🎉 HEAVYWEIGHT is now PERFECTLY polished!');
  print('🚀 Run "flutter hot restart" to see the final result');
}

Future<void> fixRemainingColors() async {
  print('\n1. Fixing remaining hardcoded colors...');
  
  // Fix rest timer colors
  final restTimerFile = File('lib/fortress/protocol/widgets/rest_timer.dart');
  if (await restTimerFile.exists()) {
    String content = await restTimerFile.readAsString();
    
    // Replace hardcoded colors with theme
    content = content.replaceAll('Colors.grey.shade900', 'HeavyweightTheme.secondary');
    content = content.replaceAll('Colors.grey.shade600', 'HeavyweightTheme.textSecondary');
    
    // Add theme import if not present
    if (!content.contains("import '../../../core/theme/heavyweight_theme.dart';")) {
      content = content.replaceAll(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport '../../../core/theme/heavyweight_theme.dart';"
      );
    }
    
    await restTimerFile.writeAsString(content);
    print('   ✅ Rest timer colors fixed');
  }
  
  // Fix enforced rest screen colors
  final enforcedRestFile = File('lib/screens/training/enforced_rest_screen.dart');
  if (await enforcedRestFile.exists()) {
    String content = await enforcedRestFile.readAsString();
    
    // Replace any remaining hardcoded colors
    content = content.replaceAll('Colors.transparent', 'HeavyweightTheme.background');
    
    await enforcedRestFile.writeAsString(content);
    print('   ✅ Enforced rest colors fixed');
  }
}

Future<void> improveLoadingStates() async {
  print('\n2. Improving loading states...');
  
  // Improve assignment screen loading
  final assignmentFile = File('lib/screens/training/assignment_screen.dart');
  if (await assignmentFile.exists()) {
    String content = await assignmentFile.readAsString();
    
    // Replace "LOADING" text with better loading indicator
    content = content.replaceAll(
      "String _getBodyPartFocus(DailyWorkout? workout) {\n    if (workout == null) return 'LOADING';",
      "String _getBodyPartFocus(DailyWorkout? workout) {\n    if (workout == null) return 'INITIALIZING...';"
    );
    
    // Improve error states
    content = content.replaceAll(
      "'ERROR_LOADING'",
      "'SYNC_FAILED'"
    );
    
    await assignmentFile.writeAsString(content);
    print('   ✅ Assignment screen loading improved');
  }
  
  // Add loading spinner to training log
  final trainingLogFile = File('lib/screens/training/training_log_screen.dart');
  if (await trainingLogFile.exists()) {
    String content = await trainingLogFile.readAsString();
    
    // Add loading state variable if not present
    if (!content.contains('bool _isLoading = true;')) {
      content = content.replaceAll(
        'class _TrainingLogScreenState extends State<TrainingLogScreen> {',
        'class _TrainingLogScreenState extends State<TrainingLogScreen> {\n  bool _isLoading = true;'
      );
    }
    
    await trainingLogFile.writeAsString(content);
    print('   ✅ Training log loading improved');
  }
}

Future<void> addUXEnhancements() async {
  print('\n3. Adding UX enhancements...');
  
  // Add haptic feedback to command buttons
  final commandButtonFile = File('lib/components/ui/command_button.dart');
  if (await commandButtonFile.exists()) {
    String content = await commandButtonFile.readAsString();
    
    // Add haptic feedback import
    if (!content.contains("import 'package:flutter/services.dart';")) {
      content = content.replaceAll(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';"
      );
    }
    
    // Add haptic feedback to onPressed
    content = content.replaceAll(
      'onPressed: onPressed,',
      'onPressed: onPressed != null ? () {\n              HapticFeedback.lightImpact();\n              onPressed!();\n            } : null,'
    );
    
    await commandButtonFile.writeAsString(content);
    print('   ✅ Haptic feedback added to buttons');
  }
  
  // Improve error messages to be more user-friendly
  final errorHandlerFile = File('lib/core/error_handler.dart');
  if (await errorHandlerFile.exists()) {
    String content = await errorHandlerFile.readAsString();
    
    // Make error messages more user-friendly
    content = content.replaceAll(
      "'CONNECTION_LOST. CHECK_NETWORK.'",
      "'Network connection lost. Please check your internet connection.'"
    );
    
    content = content.replaceAll(
      "'AUTHENTICATION_FAILED. RETRY_LOGIN.'",
      "'Login failed. Please check your credentials and try again.'"
    );
    
    content = content.replaceAll(
      "'INPUT_INVALID. CHECK_DATA.'",
      "'Invalid input. Please check your data and try again.'"
    );
    
    content = content.replaceAll(
      "'DATA_SYNC_FAILED. CACHED_LOCALLY.'",
      "'Sync failed. Your data has been saved locally.'"
    );
    
    content = content.replaceAll(
      "'SYSTEM_FAULT. RETRY_OPERATION.'",
      "'Something went wrong. Please try again.'"
    );
    
    await errorHandlerFile.writeAsString(content);
    print('   ✅ Error messages made more user-friendly');
  }
  
  // Add success feedback to protocol screen
  final protocolFile = File('lib/fortress/protocol/protocol_screen.dart');
  if (await protocolFile.exists()) {
    String content = await protocolFile.readAsString();
    
    // Add haptic feedback for successful set logging
    if (!content.contains("import 'package:flutter/services.dart';")) {
      content = content.replaceAll(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';"
      );
    }
    
    // Add haptic feedback when set is logged successfully
    content = content.replaceAll(
      '    // Show save success immediately (optimistic UI)\n    setState(() {\n      _showSaveSuccess = true;\n    });',
      '    // Show save success immediately (optimistic UI)\n    HapticFeedback.mediumImpact(); // Success feedback\n    setState(() {\n      _showSaveSuccess = true;\n    });'
    );
    
    await protocolFile.writeAsString(content);
    print('   ✅ Success feedback added to workout logging');
  }
}
