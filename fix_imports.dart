#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing Missing HeavyweightTheme Imports');
  print('==========================================');

  await fixManifestoScreen();
  await fixDailyWorkoutScreen();
  
  print('\n✅ Import fixes completed!');
}

Future<void> fixManifestoScreen() async {
  print('\n1. Fixing Manifesto Screen imports...');
  
  final file = File('lib/fortress/manifesto/manifesto_screen.dart');
  String content = await file.readAsString();
  
  // Add the missing import after the existing imports
  if (!content.contains("import '../../core/theme/heavyweight_theme.dart';")) {
    content = content.replaceAll(
      "import '../../providers/app_state_provider.dart';",
      "import '../../providers/app_state_provider.dart';\nimport '../../core/theme/heavyweight_theme.dart';"
    );
  }
  
  // Also fix any remaining hardcoded colors
  content = content.replaceAll('Colors.white', 'HeavyweightTheme.primary');
  content = content.replaceAll('Colors.black', 'HeavyweightTheme.background');
  
  await file.writeAsString(content);
  print('   ✅ Manifesto screen imports fixed');
}

Future<void> fixDailyWorkoutScreen() async {
  print('\n2. Fixing Daily Workout Screen imports...');
  
  final file = File('lib/fortress/daily_workout/daily_workout_screen.dart');
  String content = await file.readAsString();
  
  // Check if import already exists
  if (!content.contains("import '../../core/theme/heavyweight_theme.dart';")) {
    // Find the last import line and add our import after it
    final lines = content.split('\n');
    int lastImportIndex = -1;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('import ')) {
        lastImportIndex = i;
      }
    }
    
    if (lastImportIndex != -1) {
      lines.insert(lastImportIndex + 1, "import '../../core/theme/heavyweight_theme.dart';");
      content = lines.join('\n');
    }
  }
  
  await file.writeAsString(content);
  print('   ✅ Daily workout screen imports fixed');
}
