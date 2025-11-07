import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heavyweight_app/fortress/calibration/calibration_resume_store.dart';

void main() {
  group('CalibrationResumeStore', () {
    setUp(() async {
      // Set up mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load calibration attempts', () async {
      const testExercise = 'bench';
      const testAttempt = 2;
      const testWeight = 80.0;
      const testReps = 5;
      const testEst1RM = 90.0;
      const testNextWeight = 85.0;

      await CalibrationResumeStore.saveAttempt(
        exerciseId: testExercise,
        attemptIdx: testAttempt,
        signedLoadKg: testWeight,
        effectiveLoadKg: testWeight,
        reps: testReps,
        est1RmKg: testEst1RM,
        nextSignedKg: testNextWeight,
      );

      final loaded = await CalibrationResumeStore.loadPending();

      expect(loaded, isNotNull);
      expect(loaded!.exerciseId, equals(testExercise));
      expect(loaded.attemptIdx, equals(testAttempt));
      expect(loaded.signedLoadKg, equals(testWeight));
      expect(loaded.reps, equals(testReps));
      expect(loaded.est1RmKg, equals(testEst1RM));
      expect(loaded.nextSignedKg, equals(testNextWeight));
    });

    test('should generate checksums for data integrity', () async {
      await CalibrationResumeStore.saveAttempt(
        exerciseId: 'squat',
        attemptIdx: 1,
        signedLoadKg: 100.0,
        effectiveLoadKg: 100.0,
        reps: 8,
        est1RmKg: 125.0,
        nextSignedKg: 110.0,
      );

      final loaded = await CalibrationResumeStore.loadPending();

      expect(loaded, isNotNull);
      expect(loaded!.checksum, isNotEmpty);
      expect(loaded.checksum.length, greaterThan(5));
    });

    test('should handle corrupted data gracefully', () async {
      // Manually corrupt the stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hw_calibration_resume_state', 'invalid_json');

      final loaded = await CalibrationResumeStore.loadPending();

      // Should return null for corrupted data
      expect(loaded, isNull);
    });

    test('should clear calibration data', () async {
      // Save some data
      await CalibrationResumeStore.saveAttempt(
        exerciseId: 'deadlift',
        attemptIdx: 3,
        signedLoadKg: 120.0,
        effectiveLoadKg: 120.0,
        reps: 4,
        est1RmKg: 140.0,
        nextSignedKg: 115.0,
      );

      // Verify it exists
      var loaded = await CalibrationResumeStore.loadPending();
      expect(loaded, isNotNull);

      // Clear it
      await CalibrationResumeStore.clear();

      // Verify it's gone
      loaded = await CalibrationResumeStore.loadPending();
      expect(loaded, isNull);
    });

    group('Exercise Name Mapping', () {
      test('should map exercise slugs to proper names', () {
        expect(CalibrationResumeStore.mapSlugToName('bench'),
            equals('Bench Press'));
        expect(CalibrationResumeStore.mapSlugToName('squat'), equals('Squat'));
        expect(CalibrationResumeStore.mapSlugToName('deadlift'),
            equals('Deadlift'));
        expect(CalibrationResumeStore.mapSlugToName('overhead'),
            equals('Overhead Press'));
        expect(CalibrationResumeStore.mapSlugToName('row'), equals('Row'));
        expect(
            CalibrationResumeStore.mapSlugToName('pullup'), equals('Pull-ups'));
      });

      test('should map exercise names back to slugs', () {
        expect(CalibrationResumeStore.mapNameToSlug('Bench Press'),
            equals('bench'));
        expect(CalibrationResumeStore.mapNameToSlug('Squat'), equals('squat'));
        expect(CalibrationResumeStore.mapNameToSlug('Deadlift'),
            equals('deadlift'));
        expect(CalibrationResumeStore.mapNameToSlug('Overhead Press'),
            equals('overhead'));
        expect(CalibrationResumeStore.mapNameToSlug('Row'), equals('row'));
        expect(
            CalibrationResumeStore.mapNameToSlug('Pull-ups'), equals('pullup'));
      });

      test('should handle case insensitive name mapping', () {
        expect(CalibrationResumeStore.mapNameToSlug('BENCH PRESS'),
            equals('bench'));
        expect(CalibrationResumeStore.mapNameToSlug('bench press'),
            equals('bench'));
        expect(CalibrationResumeStore.mapNameToSlug('Bench press'),
            equals('bench'));
      });

      test('should handle unknown exercise names gracefully', () {
        final result = CalibrationResumeStore.mapNameToSlug('Unknown Exercise');
        expect(result, equals('unknown_exercise'));
      });
    });
  });
}
