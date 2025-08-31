import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../engine/mandate_engine.dart';
import '../engine/models/set_data.dart';
import '../engine/storage/workout_repository.dart';
import '../protocol/protocol_screen.dart';
import 'calibration_protocol.dart';

/// The Mandate Screen - The sole entry point to the system
/// No choices, only the mandate
class MandateScreen extends StatefulWidget {
  const MandateScreen({Key? key}) : super(key: key);
  
  @override
  State<MandateScreen> createState() => _MandateScreenState();
}

class _MandateScreenState extends State<MandateScreen> {
  late WorkoutRepository _repository;
  late MandateEngine _engine;
  WorkoutMandate? _todaysMandate;
  bool _isLoading = true;
  bool _needsCalibration = false;
  
  @override
  void initState() {
    super.initState();
    _engine = MandateEngine();
    _initializeMandate();
  }
  
  Future<void> _initializeMandate() async {
    _repository = await WorkoutRepository.create();
    
    // Generate today's mandate (handles Day 1 automatically)
    final history = await _repository.getHistory();
    final mandate = _engine.generateMandate(history);
    
    setState(() {
      _todaysMandate = mandate;
      _isLoading = false;
    });
  }
  
  Future<void> _beginProtocol() async {
    if (_todaysMandate == null) return;
    
    final results = await Navigator.push<List<SetData>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProtocolScreen(mandate: _todaysMandate!),
      ),
    );
    
    if (results != null && results.isNotEmpty) {
      // Workout completed, refresh mandate
      _initializeMandate();
    }
  }
  
  Future<void> _beginCalibration() async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CalibrationProtocolScreen(),
      ),
    );
    
    if (completed == true) {
      _initializeMandate();
    }
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
    
    if (_todaysMandate == null || _todaysMandate!.isRestDay) {
      return _buildRestDay();
    }
    
    return _buildMandate();
  }
  
  Widget _buildMandate() {
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
                    DateTime.now().toString().split(' ')[0],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'TODAY\'S MANDATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Exercises list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _todaysMandate!.prescriptions.length,
                itemBuilder: (context, index) {
                  final prescription = _todaysMandate!.prescriptions[index];
                  return _buildExerciseCard(prescription, index + 1);
                },
              ),
            ),
            
            // Begin Protocol button
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _beginProtocol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 80),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'BEGIN PROTOCOL',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Debug reset button (temporary)
                  OutlinedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      // Also clear the workout database
                      await _repository.clearAll();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacementNamed('/fortress/manifesto');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1),
                      minimumSize: const Size(double.infinity, 40),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'RESET ALL & START DAY 1',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExerciseCard(ExercisePrescription prescription, int order) {
    final bool needsCalibration = prescription.needsCalibration;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: needsCalibration ? Colors.amber.shade800 : Colors.grey.shade800, 
          width: needsCalibration ? 2 : 1,
        ),
        color: Colors.grey.shade900,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order number
          Text(
            '$order.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          
          // Exercise name
          Text(
            prescription.exercise.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Weight or Calibration Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    needsCalibration ? 'STATUS' : 'WEIGHT',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    needsCalibration 
                      ? 'PENDING CALIBRATION'
                      : '${prescription.prescribedWeight} KG',
                    style: TextStyle(
                      color: needsCalibration ? Colors.amber : const Color(0xFF00FF00),
                      fontSize: needsCalibration ? 12 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Sets
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'SETS',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${prescription.targetSets}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Mandate
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MANDATE',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    needsCalibration ? 'FIND 5RM' : '4-6 REPS',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRestDay() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                color: Colors.red.shade900,
                size: 100,
              ),
              const SizedBox(height: 30),
              const Text(
                'REST DAY MANDATED',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Recovery is not optional.\nYour muscles grow during rest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'NEXT WORKOUT: TOMORROW',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalibrationRequired() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center,
                color: Color(0xFF00FF00),
                size: 100,
              ),
              const SizedBox(height: 30),
              const Text(
                'CALIBRATION REQUIRED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Before the mandate can be issued,\nwe must establish your baseline.\n\nYou will find your true 4-6 rep max\nfor each of the Big Six movements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _beginCalibration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 80),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'BEGIN CALIBRATION',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}