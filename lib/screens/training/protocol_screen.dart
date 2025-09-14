import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../fortress/calibration/calibration_resume_store.dart';

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
  static const int _maxCalibrationAttempts = 5; // Prevent infinite calibration
  Map<String, double> _calibratedWeights = {};
  
  // Weight adjustment system
  Map<String, double> _adjustedWeights = {};
  bool _showWeightAdjustment = false;
  String? _lastAdjustmentReason;
  
  List<SetData> _sessionSets = [];
  bool _showSaveSuccess = false;
  
  @override
  void initState() {
    super.initState();
    HWLog.screen('Training/Protocol');
    _initializeRepository();
    _engine = WorkoutEngine();
    
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: HeavyweightTheme.error,
              content: Text(
                'No workout mandate available',
                style: TextStyle(color: HeavyweightTheme.primary),
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _tryResumeCalibration() async {
    final rec = await CalibrationResumeStore.loadPending();
    if (rec == null) return;
    final idx = widget.workout!.exercises.indexWhere((e) => e.exercise.id == rec.exerciseId);
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
  
  PlannedExercise? get _currentPrescription {
    if (widget.workout?.exercises.isEmpty != false) return null;
    return widget.workout!.exercises[_currentExerciseIndex];
  }
  
  /// Get current working weight (adjusted or prescribed)
  double get _currentWorkingWeight {
    final exerciseId = _currentPrescription?.exercise.id;
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
    HWLog.event('protocol_handle_calibration', data: {'reps': actualReps, 'weight': _currentCalibrationWeight});
    // Record attempt
    _calibrationEntries.add(_CalibrationEntry(_currentCalibrationWeight, actualReps));
    // Determine lock conditions
    final inMandate = actualReps >= 4 && actualReps <= 6;
    final reachedMax = _calibrationAttempt >= 3;
    if (inMandate || reachedMax) {
      // Choose best (closest to 5) if not in range
      final best = _selectBestCalibrationEntry(_calibrationEntries);
      _currentCalibrationWeight = best.weight;
      // Found the 5RM!
      if (_currentPrescription != null) {
        _calibratedWeights[_currentPrescription!.exercise.id] = _currentCalibrationWeight;
      }
      
      // If this is bench press on Day 1, estimate all other weights
      if (_currentPrescription?.exercise.id == 'bench') {
        final estimatedWeights = _engine.estimateWeightsFromBenchPress(_currentCalibrationWeight);
        _calibratedWeights.addAll(estimatedWeights);
      }
      
      // Save the calibration as a set
      final setData = SetData(
        exerciseId: _currentPrescription?.exercise.id ?? 'unknown',
        weight: _currentCalibrationWeight,
        actualReps: actualReps,
        timestamp: DateTime.now(),
        setNumber: 1,
        restTaken: 0,
      );
      await _repository.saveSet(setData);
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
        final unit = context.read<ProfileProvider>().unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
        final disp = formatWeightForUnit(_currentCalibrationWeight, unit);
        final msg = 'WORKING WEIGHT LOCKED: $disp ${unit == HWUnit.kg ? 'KG' : 'LB'}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text(msg, style: const TextStyle(color: Colors.white)),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      }
      
      // Move to next exercise
      setState(() {
        if (widget.workout != null && _currentExerciseIndex < widget.workout!.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          _calibrationAttempt = 1;
          _calibrationEntries.clear();
          
          // Check if next exercise needs calibration
          final nextPrescription = widget.workout!.exercises[_currentExerciseIndex];
          _isCalibrating = nextPrescription.needsCalibration;
          
          if (_isCalibrating) {
            // Use estimated weight if available
            _currentCalibrationWeight = _calibratedWeights[nextPrescription.exercise.id] 
                ?? nextPrescription.prescribedWeight;
          }
          
          _isResting = true;
          _restSeconds = 180;
        } else {
          _completeWorkout();
        }
      });
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
            content: Text(msg, style: const TextStyle(color: HeavyweightTheme.onPrimary)),
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
    }
  }

  _CalibrationEntry _selectBestCalibrationEntry(List<_CalibrationEntry> entries) {
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
        return ( (e1.reps - 5).abs() <= (e2.reps - 5).abs() ) ? e1 : e2;
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
    if (r == 5) return _NextCalibResult(next: currentWeight, est1rm: currentWeight * (1 + 5 / 30.0), note: 'PERFECT - 5RM FOUND!', pct: 100);
    // Epley and Brzycki 1RM estimates
    final est1RM_e = currentWeight * (1 + r / 30.0);
    final est1RM_b = currentWeight * 36.0 / (37 - (r == 0 ? 1 : r));
    final est1RM = _median([est1RM_e, est1RM_b]);
    // Target 5-rep load by inverse
    final tgt_e = est1RM / (1 + 5 / 30.0);
    final tgt_b = est1RM * (37 - 5) / 36.0;
    double target = _median([tgt_e, tgt_b]);
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
    if (attempt == 1 && (target / (currentWeight == 0 ? 1 : currentWeight)) > 1.35) {
      next = math.sqrt(currentWeight * target);
    }
    // Rounding per exercise increment
    final inc = SystemConfig.instance.incrementForExerciseKg(exerciseId);
    final rounded = (next / inc).round() * inc;
    // Min clamp from config
    final minClamp = SystemConfig.instance.minClampForExerciseKg(exerciseId);
    final nextClamped = rounded < minClamp ? minClamp : rounded;
    final pct = (currentWeight > 0) ? ((nextClamped / currentWeight - 1.0) * 100.0) : 0.0;
    final note = (pct == 0) ? 'NO CHANGE' : (pct > 0 ? 'ADJUSTING +${pct.toStringAsFixed(0)}%' : 'ADJUSTING ${pct.toStringAsFixed(0)}%');
    return _NextCalibResult(next: nextClamped, est1rm: est1RM, note: note, pct: pct.round());
  }

  double _median(List<double> xs) {
    xs.sort();
    final n = xs.length;
    if (n == 0) return 0;
    if (n % 2 == 1) return xs[n >> 1];
    return (xs[n ~/ 2 - 1] + xs[n ~/ 2]) / 2.0;
  }
  
  void _handleWorkoutReps(int actualReps) async {
    HWLog.event('protocol_handle_workout', data: {'reps': actualReps, 'weight': _currentWorkingWeight});
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
    
    // Save to repository (fire and forget)
    _repository.saveSet(setData).then((_) {
      HWLog.event('protocol_save_set', data: {'exercise': setData.exerciseId, 'reps': actualReps, 'weight': setData.weight});
      // Success - the optimistic UI was correct
    }).catchError((error) {
      // Handle error silently, could add to retry queue
      HWLog.event('protocol_save_set_error', data: {'error': error.toString()});
    });
    
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
    final calculatedRest = _engine.calculateRestSeconds(actualReps, 180); // 180 seconds base rest
    final cfg = SystemConfig.instance;
    final restToUse = (cfg.isLoaded && cfg.debugShortRestEnabled)
        ? cfg.debugShortRestSeconds
        : calculatedRest;
    
    setState(() {
      if (_currentSet < (_currentPrescription?.targetSets ?? 3)) {
        // More sets remaining for this exercise
        _currentSet++;
        _isResting = true;
        _restSeconds = restToUse; // Apply performance-based or debug-short rest between sets
      } else {
        // Move to next exercise
        if (widget.workout != null && _currentExerciseIndex < widget.workout!.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          
          // Check if next exercise needs calibration
          final nextPrescription = widget.workout!.exercises[_currentExerciseIndex];
          _isCalibrating = nextPrescription.needsCalibration;
          
          if (_isCalibrating) {
            _currentCalibrationWeight = _calibratedWeights[nextPrescription.exercise.id] 
                ?? nextPrescription.prescribedWeight;
            _calibrationAttempt = 1;
          }
          
          _isResting = true;
        _restSeconds = restToUse;
        } else {
          // Workout complete
          _completeWorkout();
        }
      }
    });
  }
  
  void _onRestComplete() {
    HWLog.event('protocol_rest_complete');
    setState(() {
      _isResting = false;
      _showWeightAdjustment = false; // Hide adjustment UI when returning to workout
    });
  }
  
  void _showWeightAdjustmentDialog() {
    HWLog.event('protocol_show_adjust_weight');
    setState(() {
      _showWeightAdjustment = true;
    });
  }
  
  void _adjustWeight(double newWeight, String reason) {
    HWLog.event('protocol_adjust_weight', data: {'weight': newWeight, 'reason': reason});
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
  
  void _completeWorkout() {
    HWLog.event('protocol_complete_workout', data: {'setCount': _sessionSets.length});
    // End the workout session in Supabase
    _repository.endWorkoutSession();
    
    // Calculate mandate satisfaction (4-6 reps is the mandate)
    bool mandateSatisfied = _calculateMandateSatisfaction();
    
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.red.withOpacity(0.18),
                  child: Text(
                    'DEV · SHORT REST (${cfg.debugShortRestSeconds}s)',
                    style: const TextStyle(fontSize: 10, color: Colors.redAccent),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        HeavyweightScaffold(
          title: 'PROTOCOL',
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header back button is provided by HeavyweightScaffold; avoid extra back button here
                Padding(
                  padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _currentPrescription?.exercise.name.toUpperCase() ?? 'UNKNOWN EXERCISE',
                              style: HeavyweightTheme.h1,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Consumer<ExerciseViewModel>(
                            builder: (context, exerciseViewModel, child) {
                              if (!exerciseViewModel.isLoaded || _currentPrescription == null) {
                                return const SizedBox();
                              }
                              
                              final hasAlternatives = exerciseViewModel.hasAlternatives(_currentPrescription!.exercise.id);
                              if (!hasAlternatives) {
                                return const SizedBox();
                              }
                              
                              return IconButton(
                                onPressed: () {
                                  ExerciseAlternativesBottomSheet.show(
                                    context,
                                    exerciseId: _currentPrescription!.exercise.id,
                                    currentExerciseName: _currentPrescription!.exercise.name,
                                  );
                                },
                                icon: const Icon(
                                  Icons.swap_horiz,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                tooltip: 'Exercise Options',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingMd),
                      Text(
                        _isCalibrating
                            ? 'CALIBRATION IN PROGRESS'
                            : 'SET $_currentSet OF ${_currentPrescription?.targetSets ?? 3}',
                        style: TextStyle(
                          color: _isCalibrating ? HeavyweightTheme.warning : HeavyweightTheme.textSecondary,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingLg),
                      Container(
                        padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isCalibrating ? HeavyweightTheme.warning : HeavyweightTheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isCalibrating ? 'CALIBRATION ATTEMPT $_calibrationAttempt' : 'PRESCRIBED WEIGHT',
                              style: TextStyle(
                                color: HeavyweightTheme.textSecondary,
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingSm),
                            Text(
                              () {
                                final unit = context.read<ProfileProvider>().unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
                                final valueKg = _isCalibrating ? _currentCalibrationWeight : _currentWorkingWeight;
                                final disp = formatWeightForUnit(valueKg, unit);
                                final suffix = unit == HWUnit.kg ? 'KG' : 'LB';
                                return '$disp $suffix';
                              }(),
                              style: GoogleFonts.ibmPlexMono(
                                color: _isCalibrating
                                    ? HeavyweightTheme.warning
                                    : _hasWeightAdjustment
                                        ? HeavyweightTheme.warning
                                        : HeavyweightTheme.primary,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_hasWeightAdjustment && !_isCalibrating) ...[
                              const SizedBox(height: HeavyweightTheme.spacingSm),
                              Text(
                                'ADJUSTED: ${_lastAdjustmentReason ?? 'Manual'}',
                                style: TextStyle(
                                  color: Colors.orange.shade300,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!_isCalibrating) ...[
                        const SizedBox(height: HeavyweightTheme.spacingMd),
                        OutlinedButton.icon(
                          onPressed: _showWeightAdjustmentDialog,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                _hasWeightAdjustment ? HeavyweightTheme.warning : HeavyweightTheme.textSecondary,
                            side: BorderSide(
                              color: _hasWeightAdjustment ? HeavyweightTheme.warning : HeavyweightTheme.secondary,
                              width: 1,
                            ),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          icon: Icon(_hasWeightAdjustment ? Icons.tune : Icons.scale, size: 16),
                          label: const Text(
                            'ADJUST WEIGHT',
                            style: TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      const SizedBox(height: HeavyweightTheme.spacingLg),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingMd, vertical: HeavyweightTheme.spacingSm),
                        decoration: BoxDecoration(
                          border: Border.all(color: _isCalibrating ? HeavyweightTheme.warning : HeavyweightTheme.secondary),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isCalibrating ? 'LIFT TO FAILURE - LOG REPS ACHIEVED' : 'PERFORM SET - LOG HONEST REPS',
                              style: TextStyle(
                                color: _isCalibrating ? HeavyweightTheme.warning : HeavyweightTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_isCalibrating) ...[
                              const SizedBox(height: HeavyweightTheme.spacingSm),
                              Text(
                                'Perform as many reps as possible with this weight',
                                style: TextStyle(color: HeavyweightTheme.textSecondary, fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingMd),
                  child: RepLogger(
                    onRepsLogged: _onRepsLogged,
                    initialValue: 5,
                    currentSet: _currentSet,
                    previousSetReps: _getPreviousSetRepsForCurrentExercise(),
                    liveMode: true,
                  ),
                ),
                if (_showSaveSuccess)
                  Padding(
                    padding: const EdgeInsets.all(HeavyweightTheme.spacingSm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: HeavyweightTheme.spacingSm),
                        Text(
                          'SET LOGGED',
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: HeavyweightTheme.spacingMd),
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
                  'CURRENT: ${currentWeight.toStringAsFixed(1)} KG',
                  style: TextStyle(
                    color: HeavyweightTheme.textSecondary,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                
                if (currentWeight != prescribedWeight) ...[
                  Text(
                    'PRESCRIBED: ${prescribedWeight.toStringAsFixed(1)} KG',
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
                      'TOO_HEAVY\n-2.5KG',
                      currentWeight - 2.5,
                      'Too Heavy',
                      HeavyweightTheme.error,
                    ),
                    _buildQuickAdjustButton(
                      'TOO_LIGHT\n+2.5KG',
                      currentWeight + 2.5,
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
        margin: const EdgeInsets.symmetric(horizontal: HeavyweightTheme.spacingXs),
        child: ElevatedButton(
          onPressed: newWeight > 0 ? () => _adjustWeight(newWeight, reason) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: HeavyweightTheme.onPrimary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(vertical: HeavyweightTheme.spacingMd),
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
  _NextCalibResult({required this.next, required this.est1rm, required this.note, required this.pct});
}
