import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../fortress/protocol/widgets/rest_timer.dart';
import '../../fortress/protocol/widgets/rep_logger.dart';
import '../../fortress/engine/workout_engine.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../backend/supabase/supabase_workout_repository.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../core/logging.dart';

/// The Protocol Screen - The heart of the workout experience
/// Minimalist, brutal, effective
class ProtocolScreen extends StatefulWidget {
  final DailyWorkout? workout;
  
  const ProtocolScreen({
    Key? key,
    this.workout,
  }) : super(key: key);
  
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
    // Calculate next calibration weight
    final nextWeight = _engine.calculateCalibrationWeight(
      _currentCalibrationWeight,
      actualReps,
    );
    // Success toast for calibration attempt
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: HeavyweightTheme.primary,
          content: Text(
            'CALIBRATION SET LOGGED',
            style: TextStyle(color: HeavyweightTheme.onPrimary),
          ),
          duration: Duration(milliseconds: 800),
        ),
      );
    }
    
    if (actualReps == 5) {
      // Found the 5RM!
      if (_currentPrescription != null) {
        _calibratedWeights[_currentPrescription!.exercise.id] = _currentCalibrationWeight;
      }
      
      // If this is bench press on Day 1, estimate all other weights
      if (widget.workout?.isDay1 == true && _currentPrescription?.exercise.id == 'bench') {
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
      HWLog.event('protocol_save_set', data: {'exercise': setData.exerciseId, 'reps': actualReps, 'weight': setData.weight});
      _sessionSets.add(setData);
      
      // Move to next exercise
      setState(() {
        if (widget.workout != null && _currentExerciseIndex < widget.workout!.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          _calibrationAttempt = 1;
          
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
      // Continue calibrating
      setState(() {
        _currentCalibrationWeight = nextWeight;
        _calibrationAttempt++;
        _isResting = true;
        _restSeconds = 180; // 3 minutes - THE MANDATE
      });
    }
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
    
    // Calculate rest time based on performance (using 5 seconds for testing)
    // TODO: Batch setState calls for better performance
    final calculatedRest = 5; // Simplified to 5 seconds for testing
    
    setState(() {
      if (_currentSet < (_currentPrescription?.targetSets ?? 3)) {
        // More sets remaining for this exercise
        _currentSet++;
        _isResting = true;
        _restSeconds = 180; // 3 minutes - THE MANDATE
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
          _restSeconds = calculatedRest;
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
    HWLog.event('protocol_build');
    if (_isResting) {
      return HeavyweightScaffold(
        title: 'RESTING',
        body: RestTimer(
          restSeconds: _restSeconds,
          onComplete: _onRestComplete,
          canSkip: false,
          canExtend: true,
          lastSetPerformance: _getLastSetPerformance(),
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
                      Text(
                        _currentPrescription?.exercise.name.toUpperCase() ?? 'UNKNOWN EXERCISE',
                        style: HeavyweightTheme.h1,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                              _isCalibrating ? '${_currentCalibrationWeight} KG' : '${_currentWorkingWeight} KG',
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
