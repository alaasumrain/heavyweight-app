import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  print('✓ Commitment cleared - User will see manifesto on next launch');
  
  // Also clear any workout history
  await prefs.remove('fortress_committed');
  await prefs.remove('fortress_commitment');
  await prefs.remove('workout_history');
  
  print('✓ All Fortress data reset');
}