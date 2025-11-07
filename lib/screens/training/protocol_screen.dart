import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../fortress/protocol/widgets/rest_timer.dart';
import '../../fortress/protocol/widgets/rep_logger.dart';
import '../../fortress/engine/workout_engine.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../backend/supabase/supabase_workout_repository.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/logging.dart';
import '../../viewmodels/exercise_viewmodel.dart';
import '../../components/ui/exercise_alternatives_widget.dart';
import '../../core/system_config.dart';
import '../../core/units.dart';
import '../../providers/profile_provider.dart';
import '../../fortress/calibration/calibration_resume_store.dart';
import '../../components/ui/hw_badge.dart';
import '../../core/cache_service.dart';
import '../../core/workout_session_manager.dart';

/// The Protocol Screen - The heart of the workout experience
/// Minimalist, brutal, effective
class ProtocolScreen extends StatefulWidget {
  final DailyWorkout? workout;

  const ProtocolScreen({
    super.key,
    this.workout,
  });

  @override
  State<ProtocolScreen> createState() => _ProtocolScreenState();
}

class _ProtocolScreenState extends State<ProtocolScreen> {
  late SupabaseWorkoutRepository _repository;
  late WorkoutEngine _engine;

  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restSeconds = 180; // 3 minutes - THE MANDATE

  // Calibration mode tracking
  bool _isCalibrating = false;
  double _currentCalibrationWeight = 40.0;
  int _calibrationAttempt = 1;
  final List<_CalibrationEntry> _calibrationEntries = [];
  bool _resumedCalibration = false;
  bool _oscillationTriggered = false;
  final Map<String, double> _calibratedWeights = {};

  // Weight adjustment system
  final Map<String, double> _adjustedWeights = {};
  bool _showWeightAdjustment = false;
  String? _lastAdjustmentReason;

  List<SetData> _sessionSets = [];
  bool _showSaveSuccess = false;

