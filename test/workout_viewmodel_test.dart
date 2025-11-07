import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:heavyweight_app/core/cache_service.dart';
import 'package:heavyweight_app/fortress/engine/models/exercise.dart';
import 'package:heavyweight_app/fortress/engine/models/set_data.dart';
import 'package:heavyweight_app/fortress/engine/models/workout_day.dart';
import 'package:heavyweight_app/fortress/engine/storage/workout_repository_interface.dart';
import 'package:heavyweight_app/fortress/engine/workout_engine.dart';
import 'package:heavyweight_app/fortress/viewmodels/workout_viewmodel.dart';

class TestWorkoutRepository implements WorkoutRepositoryInterface {
  TestWorkoutRepository({
    List<SetData>? history,
    this.getHistoryError,
    this.saveSetError,
  }) : _history = List<SetData>.from(history ?? const []);

  List<SetData> _history;
  final Exception? getHistoryError;
  final Exception? saveSetError;
  final List<SetData> savedSets = [];
  bool calibrationComplete = true;
  PerformanceStats stats = PerformanceStats.empty();

  @override
  Future<void> saveSet(SetData set) async {
    if (saveSetError != null) throw saveSetError!;
    savedSets.add(set);
  }

  @override
  Future<List<SetData>> getHistory() async {
    if (getHistoryError != null) throw getHistoryError!;
    return List<SetData>.from(_history);
  }

  @override
  Future<List<SetData>> getExerciseHistory(String exerciseId) async {
    return _history.where((set) => set.exerciseId == exerciseId).toList();
  }

  @override
  Future<WorkoutSession?> getLastSession() async => null;

  @override
  Future<void> markCalibrationComplete() async {
    calibrationComplete = true;
  }

  @override
  Future<bool> isCalibrationComplete() async => calibrationComplete;

  @override
  Future<void> saveExerciseWeights(Map<String, double> weights) async {}

  @override
  Future<Map<String, double>> getExerciseWeights() async => {};

  @override
  Future<double?> getLastWeight(String exerciseId) async => null;

  @override
  Future<void> clearAll() async {
    _history = [];
    savedSets.clear();
  }

  @override
  Future<PerformanceStats> getStats() async => stats;

  @override
  Future<Map<String, SetData>> getLastForExercises(
          Set<String> exerciseIds) async =>
      {};

  @override
  Future<List<WorkoutDay>> fetchWorkoutDays() async => [];

  @override
  Future<WorkoutDay?> fetchCompleteWorkoutDay(int workoutDayId) async => null;

  @override
  void dispose() {}

  void updateHistory(List<SetData> history) {
    _history = List<SetData>.from(history);
  }
}

class TestWorkoutEngine extends WorkoutEngine {
  TestWorkoutEngine({
    List<DailyWorkout>? workouts,
    this.generateError,
  })  : _queue = List<DailyWorkout>.from(workouts ?? const []),
        super();

  final List<DailyWorkout> _queue;
  final Exception? generateError;
  int generateCalls = 0;

  @override
  Future<DailyWorkout> generateDailyWorkout(List<SetData> history,
      {String? preferredStartingDay}) async {
    generateCalls++;
    if (generateError != null) throw generateError!;
    if (_queue.isNotEmpty) {
      return _queue.removeAt(0);
    }
    return DailyWorkout(
      date: DateTime(2024, 1, 1),
      dayName: 'REST',
      exercises: const [],
    );
  }

  void enqueue(DailyWorkout workout) {
    _queue.add(workout);
  }
}

DailyWorkout _makeWorkout(String dayName, {bool withExercise = true}) {
  return DailyWorkout(
    date: DateTime(2024, 1, 1),
    dayName: dayName,
    exercises: withExercise
        ? [
            PlannedExercise(
              exercise: Exercise.bigSix.first,
              prescribedWeight: 100,
              targetSets: 3,
              restSeconds: 180,
            ),
          ]
        : const [],
  );
}

SetData _makeSet({int setNumber = 1}) {
  return SetData(
    exerciseId: 'bench',
    weight: 100,
    actualReps: 5,
    timestamp: DateTime(2024, 1, 1, 9, setNumber),
    setNumber: setNumber,
    restTaken: 180,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'public-anon-key',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService().clear();
  });

  group('WorkoutViewModel', () {
    late TestWorkoutRepository repository;
    late TestWorkoutEngine engine;
    late WorkoutViewModel viewModel;

    setUp(() {
      repository = TestWorkoutRepository();
      engine = TestWorkoutEngine(workouts: [
        _makeWorkout('CHEST'),
      ]);
      viewModel = WorkoutViewModel(repository: repository, engine: engine);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('starts in loading state', () {
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.error, isNull);
      expect(viewModel.todaysWorkout, isNull);
    });

    test('initialize loads workout and clears loading flag', () async {
      await viewModel.initialize();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.todaysWorkout?.dayName, 'CHEST');
      expect(viewModel.hasWorkout, isTrue);
    });

    test('initialize surfaces repository errors', () async {
      repository =
          TestWorkoutRepository(getHistoryError: Exception('Network failure'));
      engine = TestWorkoutEngine(workouts: [_makeWorkout('CHEST')]);
      viewModel = WorkoutViewModel(repository: repository, engine: engine);

      await viewModel.initialize();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, contains('Network failure'));
      expect(viewModel.todaysWorkout, isNull);
    });

    test('refresh fetches a new workout', () async {
      engine = TestWorkoutEngine(workouts: [
        _makeWorkout('CHEST'),
        _makeWorkout('BACK'),
      ]);
      viewModel = WorkoutViewModel(repository: repository, engine: engine);

      await viewModel.initialize();
      expect(viewModel.todaysWorkout?.dayName, 'CHEST');

      await viewModel.refresh();

      expect(viewModel.todaysWorkout?.dayName, 'BACK');
      expect(engine.generateCalls, 2);
    });

    test('processWorkoutResults saves sets and refreshes workout', () async {
      engine = TestWorkoutEngine(workouts: [
        _makeWorkout('CHEST'),
        _makeWorkout('BACK'),
      ]);
      repository = TestWorkoutRepository();
      viewModel = WorkoutViewModel(repository: repository, engine: engine);

      await viewModel.initialize();

      final results = [_makeSet(setNumber: 1), _makeSet(setNumber: 2)];
      repository.updateHistory(results);

      await viewModel.processWorkoutResults(results);

      expect(repository.savedSets.length, results.length);
      expect(viewModel.error, isNull);
      expect(viewModel.todaysWorkout?.dayName, 'BACK');
    });

    test('processWorkoutResults captures repository failures', () async {
      repository =
          TestWorkoutRepository(saveSetError: Exception('Database error'));
      engine = TestWorkoutEngine(workouts: [_makeWorkout('CHEST')]);
      viewModel = WorkoutViewModel(repository: repository, engine: engine);

      final results = [_makeSet()];
      await viewModel.processWorkoutResults(results);

      expect(viewModel.error, contains('Database error'));
      expect(repository.savedSets, isEmpty);
    });

    test('hasWorkout is false for rest days', () async {
      engine = TestWorkoutEngine(workouts: [
        _makeWorkout('REST', withExercise: false),
      ]);
      viewModel = WorkoutViewModel(repository: repository, engine: engine);

      await viewModel.initialize();

      expect(viewModel.hasWorkout, isFalse);
      expect(viewModel.todaysWorkout?.exercises, isEmpty);
    });
  });
}
