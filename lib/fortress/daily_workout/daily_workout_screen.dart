import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../engine/models/set_data.dart';
import '../engine/workout_engine.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../../providers/workout_viewmodel_provider.dart';
import '../../providers/repository_provider.dart';
import '../protocol/protocol_screen.dart';
import '../../core/theme/heavyweight_theme.dart';


/// The Daily Workout Screen - The sole entry point to the system
/// No choices, only the workout
/// Now uses WorkoutViewModel for state management
class DailyWorkoutScreen extends StatefulWidget {
  const DailyWorkoutScreen({super.key});
  
  static Widget withProvider() {
    return const WorkoutViewModelProvider(
      child: DailyWorkoutScreen(),
    );
  }
  
  @override
  State<DailyWorkoutScreen> createState() => _DailyWorkoutScreenState();
}

class _DailyWorkoutScreenState extends State<DailyWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutViewModel>().initialize();
    });
  }
  


  
  Future<void> _beginProtocol() async {
    final viewModel = context.read<WorkoutViewModel>();
    if (viewModel.todaysWorkout == null) return;
    
    // Navigate to protocol screen - it will handle completion flow
    context.push<List<SetData>>(
      '/protocol',
      extra: viewModel.todaysWorkout!,
    );
  }
  

  
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }
        
        if (viewModel.error != null) {
          return _buildError(viewModel.error!);
        }
        
        if (!viewModel.hasWorkout) {
          return _buildRestDay();
        }
        
        return _buildWorkout(viewModel.todaysWorkout!);
      },
    );
  }
  
  Widget _buildError(String error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'ERROR',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<WorkoutViewModel>().initialize();
                },
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWorkout(DailyWorkout workout) {
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
                  // Back button row
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/'); // Go back to main app
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${workout.dayName} DAY',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TODAY\'S WORKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Exercises list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return _buildExerciseCard(exercise, index + 1);
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
                      backgroundColor: Colors.white,
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
                      final repository = context.read<RepositoryProvider>().repository;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      // Also clear the workout database
                      if (repository != null) {
                        await repository.clearAll();
                      }
                      if (!mounted) return;
                      context.go('/manifesto');
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
  
  Widget _buildExerciseCard(PlannedExercise exercise, int order) {
    final bool needsCalibration = exercise.needsCalibration;
    
    // Use theme-based colors for consistency
    final cardColor = HeavyweightTheme.surface;
    final borderColor = needsCalibration 
        ? HeavyweightTheme.warning 
        : HeavyweightTheme.secondary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor, 
          width: needsCalibration ? 3 : 2,
        ),
        color: cardColor.withOpacity(0.3),
        boxShadow: needsCalibration ? [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
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
            exercise.exercise.name.toUpperCase(),
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
                      ? 'FIND 5RM'
                      : '${exercise.prescribedWeight} KG',
                    style: TextStyle(
                      color: needsCalibration ? Colors.amber : Colors.white,
                      fontSize: needsCalibration ? 14 : 18,
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
                    '${exercise.targetSets}',
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
          
          const SizedBox(height: 16),
          
          // Exercise Intel Access
          InkWell(
            onTap: () {
              context.go('/exercise-intel', extra: {
                'exerciseId': exercise.exercise.id,
                'exerciseName': exercise.exercise.name,
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                color: Colors.grey.shade900.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FORM_PROTOCOL',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
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

}