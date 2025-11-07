import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heavyweight_app/core/training_state.dart';

void main() {
  group('TrainingState', () {
    setUp(() async {
      // Set up mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve training day assignments', () async {
      const testDay = 'CHEST';

      await TrainingState.assignDay(testDay);
      final retrievedDay = await TrainingState.getLastAssignedDay();

      expect(retrievedDay, equals(testDay));
    });

    test('should track training streaks correctly', () async {
      // Start with no streak
      var streak = await TrainingState.getCurrentStreak();
      expect(streak, equals(0));

      // Complete a day
      await TrainingState.completeDay();
      streak = await TrainingState.getCurrentStreak();
      expect(streak, equals(1));

      // Complete another day
      await TrainingState.completeDay();
      streak = await TrainingState.getCurrentStreak();
      expect(streak, equals(2));
    });

    test('should calculate days since last workout', () async {
      final daysSince = await TrainingState.getDaysSinceLastWorkout();

      // Should return 999 if never worked out
      expect(daysSince, equals(999));
    });

    test('should reset streak when requested', () async {
      // Build up a streak
      await TrainingState.completeDay();
      await TrainingState.completeDay();

      var streak = await TrainingState.getCurrentStreak();
      expect(streak, equals(2));

      // Reset it
      await TrainingState.resetStreak();
      streak = await TrainingState.getCurrentStreak();
      expect(streak, equals(0));
    });

    test('should clear all training state', () async {
      // Set up some state
      await TrainingState.assignDay('LEGS');
      await TrainingState.completeDay();

      // Verify it exists
      var day = await TrainingState.getLastAssignedDay();
      var streak = await TrainingState.getCurrentStreak();
      expect(day, equals('LEGS'));
      expect(streak, equals(1));

      // Clear everything
      await TrainingState.clearAll();

      // Verify it's gone
      day = await TrainingState.getLastAssignedDay();
      streak = await TrainingState.getCurrentStreak();
      expect(day, isNull);
      expect(streak, equals(0));
    });
  });
}
