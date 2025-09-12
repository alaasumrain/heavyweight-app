import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/logging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/fortress/engine/models/exercise.dart';
import '/fortress/engine/models/set_data.dart';
import '/fortress/engine/models/workout_day.dart';
import '/fortress/engine/storage/workout_repository_interface.dart';
import 'supabase.dart';

/// Supabase-backed repository for workout data persistence
/// Replaces SharedPreferences with real database operations
class SupabaseWorkoutRepository implements WorkoutRepositoryInterface {
  final SupabaseClient _supabase = supabase;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  /// Current workout session ID - kept in memory during active workout
  String? _currentWorkoutId;
  
  /// Cache for exercises fetched from database
  List<Exercise>? _exercisesCache;
  
  /// Initialize connectivity monitoring
  SupabaseWorkoutRepository() {
    _initializeConnectivityMonitoring();
  }

  @override
  Future<void> saveSet(SetData set) async {
    try {
      // Ensure we have an active workout
      if (_currentWorkoutId == null) {
        await _createWorkoutSession();
      }

      // Insert set into database
      await _supabase.from('sets').insert({
        'workout_id': int.parse(_currentWorkoutId!),
        'exercise_id': await _getExerciseIdFromSetData(set),
        'weight': set.weight,
        'actual_reps': set.actualReps,
        'target_reps': 5, // Always 4-6 range, 5 is middle
        'notes': null,
      });
      
      // Fire and forget - don't block UI
    } catch (error) {
      // Log error but don't block UI
      print('Failed to save set: $error');
      HWLog.event('repo_save_set_error', data: {'error': error.toString()});
      // Add to offline queue for retry when network available
      await _addToOfflineQueue('saveSet', set.toJson());
    }
  }

  @override
  Future<List<SetData>> getHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Get all sets for this user, joined with workout and exercise data
      final response = await _supabase
          .from('sets')
          .select('''
            *,
            workouts!inner(user_id),
            exercises!inner(name)
          ''')
          .eq('workouts.user_id', userId)
          .order('created_at', ascending: false);

