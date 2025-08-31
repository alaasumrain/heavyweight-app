import 'package:flutter/material.dart';
import '../engine/mandate_engine.dart';
import '../engine/models/exercise.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository.dart';
import '../protocol/widgets/rep_logger.dart';

/// Calibration Protocol Screen - Day One Initiation
/// Establishes the user's true 4-6 rep max for each exercise
class CalibrationProtocolScreen extends StatefulWidget {
  const CalibrationProtocolScreen({Key? key}) : super(key: key);
  
  @override
  State<CalibrationProtocolScreen> createState() => _CalibrationProtocolScreenState();
}

class _CalibrationProtocolScreenState extends State<CalibrationProtocolScreen> {
  late WorkoutRepository _repository;
  late MandateEngine _engine;
  
  int _currentExerciseIndex = 0;
  double _currentWeight = 20.0; // Starting weight
  int _attemptNumber = 1;
  Map<String, double> _calibratedWeights = {};
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _engine = MandateEngine();
    _initializeRepository();
  }
  
  Future<void> _initializeRepository() async {
    _repository = await WorkoutRepository.create();
    
    // Set initial weight for first exercise
    _currentWeight = Exercise.bigSix[_currentExerciseIndex].prescribedWeight;
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Exercise get _currentExercise => Exercise.bigSix[_currentExerciseIndex];
  
  void _onRepsLogged(int actualReps) async {
    // Save the attempt
    final setData = SetData(
      exerciseId: _currentExercise.id,
      weight: _currentWeight,
      actualReps: actualReps,
      timestamp: DateTime.now(),
      setNumber: _attemptNumber,
      restTaken: 180, // Standard rest during calibration
    );
    
    await _repository.saveSet(setData);
    
    // Determine if calibration is complete for this exercise
    if (actualReps >= 4 && actualReps <= 6) {
      // Perfect - this is the calibrated weight
      _calibratedWeights[_currentExercise.id] = _currentWeight;
      _moveToNextExercise();
    } else if (actualReps < 4) {
      // Too heavy - reduce weight
      setState(() {
        _currentWeight = _currentWeight * 0.9;
        _attemptNumber++;
      });
      _showFeedback('TOO HEAVY - REDUCING WEIGHT', Colors.red);
    } else {
      // Too light - increase weight
      setState(() {
        _currentWeight = _currentWeight * 1.1;
        _attemptNumber++;
      });
      _showFeedback('TOO LIGHT - INCREASING WEIGHT', Colors.amber);
    }
  }
  
  void _moveToNextExercise() {
    if (_currentExerciseIndex < Exercise.bigSix.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentWeight = Exercise.bigSix[_currentExerciseIndex].prescribedWeight;
        _attemptNumber = 1;
      });
      _showFeedback('CALIBRATED - NEXT EXERCISE', const Color(0xFF00FF00));
    } else {
      _completeCalibration();
    }
  }
  
  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _completeCalibration() async {
    // Save calibrated weights
    await _repository.saveExerciseWeights(_calibratedWeights);
    await _repository.markCalibrationComplete();
    
    // Show completion dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: const Text(
          'CALIBRATION COMPLETE',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Your baseline has been established.\n\nThe system now knows your truth.\n\nThe mandate begins tomorrow.',
          style: TextStyle(
            color: Colors.grey.shade400,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to mandate screen
            },
            child: const Text(
              'UNDERSTOOD',
              style: TextStyle(
                color: Color(0xFF00FF00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00FF00),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'CALIBRATION PROTOCOL',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Progress
                  LinearProgressIndicator(
                    value: (_currentExerciseIndex + 1) / Exercise.bigSix.length,
                    backgroundColor: Colors.grey.shade900,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Exercise ${_currentExerciseIndex + 1} of ${Exercise.bigSix.length}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                children: [
                  const Text(
                    'OBJECTIVE',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Find the weight where you can complete\nEXACTLY 4-6 reps with maximum effort.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Current exercise
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Exercise name
                    Text(
                      _currentExercise.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Attempt number
                    Text(
                      'ATTEMPT #$_attemptNumber',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Current test weight
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TEST WEIGHT',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _currentWeight = (_currentWeight - 2.5).clamp(0, 500);
                                  });
                                },
                                icon: const Icon(Icons.remove),
                                color: Colors.white,
                                iconSize: 32,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '${_currentWeight.toStringAsFixed(1)} KG',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _currentWeight = (_currentWeight + 2.5).clamp(0, 500);
                                  });
                                },
                                icon: const Icon(Icons.add),
                                color: Colors.white,
                                iconSize: 32,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Instructions
                    Text(
                      'Load the weight and perform as many reps as possible.\nBe honest. Stop at true failure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
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