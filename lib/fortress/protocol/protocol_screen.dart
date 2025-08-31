import 'package:flutter/material.dart';
import 'widgets/rest_timer.dart';
import 'widgets/rep_logger.dart';
import '../engine/mandate_engine.dart';
import '../engine/models/exercise.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository.dart';

/// The Protocol Screen - The heart of the workout experience
/// Minimalist, brutal, effective
class ProtocolScreen extends StatefulWidget {
  final WorkoutMandate mandate;
  
  const ProtocolScreen({
    Key? key,
    required this.mandate,
  }) : super(key: key);
  
  @override
  State<ProtocolScreen> createState() => _ProtocolScreenState();
}

class _ProtocolScreenState extends State<ProtocolScreen> {
  late WorkoutRepository _repository;
  late MandateEngine _engine;
  
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restSeconds = 180;
  
  // Calibration mode tracking
  bool _isCalibrating = false;
  double _currentCalibrationWeight = 20.0;
  int _calibrationAttempt = 1;
  Map<String, double> _calibratedWeights = {};
  
  List<SetData> _sessionSets = [];
  
  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _engine = MandateEngine();
    
    // Check if first exercise needs calibration
    if (widget.mandate.prescriptions.isNotEmpty) {
      _isCalibrating = widget.mandate.prescriptions[0].needsCalibration;
      if (_isCalibrating) {
        _currentCalibrationWeight = widget.mandate.prescriptions[0].prescribedWeight;
      }
    }
  }
  
  Future<void> _initializeRepository() async {
    _repository = await WorkoutRepository.create();
  }
  
  ExercisePrescription get _currentPrescription {
    return widget.mandate.prescriptions[_currentExerciseIndex];
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
      _calibratedWeights[_currentPrescription.exercise.id] = _currentCalibrationWeight;
      
      // If this is bench press on Day 1, estimate all other weights
      if (widget.mandate.isDay1 && _currentPrescription.exercise.id == 'bench') {
        final estimatedWeights = _engine.estimateWeightsFromBenchPress(_currentCalibrationWeight);
        _calibratedWeights.addAll(estimatedWeights);
      }
      
      // Save the calibration as a set
      final setData = SetData(
        exerciseId: _currentPrescription.exercise.id,
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
        if (_currentExerciseIndex < widget.mandate.prescriptions.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          _calibrationAttempt = 1;
          
          // Check if next exercise needs calibration
          final nextPrescription = widget.mandate.prescriptions[_currentExerciseIndex];
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
        _restSeconds = actualReps < 5 ? 180 : 120; // Less rest if too heavy
      });
    }
  }
  
  void _handleWorkoutReps(int actualReps) async {
    // Create set data
    final setData = SetData(
      exerciseId: _currentPrescription.exercise.id,
      weight: _currentPrescription.prescribedWeight,
      actualReps: actualReps,
      timestamp: DateTime.now(),
      setNumber: _currentSet,
      restTaken: _restSeconds,
    );
    
    // Save to repository
    await _repository.saveSet(setData);
    _sessionSets.add(setData);
    
    // Calculate rest time based on performance
    final calculatedRest = _engine.calculateRestSeconds(
      actualReps,
      _currentPrescription.restSeconds,
    );
    
    setState(() {
      if (_currentSet < _currentPrescription.targetSets) {
        // More sets remaining for this exercise
        _currentSet++;
        _isResting = true;
        _restSeconds = calculatedRest;
      } else {
        // Move to next exercise
        if (_currentExerciseIndex < widget.mandate.prescriptions.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          
          // Check if next exercise needs calibration
          final nextPrescription = widget.mandate.prescriptions[_currentExerciseIndex];
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
    });
  }
  
  void _completeWorkout() {
    // Navigate to completion screen or back to mandate
    Navigator.of(context).pop(_sessionSets);
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
            onPressed: () => Navigator.of(context).pop(),
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
            canSkip: false, // Rest is mandatory
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
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
                value: (_currentExerciseIndex * 3 + _currentSet) / 
                       (widget.mandate.prescriptions.length * 3),
                backgroundColor: Colors.grey.shade900,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
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
                      _currentPrescription.exercise.name.toUpperCase(),
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
                        : 'SET $_currentSet OF ${_currentPrescription.targetSets}',
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
                          color: _isCalibrating ? Colors.amber : const Color(0xFF00FF00), 
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
                              : '${_currentPrescription.prescribedWeight} KG',
                            style: TextStyle(
                              color: _isCalibrating ? Colors.amber : const Color(0xFF00FF00),
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
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
            ),
          ],
        ),
      ),
    );
  }
}