      return response.map<SetData>((row) {
        return SetData(
          exerciseId: Exercise.mapNameToId(row['exercises']['name']),
          weight: _parseWeight(row['weight']),
          actualReps: _parseInt(row['actual_reps']),
          timestamp: DateTime.parse(row['created_at']),
          setNumber: _parseInt(row['set_number'] ?? 1),
          restTaken: _parseInt(row['rest_taken'] ?? 180),
        );
      }).toList();
    } catch (error) {
      print('Failed to get history: $error');
      HWLog.event('repo_get_history_error', data: {'error': error.toString()});
      return [];
    }
  }

  @override
  Future<List<SetData>> getExerciseHistory(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Get exercise database ID
      final exerciseDbId = await _getExerciseDbId(exerciseId);
      if (exerciseDbId == null) return [];

      final response = await _supabase
          .from('sets')
          .select('''
            *,
            workouts!inner(user_id)
          ''')
          .eq('workouts.user_id', userId)
          .eq('exercise_id', exerciseDbId)
          .order('created_at', ascending: false);

      return response.map<SetData>((row) {
        return SetData(
          exerciseId: exerciseId,
          weight: _parseWeight(row['weight']),
          actualReps: _parseInt(row['actual_reps']),
          timestamp: DateTime.parse(row['created_at']),
          setNumber: _parseInt(row['set_number'] ?? 1),
          restTaken: _parseInt(row['rest_taken'] ?? 180),
        );
      }).toList();
    } catch (error) {
      print('Failed to get exercise history: $error');
      HWLog.event('repo_get_exercise_history_error', data: {'error': error.toString()});
      return [];
    }
  }

  @override
  Future<WorkoutSession?> getLastSession() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Get most recent completed workout
      final response = await _supabase
          .from('workouts')
          .select('''
            *,
            sets(*)
          ''')
          .eq('user_id', userId)
          .not('ended_at', 'is', null)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      final workoutData = response.first;
      final sets = (workoutData['sets'] as List).map<SetData>((setData) {
        return SetData(
          exerciseId: setData['exercise_id'].toString(),
          weight: (setData['weight'] as num).toDouble(),
          actualReps: setData['actual_reps'] as int,
          timestamp: DateTime.parse(setData['created_at']),
          setNumber: 1,
          restTaken: 180,
        );
      }).toList();

      return WorkoutSession(
        id: workoutData['id'].toString(),
        date: DateTime.parse(workoutData['created_at']),
        sets: sets,
        completed: workoutData['ended_at'] != null,
      );
    } catch (error) {
      print('Failed to get last session: $error');
      HWLog.event('repo_get_last_session_error', data: {'error': error.toString()});
      return null;
    }
  }

  @override
  Future<void> markCalibrationComplete() async {
    // This could be stored in user profile or as a flag
    // For now, we'll use the presence of workout data as calibration marker
  }

  @override
  Future<bool> isCalibrationComplete() async {
    // Check if user has any workout history
    final history = await getHistory();
    return history.isNotEmpty;
  }

  @override
  Future<void> saveExerciseWeights(Map<String, double> weights) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update user profile with calibrated weights
      await _supabase.from('profiles').upsert({
        'id': userId,
        'exercise_weights': weights,
      });
    } catch (error) {
      print('Failed to save exercise weights: $error');
      HWLog.event('repo_save_exercise_weights_error', data: {'error': error.toString()});
    }
  }

  @override
  Future<Map<String, double>> getExerciseWeights() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      final response = await _supabase
          .from('profiles')
          .select('exercise_weights')
          .eq('id', userId)
          .single();

      final weights = response['exercise_weights'] as Map<String, dynamic>?;
      if (weights == null) return {};

      return weights.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (error) {
      print('Failed to get exercise weights: $error');
      HWLog.event('repo_get_exercise_weights_error', data: {'error': error.toString()});
      return {};
    }
  }

  @override
  Future<double?> getLastWeight(String exerciseId) async {
    final history = await getExerciseHistory(exerciseId);
    if (history.isEmpty) return null;
    
    return history.first.weight;
  }

  @override
  Future<void> clearAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Delete all user's workout data
      await _supabase.from('workouts').delete().eq('user_id', userId);
      // Sets will be cascade deleted due to foreign key constraint
      
      // Clear calibration data
      await _supabase.from('profiles').upsert({
        'id': userId,
        'exercise_weights': {},
      });
    } catch (error) {
      print('Failed to clear all data: $error');
      HWLog.event('repo_clear_all_error', data: {'error': error.toString()});
    }
  }

  @override
  Future<PerformanceStats> getStats() async {
    final history = await getHistory();
    if (history.isEmpty) {
      return PerformanceStats.empty();
    }
    
    int totalSets = history.length;
    int mandateSets = history.where((s) => s.metMandate).length;
    int failureSets = history.where((s) => s.isFailure).length;
    int exceededSets = history.where((s) => s.exceededMandate).length;
    
    double totalVolume = 0;
    for (final set in history) {
      totalVolume += set.weight * set.actualReps;
    }
    
    final uniqueDays = history
        .map((s) => DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day))
        .toSet()
        .length;
    
    return PerformanceStats(
      totalSets: totalSets,
      mandateSets: mandateSets,
      failureSets: failureSets,
      exceededSets: exceededSets,
      totalVolume: totalVolume,
      workoutDays: uniqueDays,
      mandateAdherence: totalSets > 0 ? (mandateSets / totalSets) * 100 : 0,
    );
  }

  /// Fetch exercises from Supabase database
  Future<List<Exercise>> getExercises() async {
    if (_exercisesCache != null) {
      return _exercisesCache!;
    }

    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .order('id', ascending: true);

      _exercisesCache = response.map<Exercise>((row) {
        return Exercise.fromSupabase(row);
      }).toList();

      return _exercisesCache!;
    } catch (error) {
      print('Failed to fetch exercises: $error');
      HWLog.event('repo_fetch_exercises_error', data: {'error': error.toString()});
      // Return default big six if database fails
      return Exercise.bigSix;
    }
  }

  /// Fetch workout days from Supabase database
  @override
  Future<List<WorkoutDay>> fetchWorkoutDays() async {
    try {
      final response = await _supabase
          .from('workout_days')
          .select('*')
          .order('day_order', ascending: true);

      return response.map<WorkoutDay>((row) {
        return WorkoutDay.fromDatabase(
          id: row['id'],
          name: row['name'],
          dayOrder: row['day_order'],
        );
      }).toList();
    } catch (error) {
      print('Failed to fetch workout days: $error');
      HWLog.event('repo_fetch_workout_days_error', data: {'error': error.toString()});
      return [];
    }
  }

  /// Fetch exercises for a specific workout day
  Future<List<DayExercise>> fetchDayExercises(int workoutDayId) async {
    try {
      final response = await _supabase
          .from('day_exercises')
          .select('''
            *,
            exercises!inner(*)
          ''')
          .eq('workout_day_id', workoutDayId)
          .order('order_in_day', ascending: true);

      return response.map<DayExercise>((row) {
        final exerciseData = row['exercises'];
        final exercise = Exercise.fromDatabase(
          databaseId: exerciseData['id'],
          name: exerciseData['name'],
          description: exerciseData['description'] ?? '',
        );

        return DayExercise.fromDatabase(
          id: row['id'],
          workoutDayId: row['workout_day_id'],
          orderInDay: row['order_in_day'],
          setsTarget: row['sets_target'],
          exercise: exercise,
        );
      }).toList();
    } catch (error) {
      print('Failed to fetch day exercises: $error');
      HWLog.event('repo_fetch_day_exercises_error', data: {'error': error.toString()});
      return [];
    }
  }

  /// Fetch complete workout day with exercises
  @override
  Future<WorkoutDay?> fetchCompleteWorkoutDay(int workoutDayId) async {
    // Check if Supabase is available
    if (!SupabaseService.isAvailable) {
      HWLog.event('repo_fetch_day_supabase_unavailable', data: {'dayId': workoutDayId});
      return null; // Let caller handle fallback
    }
    
    try {
      // Add timeout to prevent hanging
      final dayResponse = await _supabase
          .from('workout_days')
          .select('*')
          .eq('id', workoutDayId)
          .single()
          .timeout(const Duration(seconds: 5));

      // Get exercises for this day
      final exercises = await fetchDayExercises(workoutDayId);

      final workoutDay = WorkoutDay.fromDatabase(
        id: dayResponse['id'],
        name: dayResponse['name'],
        dayOrder: dayResponse['day_order'],
        exercises: exercises,
      );
      
      HWLog.event('repo_fetch_complete_day_success', data: {
        'dayId': workoutDayId,
        'exerciseCount': exercises.length
      });
      
      return workoutDay;
    } catch (error) {
      HWLog.event('repo_fetch_complete_day_error', data: {
        'dayId': workoutDayId,
        'error': error.toString()
      });
      if (kDebugMode) {
        debugPrint('Failed to fetch complete workout day $workoutDayId: $error');
      }
      return null; // Let caller handle fallback
    }
  }

  /// Create a new workout session when first set is logged
  Future<void> _createWorkoutSession() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('workouts')
          .insert({
            'user_id': userId,
          })
          .select()
          .single();

      _currentWorkoutId = response['id'].toString();
    } catch (error) {
      print('Failed to create workout session: $error');
      HWLog.event('repo_create_session_error', data: {'error': error.toString()});
      rethrow;
    }
  }

  /// End the current workout session
  Future<void> endWorkoutSession() async {
    if (_currentWorkoutId == null) return;

    try {
      await _supabase
          .from('workouts')
          .update({'ended_at': DateTime.now().toIso8601String()})
          .eq('id', int.parse(_currentWorkoutId!));

      _currentWorkoutId = null;
    } catch (error) {
      print('Failed to end workout session: $error');
      HWLog.event('repo_end_session_error', data: {'error': error.toString()});
    }
  }


  /// Get database exercise ID for internal exercise ID
  Future<int?> _getExerciseDbId(String exerciseId) async {
    try {
      final exercises = await getExercises();
      final exercise = exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      // Find the database ID for this exercise
      final response = await _supabase
          .from('exercises')
          .select('id')
          .eq('name', exercise.name)
          .single();

      return response['id'] as int;
    } catch (error) {
      print('Failed to get exercise DB ID: $error');
      HWLog.event('repo_get_exercise_id_error', data: {'error': error.toString()});
      return null;
    }
  }

  /// Extract exercise ID from SetData for database insertion
  Future<int> _getExerciseIdFromSetData(SetData set) async {
    // Get the exercise from the Big Six to ensure it exists
    final exercise = Exercise.getById(set.exerciseId);
    if (exercise == null) {
      print('Warning: Unknown exercise ID ${set.exerciseId}, defaulting to squat');
      HWLog.event('repo_unknown_exercise_id', data: {'id': set.exerciseId});
      return 1; // Default to squat
    }
    
    // Get the database ID for this exercise
    final dbId = await _getExerciseDbId(set.exerciseId);
    return dbId ?? 1; // Default to squat if lookup fails
  }

  /// Safe weight parsing with validation
  double _parseWeight(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  /// Safe integer parsing with validation
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  /// Initialize connectivity monitoring to process queue when network returns
  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          // Network is available, process offline queue
          processOfflineQueue().catchError((error) {
            print('Failed to process offline queue on reconnect: $error');
            HWLog.event('repo_offline_queue_reconnect_error', data: {'error': error.toString()});
          });
        }
      },
    );
    
    // Also process queue on initialization in case we have network now
    Future.delayed(Duration.zero, () {
      processOfflineQueue().catchError((error) {
        print('Failed to process offline queue on startup: $error');
        HWLog.event('repo_offline_queue_startup_error', data: {'error': error.toString()});
      });
    });
  }

  /// Clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Add failed operations to offline queue for retry
  Future<void> _addToOfflineQueue(String operation, Map<String, dynamic> data) async {
    try {
      // Simple offline queue using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('offline_queue') ?? [];
      
      final queueItem = {
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      queue.add(jsonEncode(queueItem));
      await prefs.setStringList('offline_queue', queue);
      print('Added ${operation} to offline queue');
      HWLog.event('repo_offline_queue_add', data: {'op': operation});
    } catch (e) {
      print('Failed to add to offline queue: $e');
      HWLog.event('repo_offline_queue_add_error', data: {'error': e.toString()});
    }
  }

  /// Process offline queue and retry failed operations
  Future<void> processOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('offline_queue') ?? [];
      
      if (queue.isEmpty) return;
      
      print('Processing ${queue.length} items from offline queue');
      HWLog.event('repo_offline_queue_process_start', data: {'count': queue.length});
      final processedItems = <String>[];
      
      for (final queueItemJson in queue) {
        try {
          final queueItem = jsonDecode(queueItemJson) as Map<String, dynamic>;
          final operation = queueItem['operation'] as String;
          final data = queueItem['data'] as Map<String, dynamic>;
          
          await _retryOperation(operation, data);
          processedItems.add(queueItemJson);
          print('Successfully processed queued ${operation}');
          HWLog.event('repo_offline_queue_processed', data: {'op': operation});
        } catch (e) {
          print('Failed to process queued operation: $e');
          HWLog.event('repo_offline_queue_process_error', data: {'error': e.toString()});
          // Leave the item in queue for next retry
        }
      }
      
      // Remove successfully processed items
      if (processedItems.isNotEmpty) {
        final remainingQueue = queue.where((item) => !processedItems.contains(item)).toList();
        await prefs.setStringList('offline_queue', remainingQueue);
        print('Removed ${processedItems.length} processed items from queue');
        HWLog.event('repo_offline_queue_removed', data: {'count': processedItems.length});
      }
    } catch (e) {
      print('Failed to process offline queue: $e');
      HWLog.event('repo_offline_queue_process_error', data: {'error': e.toString()});
    }
  }

  /// Retry a failed operation
  Future<void> _retryOperation(String operation, Map<String, dynamic> data) async {
    switch (operation) {
      case 'saveSet':
        final setData = SetData.fromJson(data);
        await saveSet(setData);
        break;
      default:
        throw Exception('Unknown operation: $operation');
    }
  }

}
