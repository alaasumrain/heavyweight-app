#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing Manifesto Screen Syntax Error');
  print('=======================================');

  final file = File('lib/fortress/manifesto/manifesto_screen.dart');
  String content = await file.readAsString();
  
  // Fix the corrupted style syntax
  content = content.replaceAll(
    '''          style: HeavyweightTheme.bodyMedium,
            fontSize: 16,
            height: 1.8,
          ),''',
    '''          style: HeavyweightTheme.bodyMedium,
          ),'''
  );
  
  await file.writeAsString(content);
  print('✅ Manifesto screen syntax fixed');
}
