import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heavyweight_app/core/cache_service.dart';
import 'package:heavyweight_app/fortress/engine/models/set_data.dart';
import 'package:heavyweight_app/fortress/engine/models/workout_day.dart';
import 'package:heavyweight_app/fortress/engine/storage/workout_repository_interface.dart';
import 'package:heavyweight_app/fortress/viewmodels/logbook_viewmodel.dart';

class FakeWorkoutRepository implements WorkoutRepositoryInterface {
  FakeWorkoutRepository({
    required this.history,
    required this.stats,
  });

  final List<SetData> history;
  final PerformanceStats stats;

  @override
  Future<void> clearAll() async {}

  @override
  Future<List<SetData>> getExerciseHistory(String exerciseId) async =>
      history.where((set) => set.exerciseId == exerciseId).toList();

  @override
  Future<List<SetData>> getHistory() async => history;

  @override
  Future<WorkoutSession?> getLastSession() async => null;

  @override
  Future<Map<String, double>> getExerciseWeights() async => {};

  @override
  Future<double?> getLastWeight(String exerciseId) async => null;

  @override
  Future<Map<String, SetData>> getLastForExercises(
          Set<String> exerciseIds) async =>
      {};

  @override
  Future<void> markCalibrationComplete() async {}

  @override
  Future<bool> isCalibrationComplete() async => true;

  @override
  Future<void> saveExerciseWeights(Map<String, double> weights) async {}

  @override
  Future<void> saveSet(SetData set) async {}

  @override
  Future<List<WorkoutDay>> fetchWorkoutDays() async => [];

  @override
  Future<WorkoutDay?> fetchCompleteWorkoutDay(int workoutDayId) async => null;

  @override
  void dispose() {}

  @override
  Future<PerformanceStats> getStats() async => stats;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheService().clear();
  });

  tearDown(() {
    CacheService().dispose();
  });

  group('LogbookViewModel.initialize', () {
    test('groups set history into sessions ordered by date desc', () async {
      final now = DateTime(2024, 5, 10, 18);
      final history = <SetData>[
        SetData(
          exerciseId: 'bench',
          weight: 100,
          actualReps: 5,
          timestamp: now.subtract(const Duration(minutes: 10)),
          setNumber: 2,
          restTaken: 180,
        ),
        SetData(
          exerciseId: 'bench',
          weight: 100,
          actualReps: 5,
          timestamp: now.subtract(const Duration(minutes: 20)),
          setNumber: 1,
          restTaken: 180,
        ),
        SetData(
          exerciseId: 'squat',
          weight: 140,
          actualReps: 4,
          timestamp: now.subtract(const Duration(days: 1, minutes: 5)),
          setNumber: 1,
          restTaken: 240,
        ),
      ];

      final repository = FakeWorkoutRepository(
        history: history,
        stats: const PerformanceStats(
          totalSets: 3,
          mandateSets: 2,
          failureSets: 0,
          exceededSets: 0,
          totalVolume: 1040,
          workoutDays: 2,
          mandateAdherence: 80,
        ),
      );

      final viewModel = LogbookViewModel(repository: repository);

      await viewModel.initialize(forceRefresh: true);

      expect(viewModel.sessions, hasLength(2));

      final firstSession = viewModel.sessions.first;
      expect(firstSession.date.year, 2024);
      expect(firstSession.date.day, 10);
      expect(firstSession.sets.map((s) => s.setNumber), orderedEquals([1, 2]));

      expect(viewModel.stats.totalSets, 3);
      expect(viewModel.stats.workoutDays, 2);
    });
  });

  group('LogbookViewModel helpers', () {
    test('computes summaries, duration, volume and day name', () async {
      final sessionDate = DateTime(2024, 3, 3, 9);
      final history = <SetData>[
        SetData(
          exerciseId: 'bench',
          weight: 100,
          actualReps: 5,
          timestamp: sessionDate,
          setNumber: 1,
          restTaken: 180,
        ),
        SetData(
          exerciseId: 'bench',
          weight: 100,
          actualReps: 6,
          timestamp: sessionDate.add(const Duration(minutes: 5)),
          setNumber: 2,
          restTaken: 180,
        ),
        SetData(
          exerciseId: 'row',
          weight: 80,
          actualReps: 7,
          timestamp: sessionDate.add(const Duration(minutes: 30)),
          setNumber: 1,
          restTaken: 200,
        ),
      ];

      final repository = FakeWorkoutRepository(
        history: history,
        stats: PerformanceStats.empty(),
      );

      final viewModel = LogbookViewModel(repository: repository);
      await viewModel.initialize(forceRefresh: true);

      final session = viewModel.sessions.first;

      expect(viewModel.getWorkoutDayName(session), 'CHEST');
      expect(viewModel.getSessionDuration(session), '15 MIN');
      expect(viewModel.getSessionVolume(session),
          closeTo(100 * 11 + 80 * 7, 1e-6));
      expect(
        viewModel.getExerciseSummary(session),
        orderedEquals([
          'BENCH PRESS: 2x6 @ 100.0kg',
          'BARBELL ROW: 1x7 @ 80.0kg',
        ]),
      );
    });
  });
}