  @override
  void initState() {
    super.initState();
    HWLog.screen('Training/Protocol');
    HWLog.event('protocol_screen_init', data: {
      'workout': widget.workout?.dayName ?? 'unknown',
      'exerciseCount': widget.workout?.exercises.length ?? 0,
      'hasWorkout': widget.workout != null,
    });
    _initializeRepository();
    _engine = WorkoutEngine();

    // Try to restore session state first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRestoreSessionState();
    });

    // Check if mandate is valid and has exercises
    if (widget.workout?.exercises.isNotEmpty == true) {
      final firstPrescription = widget.workout!.exercises[0];
      _isCalibrating = firstPrescription.needsCalibration;
      if (_isCalibrating) {
        _currentCalibrationWeight = firstPrescription.prescribedWeight;
      }
      // Attempt resume of unfinished calibration
      _tryResumeCalibration();
    } else {
      // No valid mandate - this shouldn't happen, but handle gracefully
      HWLog.event('protocol_screen_no_workout', data: {
        'hasWorkout': widget.workout != null,
        'exerciseCount': widget.workout?.exercises.length ?? 0,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: HeavyweightTheme.danger,
              content: Text(
                'NO WORKOUT DATA AVAILABLE - RETURNING TO DASHBOARD',
                style: TextStyle(color: HeavyweightTheme.primary),
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Repository dispose is handled by the repository itself
    // No additional cleanup needed for WorkoutEngine (it's stateless)
    super.dispose();
  }

  Widget _buildRepLoggerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepLogger(
          onRepsLogged: _onRepsLogged,
          initialValue: 5,
          currentSet: _currentSet,
          previousSetReps: _getPreviousSetRepsForCurrentExercise(),
          liveMode: true,
        ),
        if (_showSaveSuccess) ...[
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: HeavyweightTheme.spacingXs),
              Text(
                'SET LOGGED',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _tryResumeCalibration() async {
    final rec = await CalibrationResumeStore.loadPending();
    if (rec == null) return;
    final idx = widget.workout!.exercises
        .indexWhere((e) => e.exercise.id == rec.exerciseId);
    if (idx == -1) return;
    setState(() {
      _currentExerciseIndex = idx;
      _isCalibrating = true;
      _calibrationAttempt = rec.attemptIdx + 1; // next expected
      _currentCalibrationWeight = rec.nextSignedKg;
      _resumedCalibration = true;
    });
  }

  Future<void> _initializeRepository() async {
    _repository = SupabaseWorkoutRepository();
  }

  /// Try to restore session state if this is a resumed workout
  Future<void> _tryRestoreSessionState() async {
    final session = await WorkoutSessionManager.loadActiveSession();
    if (session != null && mounted) {
      setState(() {
        _currentExerciseIndex = session.currentExerciseIndex;
        _currentSet = session.currentSet;
        _sessionSets = List.from(session.sessionSets);
        _isResting = session.isResting;
        if (session.restTimeRemaining != null) {
          _restSeconds = session.restTimeRemaining!;
        }
        _rebuildCalibratedWeightsFromSession();
        _syncCalibrationStateForCurrentExercise();
      });

      HWLog.event('training_session_restored', data: {
        'exerciseIndex': _currentExerciseIndex,
        'set': _currentSet,
        'completedSets': _sessionSets.length,
        'isResting': _isResting,
      });
    } else if (widget.workout != null) {
      await WorkoutSessionManager.saveActiveSession(
        workout: widget.workout!,
        currentExerciseIndex: _currentExerciseIndex,
        currentSet: _currentSet,
        sessionSets: _sessionSets,
        isResting: _isResting,
        restTimeRemaining: _isResting ? _restSeconds : null,
      );
    }
  }

  void _rebuildCalibratedWeightsFromSession() {
    _calibratedWeights.clear();
    for (final set in _sessionSets) {
      if (set.setNumber == 0) {
        _calibratedWeights[set.exerciseId] = set.weight;
      } else {
        _calibratedWeights.putIfAbsent(set.exerciseId, () => set.weight);
      }
    }
  }

  void _syncCalibrationStateForCurrentExercise() {
    if (widget.workout == null || widget.workout!.exercises.isEmpty) return;
    final currentExerciseId =
        widget.workout!.exercises[_currentExerciseIndex].exercise.id;
    final hasWorkingSets = _sessionSets.any(
      (set) => set.exerciseId == currentExerciseId && set.setNumber > 0,
    );
    final hasCalibrationSet = _sessionSets.any(
      (set) => set.exerciseId == currentExerciseId && set.setNumber == 0,
    );

    if (hasWorkingSets || hasCalibrationSet) {
      _isCalibrating = false;
      if (_calibratedWeights.containsKey(currentExerciseId)) {
        _currentCalibrationWeight = _calibratedWeights[currentExerciseId]!;
      }
    } else {
      _isCalibrating = true;
      _currentCalibrationWeight =
          widget.workout!.exercises[_currentExerciseIndex].prescribedWeight;
    }
  }

  /// Save current workout session state for crash recovery
  Future<void> _saveSessionState() async {
    if (widget.workout == null) return;

    await WorkoutSessionManager.saveActiveSession(
      workout: widget.workout!,
      currentExerciseIndex: _currentExerciseIndex,
      currentSet: _currentSet,
      sessionSets: _sessionSets,
      isResting: _isResting,
      restTimeRemaining: _isResting ? _restSeconds : null,
    );
  }

  /// Build exercise progress indicator showing current position in workout
  Widget _buildExerciseProgress() {
    if (widget.workout?.exercises.isEmpty != false) {
      return const SizedBox();
    }

    final totalExercises = widget.workout!.exercises.length;
    final current = _currentExerciseIndex + 1;
    final currentEx = widget.workout!.exercises[_currentExerciseIndex];
    final completedSetsForExercise = _sessionSets
        .where((set) => set.exerciseId == currentEx.exercise.id)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXERCISE $current/$totalExercises',
          style: HeavyweightTheme.labelSmall.copyWith(
            color: HeavyweightTheme.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingXs),

        // Exercise progress dots
        Row(
          children: widget.workout!.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final isCurrent = index == _currentExerciseIndex;
            final isCompleted = index < _currentExerciseIndex;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? HeavyweightTheme.success
                    : isCurrent
                        ? HeavyweightTheme.primary
                        : HeavyweightTheme.secondary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: HeavyweightTheme.spacingXs),

        // Set progress for current exercise
        Text(
          'SET $completedSetsForExercise/${currentEx.targetSets}',
          style: HeavyweightTheme.labelSmall.copyWith(
            color: HeavyweightTheme.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  /// Save set data with offline fallback - workout continues even if network fails
  Future<void> _saveSetOfflineSafe(SetData setData) async {
    try {
      await _repository.saveSet(setData);
      HWLog.event('protocol_set_saved_online',
          data: {'exercise': setData.exerciseId});
    } catch (e) {
      // Network failed - log error but continue workout
      HWLog.event('protocol_set_save_offline', data: {
        'error': e.toString(),
        'exercise': setData.exerciseId,
        'reps': setData.actualReps,
      });

      // TODO: Queue for later sync when network returns
      // For now, workout data is preserved in session state and local storage

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'OFFLINE - DATA SAVED LOCALLY',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// End workout session with offline fallback
  Future<void> _endWorkoutSessionOfflineSafe() async {
    try {
      await _repository.endWorkoutSession();
      HWLog.event('protocol_session_ended_online');
    } catch (e) {
      // Network failed - log but allow workout completion
      HWLog.event('protocol_session_end_offline',
          data: {'error': e.toString()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'OFFLINE - WORKOUT COMPLETED LOCALLY',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Show confirmation dialog when user tries to exit during workout
  Future<bool> _showExitConfirmation(BuildContext context) async {
    final navigator = Navigator.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: HeavyweightTheme.background,
        title: const Text(
          'EXIT WORKOUT?',
          style: TextStyle(
            color: HeavyweightTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: const Text(
          'Your progress will be saved and you can resume later.\n\nAre you sure you want to exit?',
          style: TextStyle(
            color: HeavyweightTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text(
              'CONTINUE WORKOUT',
              style: TextStyle(color: HeavyweightTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _saveSessionState(); // Save before exit
              navigator.pop(true);
            },
            child: const Text(
              'EXIT',
              style: TextStyle(color: HeavyweightTheme.danger),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  PlannedExercise? get _currentPrescription {
    if (widget.workout?.exercises.isEmpty != false) {
      HWLog.event('protocol_current_prescription_null', data: {
        'hasWorkout': widget.workout != null,
        'exerciseCount': widget.workout?.exercises.length ?? 0,
        'currentIndex': _currentExerciseIndex,
      });
      return null;
    }
    if (_currentExerciseIndex >= widget.workout!.exercises.length) {
      HWLog.event('protocol_exercise_index_out_of_bounds', data: {
        'currentIndex': _currentExerciseIndex,
        'exerciseCount': widget.workout!.exercises.length,
      });
      return null;
    }
    return widget.workout!.exercises[_currentExerciseIndex];
  }

  /// Get current working weight (adjusted or prescribed)
  double get _currentWorkingWeight {
    final exerciseId = _currentPrescription?.exercise.id;
    if (exerciseId != null && _calibratedWeights.containsKey(exerciseId)) {
      return _calibratedWeights[exerciseId]!;
    }
    if (exerciseId != null && _adjustedWeights.containsKey(exerciseId)) {
      return _adjustedWeights[exerciseId]!;
    }
    return _currentPrescription?.prescribedWeight ?? 0.0;
  }

  /// Check if current exercise has been adjusted
  bool get _hasWeightAdjustment {
    final exerciseId = _currentPrescription?.exercise.id;
    return exerciseId != null && _adjustedWeights.containsKey(exerciseId);
  }

  void _onRepsLogged(int actualReps) async {
    HWLog.event('protocol_reps_logged', data: {'reps': actualReps});
    if (_isCalibrating) {
      // Calibration mode: finding the 5RM
      _handleCalibrationReps(actualReps);
    } else {
      // Normal workout mode
      _handleWorkoutReps(actualReps);
    }
  }

  void _handleCalibrationReps(int actualReps) async {
    HWLog.event('protocol_handle_calibration',
        data: {'reps': actualReps, 'weight': _currentCalibrationWeight});
    // Record attempt
    _calibrationEntries
        .add(_CalibrationEntry(_currentCalibrationWeight, actualReps));
    // Determine lock conditions
    final inMandate = actualReps >= 4 && actualReps <= 6;
    final reachedMax = _calibrationAttempt >= 3;
    if (inMandate || reachedMax) {
      // Choose best (closest to 5) if not in range
      final best = _selectBestCalibrationEntry(_calibrationEntries);
      _currentCalibrationWeight = best.weight;
      // Found the 5RM!
      if (_currentPrescription != null) {
        _calibratedWeights[_currentPrescription!.exercise.id] =
            _currentCalibrationWeight;
      }

      // If this is bench press on Day 1, estimate all other weights
      if (_currentPrescription?.exercise.id == 'bench') {
        final estimatedWeights =
            _engine.estimateWeightsFromBenchPress(_currentCalibrationWeight);
        _calibratedWeights.addAll(estimatedWeights);
      }

      // Save the calibration as a set
      final setData = SetData(
        exerciseId: _currentPrescription?.exercise.id ?? 'unknown',
        weight: _currentCalibrationWeight,
        actualReps: actualReps,
        timestamp: DateTime.now(),
        setNumber: 0,
        restTaken: 0,
      );
      // Save to repository with offline fallback
      await _saveSetOfflineSafe(setData);
      // Invalidate history cache since new data was added
      await CacheService().invalidateHistory();
      HWLog.event('protocol_save_set', data: {
        'exercise': setData.exerciseId,
        'reps': actualReps,
        'weight': setData.weight,
        'in_range': actualReps >= 4 && actualReps <= 6,
        'calib_attempts': _calibrationAttempt,
        'oscillation_locked': _oscillationTriggered,
        'resume_used': _resumedCalibration,
      });
      _sessionSets.add(setData);
      // Clear resume state since exercise is locked
      await CalibrationResumeStore.clear();
      // Lock message
      if (mounted) {
        final unit = context.read<ProfileProvider>().unit == Unit.kg
            ? HWUnit.kg
            : HWUnit.lb;
        final disp = formatWeightForUnit(_currentCalibrationWeight, unit);
        final msg =
            'WORKING WEIGHT LOCKED: $disp ${unit == HWUnit.kg ? 'KG' : 'LB'}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text(msg, style: const TextStyle(color: Colors.white)),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      }

      final restSeconds = _engine.calculateRestSeconds(actualReps, 180);
      final cfg = SystemConfig.instance;
      final resolvedRest = (cfg.isLoaded && cfg.debugShortRestEnabled)
          ? cfg.debugShortRestSeconds
          : restSeconds;

      setState(() {
        _isCalibrating = false;
        _calibrationAttempt = 1;
        _calibrationEntries.clear();
        _isResting = true;
        _restSeconds = resolvedRest;
        _currentSet = 1; // prepare for first working set
      });

      await _saveSessionState();
    } else {
      // Continue calibrating with rep-curve next weight
      final exerciseId = _currentPrescription?.exercise.id ?? '';
      final res = _computeNextCalibrationNext(
        currentWeight: _currentCalibrationWeight,
        reps: actualReps,
        exerciseId: exerciseId,
        attempt: _calibrationAttempt,
      );
      // Persist attempt for crash-proof resume
      await CalibrationResumeStore.saveAttempt(
        exerciseId: exerciseId,
        attemptIdx: _calibrationAttempt,
        signedLoadKg: _currentCalibrationWeight,
        effectiveLoadKg: _currentCalibrationWeight,
        reps: actualReps,
        est1RmKg: res.est1rm,
        nextSignedKg: res.next,
      );
      // Feedback
      if (mounted) {
        final msg = 'RECORDED: $actualReps · ${res.note}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: HeavyweightTheme.primary,
            content: Text(msg,
                style: const TextStyle(color: HeavyweightTheme.onPrimary)),
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
      HWLog.event('protocol_calib_attempt', data: {
        'exercise': exerciseId,
        'attempt': _calibrationAttempt,
        'reps': actualReps,
        'current': _currentCalibrationWeight,
        'next': res.next,
        'jump_pct': res.pct,
        'resume_used': _resumedCalibration,
      });
      setState(() {
        _currentCalibrationWeight = res.next;
        _calibrationAttempt++;
        _isResting = true;
        // fixed for calibration per v1, with optional debug-short override
        final cfg = SystemConfig.instance;
        _restSeconds = (cfg.isLoaded && cfg.debugShortRestEnabled)
            ? cfg.debugShortRestSeconds
            : 180;
      });
      await _saveSessionState();
    }
  }

  _CalibrationEntry _selectBestCalibrationEntry(
      List<_CalibrationEntry> entries) {
    if (entries.isEmpty) return _CalibrationEntry(_currentCalibrationWeight, 5);
    // Oscillation guard: if last two weights bounce A<->B, pick closer to 5
    if (entries.length >= 3) {
      final a = entries[entries.length - 3].weight;
      final b = entries[entries.length - 2].weight;
      final c = entries[entries.length - 1].weight;
      if (a == c && b != a) {
        final e1 = entries[entries.length - 3];
        final e2 = entries[entries.length - 2];
        _oscillationTriggered = true;
        return ((e1.reps - 5).abs() <= (e2.reps - 5).abs()) ? e1 : e2;
      }
    }
    // choose overall closest to 5 reps
    entries.sort((x, y) => (x.reps - 5).abs().compareTo((y.reps - 5).abs()));
    return entries.first;
  }

  _NextCalibResult _computeNextCalibrationNext({
    required double currentWeight,
    required int reps,
    required String exerciseId,
    required int attempt,
  }) {
    // Clamp reps range for formulas stability
    final r = reps.clamp(0, 15);
    if (r == 5) {
      return _NextCalibResult(
        next: currentWeight,
        est1rm: currentWeight * (1 + 5 / 30.0),
        note: 'PERFECT - 5RM FOUND!',
        pct: 100,
      );
    }
    // Epley and Brzycki 1RM estimates
    final est1rmE = currentWeight * (1 + r / 30.0);
    final est1rmB = currentWeight * 36.0 / (37 - (r == 0 ? 1 : r));
    final est1RM = _median([est1rmE, est1rmB]);
    // Target 5-rep load by inverse
    final tgtE = est1RM / (1 + 5 / 30.0);
    final tgtB = est1RM * (37 - 5) / 36.0;
    double target = _median([tgtE, tgtB]);
    // Jump caps
    double jump = target / (currentWeight == 0 ? 1 : currentWeight);
    if (attempt <= 1 && reps >= 12) {
      jump = jump.clamp(1.0, 1.55);
    } else if (attempt <= 1 && reps <= 2) {
      jump = jump.clamp(0.45, 1.0);
    } else {
      jump = jump.clamp(0.75, 1.25);
    }
    double next = currentWeight * jump;
    // Bridge set if huge gap on first attempt
    if (attempt == 1 &&
        (target / (currentWeight == 0 ? 1 : currentWeight)) > 1.35) {
      next = math.sqrt(currentWeight * target);
    }
    // Rounding per exercise increment
    final inc = SystemConfig.instance.incrementForExerciseKg(exerciseId);
    final rounded = (next / inc).round() * inc;
    // Min clamp from config
    final minClamp = SystemConfig.instance.minClampForExerciseKg(exerciseId);
    final nextClamped = rounded < minClamp ? minClamp : rounded;
    final pct = (currentWeight > 0)
        ? ((nextClamped / currentWeight - 1.0) * 100.0)
        : 0.0;
    final note = (pct == 0)
        ? 'NO CHANGE'
        : (pct > 0
            ? 'ADJUSTING +${pct.toStringAsFixed(0)}%'
            : 'ADJUSTING ${pct.toStringAsFixed(0)}%');
    return _NextCalibResult(
        next: nextClamped, est1rm: est1RM, note: note, pct: pct.round());
  }

  double _median(List<double> xs) {
    xs.sort();
    final n = xs.length;
    if (n == 0) return 0;
    if (n % 2 == 1) return xs[n >> 1];
    return (xs[n ~/ 2 - 1] + xs[n ~/ 2]) / 2.0;
  }

  void _handleWorkoutReps(int actualReps) async {
    HWLog.event('protocol_handle_workout',
        data: {'reps': actualReps, 'weight': _currentWorkingWeight});
    // Create set data
    final setData = SetData(
      exerciseId: _currentPrescription?.exercise.id ?? 'unknown',
      weight: _currentWorkingWeight,
      actualReps: actualReps,
      timestamp: DateTime.now(),
      setNumber: _currentSet,
      restTaken: _restSeconds,
    );

    // Show save success immediately (optimistic UI)
    HapticFeedback.mediumImpact(); // Success feedback
    setState(() {
      _showSaveSuccess = true;
    });
    // Also show a brief toast
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: const Text(
            'SET LOGGED',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(milliseconds: 700),
        ),
      );
    }

    // Save to repository with offline handling
    _saveSetOfflineSafe(setData);

    _sessionSets.add(setData);

    // Hide success indicator after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showSaveSuccess = false;
        });
      }
    });

    // Calculate rest time based on performance - THE MANDATE requires proper rest
    final calculatedRest =
        _engine.calculateRestSeconds(actualReps, 180); // 180 seconds base rest
    final cfg = SystemConfig.instance;
    final restToUse = (cfg.isLoaded && cfg.debugShortRestEnabled)
        ? cfg.debugShortRestSeconds
        : calculatedRest;

    bool workoutComplete = false;
    setState(() {
      if (_currentSet < (_currentPrescription?.targetSets ?? 3)) {
        // More sets remaining for this exercise
        _currentSet++;
        _isResting = true;
        _restSeconds =
            restToUse; // Apply performance-based or debug-short rest between sets

        HWLog.event('protocol_start_rest', data: {
          'exercise': _currentPrescription?.exercise.name ?? 'unknown',
          'completedSet': _currentSet - 1,
          'nextSet': _currentSet,
          'restSeconds': restToUse,
          'lastReps': actualReps,
          'inMandate': actualReps >= 4 && actualReps <= 6,
          'isCalibration': false,
        });
      } else {
        // Move to next exercise
        if (widget.workout != null &&
            _currentExerciseIndex < widget.workout!.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;

          HWLog.event('protocol_exercise_transition', data: {
            'from': _currentExerciseIndex - 1,
            'to': _currentExerciseIndex,
            'fromExercise': widget
                .workout!.exercises[_currentExerciseIndex - 1].exercise.name,
            'toExercise':
                widget.workout!.exercises[_currentExerciseIndex].exercise.name,
            'completedSets': _sessionSets
                .where((s) =>
                    s.exerciseId ==
                        widget.workout!.exercises[_currentExerciseIndex - 1]
                            .exercise.id &&
                    s.setNumber > 0)
                .length,
          });

          // Check if next exercise needs calibration
          final nextPrescription =
              widget.workout!.exercises[_currentExerciseIndex];
          final nextId = nextPrescription.exercise.id;
          final alreadyCalibrated = _calibratedWeights.containsKey(nextId);
          _isCalibrating =
              !alreadyCalibrated && nextPrescription.needsCalibration;

          _currentCalibrationWeight =
              _calibratedWeights[nextId] ?? nextPrescription.prescribedWeight;

          if (_isCalibrating) {
            _calibrationAttempt = 1;
          }

          _isResting = true;
          _restSeconds = restToUse;
        } else {
          workoutComplete = true;
        }
      }
    });
    if (workoutComplete) {
      await _completeWorkout();
    } else {
      await _saveSessionState();
    }
  }

  void _onRestComplete() {
    HWLog.event('protocol_rest_complete');
    setState(() {
      _isResting = false;
      _showWeightAdjustment =
          false; // Hide adjustment UI when returning to workout
    });
    _saveSessionState();
  }

  void _showWeightAdjustmentDialog() {
    HWLog.event('protocol_show_adjust_weight');
    setState(() {
      _showWeightAdjustment = true;
    });
  }

  void _handleSwapExercise() {
    final prescription = _currentPrescription;
    if (prescription == null) return;
    ExerciseAlternativesBottomSheet.show(
      context,
      exerciseId: prescription.exercise.id,
      currentExerciseName: prescription.exercise.name,
    );
  }

  void _adjustWeight(double newWeight, String reason) {
    HWLog.event('protocol_adjust_weight',
        data: {'weight': newWeight, 'reason': reason});
    final exerciseId = _currentPrescription?.exercise.id;
    if (exerciseId != null) {
      setState(() {
        _adjustedWeights[exerciseId] = newWeight;
        _lastAdjustmentReason = reason;
        _showWeightAdjustment = false;
      });
    }
  }

  void _resetWeight() {
    HWLog.event('protocol_reset_weight');
    final exerciseId = _currentPrescription?.exercise.id;
    if (exerciseId != null) {
      setState(() {
        _adjustedWeights.remove(exerciseId);
        _lastAdjustmentReason = null;
        _showWeightAdjustment = false;
      });
    }
  }

  /// Get last set performance for smart rest timer decisions
  String? _getLastSetPerformance() {
    if (_sessionSets.isEmpty) return null;

    final lastSet = _sessionSets.last;
    if (lastSet.metMandate) {
      return 'within_mandate';
    } else if (lastSet.isFailure) {
      return 'below_mandate';
    } else if (lastSet.exceededMandate) {
      return 'above_mandate';
    }

    return null;
  }

  /// Get previous set reps for the current exercise to show progression
  List<int>? _getPreviousSetRepsForCurrentExercise() {
    final currentExerciseId = _currentPrescription?.exercise.id;
    if (currentExerciseId == null) return null;

    // Get all sets for current exercise
    final exerciseSets = _sessionSets
        .where((set) => set.exerciseId == currentExerciseId)
        .toList();

    if (exerciseSets.isEmpty) return null;

    // Return the reps from all previous sets
    return exerciseSets.map((set) => set.actualReps).toList();
  }

  Future<void> _completeWorkout() async {
    HWLog.event('protocol_complete_workout',
        data: {'setCount': _sessionSets.length});
    // End the workout session in Supabase (offline-safe)
    await _endWorkoutSessionOfflineSafe();

    // Calculate mandate satisfaction (4-6 reps is the mandate)
    final mandateSatisfied = _calculateMandateSatisfaction();

    // Clear active session since workout is completing
    await WorkoutSessionManager.clearActiveSession();

    if (!mounted) return;
    // Navigate to session completion screen with data
    context.push('/session-complete', extra: {
      'sessionSets': _sessionSets,
      'mandateSatisfied': mandateSatisfied,
    });
  }

  /// Calculate if the mandate (4-6 reps) was satisfied for most sets
  bool _calculateMandateSatisfaction() {
    if (_sessionSets.isEmpty) return false;

    int mandateSets = 0;
    for (final set in _sessionSets) {
      if (set.actualReps >= 4 && set.actualReps <= 6) {
        mandateSets++;
      }
    }

    // Mandate satisfied if more than 70% of sets were in the 4-6 range
    return (mandateSets / _sessionSets.length) >= 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit && context.mounted) {
          GoRouter.of(context).go('/app?tab=0');
        }
      },
      child: _buildProtocolContent(context),
    );
  }

  Widget _buildProtocolContent(BuildContext context) {
    if (_isResting) {
      final cfg = SystemConfig.instance;
      final shortOn = cfg.isLoaded && cfg.debugShortRestEnabled;
      return HeavyweightScaffold(
        title: 'RESTING',
        body: Stack(
          children: [
            RestTimer(
              restSeconds: _restSeconds,
              onComplete: _onRestComplete,
              canSkip: false,
              canExtend: true,
              lastSetPerformance: _getLastSetPerformance(),
            ),
            if (shortOn)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.red.withValues(alpha: 0.18),
                  child: Text(
                    'DEV · SHORT REST (${cfg.debugShortRestSeconds}s)',
                    style:
                        const TextStyle(fontSize: 10, color: Colors.redAccent),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final profile = context.watch<ProfileProvider>();
    final unit = profile.unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
    final exerciseViewModel = context.watch<ExerciseViewModel>();
    final prescription = _currentPrescription;
    final hasAlternatives = prescription != null &&
        exerciseViewModel.isLoaded &&
        exerciseViewModel.hasAlternatives(prescription.exercise.id);
    final exerciseName =
        prescription?.exercise.name.toUpperCase() ?? 'UNKNOWN EXERCISE';
    final weightValue =
        _isCalibrating ? _currentCalibrationWeight : _currentWorkingWeight;
    final weightDisplay = formatWeightForUnit(weightValue, unit);
    final unitLabel = unit == HWUnit.kg ? 'KG' : 'LB';
    final progressWidget = _buildExerciseProgress();

    return Stack(
      children: [
        HeavyweightScaffold(
          title: 'TRAINING',
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header back button is provided by HeavyweightScaffold; avoid extra back button here
                Padding(
                  padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TrainingHeader(
                        exerciseName: exerciseName,
                        isCalibrating: _isCalibrating,
                        showCalibrationBadge: _isCalibrating,
                        showSwapButton: hasAlternatives,
                        onSwap: hasAlternatives ? _handleSwapExercise : null,
                        progress: progressWidget,
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingXl),
                      _TrainingWeightCard(
                        isCalibrating: _isCalibrating,
                        displayWeight: weightDisplay,
                        unitLabel: unitLabel,
                        calibrationAttempt: _calibrationAttempt,
                        hasAdjustment: _hasWeightAdjustment,
                        adjustmentReason: _lastAdjustmentReason,
                        onAdjust:
                            _isCalibrating ? null : _showWeightAdjustmentDialog,
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingXl),
                      GuidanceCard(isCalibrating: _isCalibrating),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HeavyweightTheme.spacingMd),
                  child: _buildRepLoggerSection(),
                ),
                const SizedBox(height: HeavyweightTheme.spacingXl),
              ],
            ),
          ),
        ),
        if (_showWeightAdjustment) _buildWeightAdjustmentOverlay(),
      ],
    );
  }

  Widget _buildWeightAdjustmentOverlay() {
    final currentWeight = _currentWorkingWeight;
    final prescribedWeight = _currentPrescription?.prescribedWeight ?? 0.0;
    final profile = context.read<ProfileProvider>();
    final unit = profile.unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
    final unitLabel = unit == HWUnit.kg ? 'KG' : 'LB';

    return Container(
      color: HeavyweightTheme.background.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(HeavyweightTheme.spacingMd),
            padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
            decoration: BoxDecoration(
              border: Border.all(color: HeavyweightTheme.primary, width: 2),
              color: HeavyweightTheme.background,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WEIGHT_ADJUSTMENT',
                  style: HeavyweightTheme.h4,
                ),

                const SizedBox(height: HeavyweightTheme.spacingMd),

                Text(
                  'CURRENT: ${currentWeight.toStringAsFixed(1)} $unitLabel',
                  style: TextStyle(
                    color: HeavyweightTheme.textSecondary,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),

                if (currentWeight != prescribedWeight) ...[
                  Text(
                    'PRESCRIBED: ${prescribedWeight.toStringAsFixed(1)} $unitLabel',
                    style: HeavyweightTheme.labelSmall.copyWith(
                      color: HeavyweightTheme.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: HeavyweightTheme.spacingXl),

                // Quick adjustment buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAdjustButton(
                      "TOO_HEAVY\\n-${unit == HWUnit.kg ? '2.5' : '5'}$unitLabel",
                      currentWeight - (unit == HWUnit.kg ? 2.5 : 5.0),
                      'Too Heavy',
                      HeavyweightTheme.error,
                    ),
                    _buildQuickAdjustButton(
                      "TOO_LIGHT\\n+${unit == HWUnit.kg ? '2.5' : '5'}$unitLabel",
                      currentWeight + (unit == HWUnit.kg ? 2.5 : 5.0),
                      'Too Light',
                      Colors.blue.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: HeavyweightTheme.spacingMd),

                // Reset to prescribed button
                if (_hasWeightAdjustment) ...[
                  OutlinedButton(
                    onPressed: _resetWeight,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HeavyweightTheme.textSecondary,
                      side: BorderSide(color: HeavyweightTheme.secondary),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'RESET_TO_PRESCRIBED',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingSm),
                ],

                // Cancel button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showWeightAdjustment = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HeavyweightTheme.primary,
                    side: const BorderSide(color: HeavyweightTheme.primary),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAdjustButton(
    String label,
    double newWeight,
    String reason,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingXs),
        child: ElevatedButton(
          onPressed:
              newWeight > 0 ? () => _adjustWeight(newWeight, reason) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: HeavyweightTheme.onPrimary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(
                vertical: HeavyweightTheme.spacingMd),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class GuidanceCard extends StatelessWidget {
  final bool isCalibrating;

  const GuidanceCard({super.key, required this.isCalibrating});

  @override
  Widget build(BuildContext context) {
    final headline = isCalibrating
        ? 'CALIBRATION SET — PUSH TO LIMIT'
        : 'WORKING SET — LOG HONEST REPS';
    final body = isCalibrating
        ? 'Go to technical failure with the assigned load. Capture the exact reps achieved.'
        : 'Execute the prescribed reps with control. Log the real number completed — zero inflation.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        color: HeavyweightTheme.surface,
        border: Border.all(
          color: (isCalibrating
                  ? HeavyweightTheme.warning
                  : HeavyweightTheme.secondary)
              .withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: HeavyweightTheme.labelMedium.copyWith(
              color: isCalibrating
                  ? HeavyweightTheme.warning
                  : HeavyweightTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          Text(
            body,
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingHeader extends StatelessWidget {
  final String exerciseName;
  final bool isCalibrating;
  final bool showCalibrationBadge;
  final bool showSwapButton;
  final VoidCallback? onSwap;
  final Widget progress;

  const _TrainingHeader({
    required this.exerciseName,
    required this.isCalibrating,
    required this.showCalibrationBadge,
    required this.showSwapButton,
    required this.onSwap,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                exerciseName,
                style: HeavyweightTheme.h1.copyWith(
                  fontSize: 28,
                  letterSpacing: 3,
                ),
              ),
            ),
            if (showCalibrationBadge)
              const Padding(
                padding: EdgeInsets.only(left: HeavyweightTheme.spacingSm),
                child: HWBadge('CALIBRATION REQUIRED',
                    variant: HWBadgeVariant.danger),
              ),
            if (showSwapButton)
              IconButton(
                onPressed: onSwap,
                icon:
                    const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
                tooltip: 'Exercise Options',
              ),
          ],
        ),
        const SizedBox(height: HeavyweightTheme.spacingSm),
        progress,
      ],
    );
  }
}

class _TrainingWeightCard extends StatelessWidget {
  final bool isCalibrating;
  final String displayWeight;
  final String unitLabel;
  final int calibrationAttempt;
  final bool hasAdjustment;
  final String? adjustmentReason;
  final VoidCallback? onAdjust;

  const _TrainingWeightCard({
    required this.isCalibrating,
    required this.displayWeight,
    required this.unitLabel,
    required this.calibrationAttempt,
    required this.hasAdjustment,
    required this.adjustmentReason,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        color: HeavyweightTheme.surface,
        border: Border.all(
          color: (isCalibrating
                  ? HeavyweightTheme.warning
                  : HeavyweightTheme.secondary)
              .withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCalibrating
                ? 'CALIBRATION ATTEMPT $calibrationAttempt'
                : 'PRESCRIBED WEIGHT',
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              '$displayWeight $unitLabel',
              key: ValueKey('$displayWeight$unitLabel'),
              style: HeavyweightTheme.h2.copyWith(
                fontSize: 36,
                letterSpacing: 2,
                color: isCalibrating
                    ? HeavyweightTheme.warning
                    : hasAdjustment
                        ? Colors.orangeAccent
                        : HeavyweightTheme.primary,
              ),
            ),
          ),
          if (hasAdjustment && adjustmentReason != null) ...[
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Text(
              'ADJUSTED: ${adjustmentReason!.toUpperCase()}',
              style: HeavyweightTheme.bodySmall.copyWith(
                color: Colors.orange.shade300,
                letterSpacing: 1.2,
              ),
            ),
          ],
          if (!isCalibrating && onAdjust != null) ...[
            const SizedBox(height: HeavyweightTheme.spacingMd),
            OutlinedButton.icon(
              onPressed: onAdjust,
              style: OutlinedButton.styleFrom(
                foregroundColor: hasAdjustment
                    ? HeavyweightTheme.warning
                    : HeavyweightTheme.textSecondary,
                side: BorderSide(
                  color: hasAdjustment
                      ? HeavyweightTheme.warning
                      : HeavyweightTheme.secondary,
                  width: 1,
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              icon: Icon(hasAdjustment ? Icons.tune : Icons.scale, size: 16),
              label: const Text(
                'ADJUST WEIGHT',
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalibrationEntry {
  final double weight;
  final int reps;
  _CalibrationEntry(this.weight, this.reps);
}

class _NextCalibResult {
  final double next;
  final double est1rm;
  final String note;
  final int pct;
  _NextCalibResult(
      {required this.next,
      required this.est1rm,
      required this.note,
      required this.pct});
}
