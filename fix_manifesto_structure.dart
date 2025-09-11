#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing Manifesto Screen Structure');
  print('===================================');

  final file = File('lib/fortress/manifesto/manifesto_screen.dart');
  String content = await file.readAsString();
  
  // Fix the corrupted TextStyle in the instruction text
  content = content.replaceAll(
    '''          Text(
            'TYPE "I COMMIT" TO BEGIN',
            style: HeavyweightTheme.bodyMedium,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),''',
    '''          const Text(
            'TYPE "I COMMIT" TO BEGIN',
            style: HeavyweightTheme.bodySmall,
          ),'''
  );
  
  // Fix the corrupted hintStyle in the TextFormField
  content = content.replaceAll(
    '''              hintStyle: HeavyweightTheme.bodySmall,
                fontSize: 24,
              ),''',
    '''              hintStyle: HeavyweightTheme.bodySmall,
              ),'''
  );
  
  // Fix any remaining Colors.red references
  content = content.replaceAll('Colors.red', 'HeavyweightTheme.danger');
  
  await file.writeAsString(content);
  print('✅ Manifesto screen structure fixed');
}
