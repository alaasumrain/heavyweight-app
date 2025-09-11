#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing Error Messages to Match HEAVYWEIGHT Language');
  print('====================================================');

  final file = File('lib/core/error_handler.dart');
  String content = await file.readAsString();
  
  // Revert to HEAVYWEIGHT terminal-style error messages
  content = content.replaceAll(
    "'Network connection lost. Please check your internet connection.'",
    "'CONNECTION_LOST. CHECK_NETWORK.'"
  );
  
  content = content.replaceAll(
    "'Login failed. Please check your credentials and try again.'",
    "'AUTHENTICATION_FAILED. RETRY_LOGIN.'"
  );
  
  content = content.replaceAll(
    "'Invalid input. Please check your data and try again.'",
    "'INPUT_INVALID. CHECK_DATA.'"
  );
  
  content = content.replaceAll(
    "'Sync failed. Your data has been saved locally.'",
    "'DATA_SYNC_FAILED. CACHED_LOCALLY.'"
  );
  
  content = content.replaceAll(
    "'Something went wrong. Please try again.'",
    "'SYSTEM_FAULT. RETRY_OPERATION.'"
  );
  
  await file.writeAsString(content);
  print('✅ Error messages restored to HEAVYWEIGHT terminal style');
  print('   - CONNECTION_LOST. CHECK_NETWORK.');
  print('   - AUTHENTICATION_FAILED. RETRY_LOGIN.');
  print('   - INPUT_INVALID. CHECK_DATA.');
  print('   - DATA_SYNC_FAILED. CACHED_LOCALLY.');
  print('   - SYSTEM_FAULT. RETRY_OPERATION.');
}
