#!/usr/bin/env dart

import 'dart:io';

void main() async {
  final file = File('lib/fortress/manifesto/manifesto_screen.dart');
  String content = await file.readAsString();
  
  // Fix the extra closing parenthesis
  content = content.replaceAll(
    '''          style: HeavyweightTheme.bodyMedium,
          ),
        ),''',
    '''          style: HeavyweightTheme.bodyMedium,
        ),'''
  );
  
  await file.writeAsString(content);
  print('✅ Final syntax error fixed');
}
