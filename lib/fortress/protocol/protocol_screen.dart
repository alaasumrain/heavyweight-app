import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/rest_timer.dart';
import 'widgets/rep_logger.dart';
import '../engine/workout_engine.dart';
import '../engine/models/set_data.dart';
import '../../backend/supabase/supabase_workout_repository.dart';

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
  int _restSeconds = 5; // 5 seconds rest for testing
  
  // Calibration mode tracking
  bool _isCalibrating = false;
  double _currentCalibrationWeight = 20.0;
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
              content: Text('No workout mandate available'),
              backgroundColor: Colors.red,
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
    if (_isCalibrating) {
      // Calibration mode: finding the 5RM
      _handleCalibrationReps(actualReps);
    } else {
      // Normal workout mode
      _handleWorkoutReps(actualReps);
    }
  }
  
  void _handleCalibrationReps(int actualReps) async {
    // Calculate next calibration weight
    final nextWeight = _engine.calculateCalibrationWeight(
      _currentCalibrationWeight,
      actualReps,
    );
    
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
        _restSeconds = 5; // 5 seconds rest for testing calibration
      });
    }
  }
  
  void _handleWorkoutReps(int actualReps) async {
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
    setState(() {
      _showSaveSuccess = true;
    });
    
    // Save to repository (fire and forget)
    _repository.saveSet(setData).then((_) {
      // Success - the optimistic UI was correct
    }).catchError((error) {
      // Handle error silently, could add to retry queue
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
    final calculatedRest = 5; // Simplified to 5 seconds for testing
    
    setState(() {
      if (_currentSet < (_currentPrescription?.targetSets ?? 3)) {
        // More sets remaining for this exercise
        _currentSet++;
        _isResting = true;
        _restSeconds = 5; // Always 5 seconds for testing
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
    setState(() {
      _isResting = false;
      _showWeightAdjustment = false; // Hide adjustment UI when returning to workout
    });
  }
  
  void _showWeightAdjustmentDialog() {
    setState(() {
      _showWeightAdjustment = true;
    });
  }
  
  void _adjustWeight(double newWeight, String reason) {
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
  
  /// Calculate workout progress safely
  double _calculateProgress() {
    final workout = widget.workout;
    if (workout == null || workout.exercises.isEmpty) {
      return 0.0;
    }
    
    final totalExercises = workout.exercises.length;
    final setsPerExercise = 3; // Assuming 3 sets per exercise
    final totalSets = totalExercises * setsPerExercise;
    final completedSets = _currentExerciseIndex * setsPerExercise + _currentSet - 1;
    
    return (completedSets / totalSets).clamp(0.0, 1.0);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isResting) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'RESTING',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
        ),
        body: SafeArea(
          child: RestTimer(
            restSeconds: _restSeconds,
            onComplete: _onRestComplete,
            canSkip: true, // Smart skip based on performance
            canExtend: true, // Allow extending when needed
            lastSetPerformance: _getLastSetPerformance(),
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'PROTOCOL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  child: LinearProgressIndicator(
                    value: _calculateProgress(),
                    backgroundColor: Colors.grey.shade900,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                
                // Exercise info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Exercise name
                    Text(
                      _currentPrescription?.exercise.name.toUpperCase() ?? 'UNKNOWN EXERCISE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Set or calibration indicator
                    Text(
                      _isCalibrating
                        ? 'CALIBRATION IN PROGRESS'
                        : 'SET $_currentSet OF ${_currentPrescription?.targetSets ?? 3}',
                      style: TextStyle(
                        color: _isCalibrating ? Colors.amber : Colors.grey.shade400,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Weight display (calibration or prescribed)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isCalibrating ? Colors.amber : Colors.white, 
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _isCalibrating 
                              ? 'CALIBRATION ATTEMPT $_calibrationAttempt'
                              : 'PRESCRIBED WEIGHT',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isCalibrating
                              ? '${_currentCalibrationWeight} KG'
                              : '${_currentWorkingWeight} KG',
                            style: TextStyle(
                              color: _isCalibrating 
                                  ? Colors.amber 
                                  : _hasWeightAdjustment 
                                      ? Colors.orange 
                                      : Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          
                          // Weight adjustment indicator
                          if (_hasWeightAdjustment && !_isCalibrating) ...[
                            const SizedBox(height: 8),
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
                    
                    // Weight Adjustment Button (only for normal workout mode)
                    if (!_isCalibrating) ...[
                      const SizedBox(height: 20),
                      
                      OutlinedButton.icon(
                        onPressed: _showWeightAdjustmentDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _hasWeightAdjustment ? Colors.orange : Colors.grey.shade400,
                          side: BorderSide(
                            color: _hasWeightAdjustment ? Colors.orange : Colors.grey.shade600,
                            width: 1,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        icon: Icon(
                          _hasWeightAdjustment ? Icons.tune : Icons.scale,
                          size: 16,
                        ),
                        label: Text(
                          _hasWeightAdjustment ? 'WEIGHT_ADJUSTED' : 'ADJUST_WEIGHT',
                          style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // The Mandate or Calibration Goal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: _isCalibrating ? Colors.amber.shade800 : Colors.grey.shade800),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _isCalibrating 
                              ? 'TARGET: 5 REPS AT MAX EFFORT'
                              : 'THE MANDATE: 4-6 REPS',
                            style: TextStyle(
                              color: _isCalibrating ? Colors.amber : Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          if (_isCalibrating) ...[                            
                            const SizedBox(height: 10),
                            Text(
                              'Find the weight where 5 reps is your absolute limit',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
                
                // Rep logger
                RepLogger(
                  onRepsLogged: _onRepsLogged,
                  initialValue: 5,
                  currentSet: _currentSet,
                  previousSetReps: _getPreviousSetRepsForCurrentExercise(),
                  liveMode: true,
                ),
                
                // Save success indicator
                if (_showSaveSuccess)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SET LOGGED',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Weight Adjustment Overlay
        if (_showWeightAdjustment)
          _buildWeightAdjustmentOverlay(),
      ],
    );
  }
  
  Widget _buildWeightAdjustmentOverlay() {
    final currentWeight = _currentWorkingWeight;
    final prescribedWeight = _currentPrescription?.prescribedWeight ?? 0.0;
    
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WEIGHT_ADJUSTMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'CURRENT: ${currentWeight.toStringAsFixed(1)} KG',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                
                if (currentWeight != prescribedWeight) ...[
                  Text(
                    'PRESCRIBED: ${prescribedWeight.toStringAsFixed(1)} KG',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Quick adjustment buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAdjustButton(
                      'TOO_HEAVY\n-2.5KG',
                      currentWeight - 2.5,
                      'Too Heavy',
                      Colors.red.shade400,
                    ),
                    _buildQuickAdjustButton(
                      'TOO_LIGHT\n+2.5KG',
                      currentWeight + 2.5,
                      'Too Light',
                      Colors.blue.shade400,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Reset to prescribed button
                if (_hasWeightAdjustment) ...[
                  OutlinedButton(
                    onPressed: _resetWeight,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                      side: BorderSide(color: Colors.grey.shade600),
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
                  const SizedBox(height: 10),
                ],
                
                // Cancel button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showWeightAdjustment = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
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
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: newWeight > 0 ? () => _adjustWeight(newWeight, reason) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
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