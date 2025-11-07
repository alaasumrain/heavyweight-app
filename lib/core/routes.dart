import 'package:flutter/material.dart';
import '../screens/training/daily_workout_screen.dart';
import '../screens/training/protocol_screen.dart';
import '../screens/training/enforced_rest_screen.dart';
import '../screens/dev/config_screen.dart';

typedef ScreenBuilder = Widget Function(BuildContext);

class ScreenRegistry {
  static final Map<String, ScreenBuilder> _map = {};

  static void register(String name, ScreenBuilder builder) {
    _map[name] = builder;
  }

  static Map<String, ScreenBuilder> get all => Map.unmodifiable(_map);
}

void registerScreens() {
  // Register core screens (extend as needed)
  ScreenRegistry.register('DailyWorkout', (_) => const DailyWorkoutScreen());
  ScreenRegistry.register('Protocol', (_) => const ProtocolScreen());
  ScreenRegistry.register('EnforcedRest', (_) => const EnforcedRestScreen());
  // SessionCompleteScreen requires parameters - use nav.dart routing instead
  ScreenRegistry.register('DevConfig', (_) => const DevConfigScreen());
}
