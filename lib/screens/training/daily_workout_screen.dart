import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/engine/workout_engine.dart';
import '../../fortress/viewmodels/workout_viewmodel.dart';
import '../../providers/workout_viewmodel_provider.dart';
import '../../providers/repository_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/logging.dart';


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
    HWLog.screen('Training/DailyWorkout');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HWLog.event('daily_workout_init_post_frame');
      // Get preferred starting day from app state
      final appState = context.read<AppStateProvider>().appState;
      final preferredStartingDay = appState.preferredStartingDay;
      context.read<WorkoutViewModel>().initialize(preferredStartingDay: preferredStartingDay);
    });
  }
  


  
  Future<void> _beginProtocol() async {
    final viewModel = context.read<WorkoutViewModel>();
    if (viewModel.todaysWorkout == null) return;
    HWLog.event('daily_workout_begin_protocol');
    
    // Navigate to protocol screen - it will handle completion flow
    context.push<List<SetData>>(
      '/protocol',
      extra: viewModel.todaysWorkout!,
    );
  }
  

  
  @override
  Widget build(BuildContext context) {
    HWLog.event('daily_workout_build');
    return Consumer<WorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          HWLog.event('daily_workout_state', data: {'state': 'loading'});
          return const HeavyweightScaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: HeavyweightTheme.primary,
              ),
            ),
          );
        }
        
        if (viewModel.error != null) {
          HWLog.event('daily_workout_state', data: {'state': 'error', 'error': viewModel.error.toString()});
          return _buildError(viewModel.error!);
        }
        
        if (!viewModel.hasWorkout) {
          HWLog.event('daily_workout_state', data: {'state': 'rest_day'});
          return _buildRestDay();
        }
        
        HWLog.event('daily_workout_state', data: {'state': 'ready'});
        return _buildWorkout(viewModel.todaysWorkout!);
      },
    );
  }
  
  Widget _buildError(String error) {
    return HeavyweightScaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: HeavyweightTheme.danger,
                size: 48,
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              Text(
                'ERROR',
                style: TextStyle(
                  color: HeavyweightTheme.danger,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingSm),
              Text(
                error,
                style: TextStyle(
                  color: HeavyweightTheme.primary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HeavyweightTheme.spacingLg),
              CommandButton(
                text: 'RETRY',
                variant: ButtonVariant.primary,
                onPressed: () {
                  final appState = context.read<AppStateProvider>().appState;
                  final preferredStartingDay = appState.preferredStartingDay;
                  context.read<WorkoutViewModel>().initialize(preferredStartingDay: preferredStartingDay);
                },
              ),
            ],
          ),
        ),
    );
  }
  
  Widget _buildWorkout(DailyWorkout workout) {
    return HeavyweightScaffold(
      title: '${workout.dayName} DAY',
      subtitle: DateTime.now().toString().split(' ')[0],
      body: Column(
          children: [
            const SizedBox(height: HeavyweightTheme.spacingSm),
            
            // Exercises list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return _buildExerciseCard(exercise, index + 1);
                },
              ),
            ),
            
            // Begin Protocol button
            Container(
              padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
              child: Column(
                children: [
                  CommandButton(
                    text: 'BEGIN PROTOCOL',
                    variant: ButtonVariant.primary,
                    onPressed: _beginProtocol,
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingMd),
                  // Debug reset button (temporary)
                  CommandButton(
                    text: 'RESET ALL & START DAY 1',
                    variant: ButtonVariant.danger,
                    size: ButtonSize.medium,
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
                  ),
                ],
              ),
            ),
          ],
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
    
    return Semantics(
      label: 'Exercise ${order}: ${exercise.exercise.name}. ${needsCalibration ? 'Needs calibration - find 5 rep max' : '${exercise.prescribedWeight} kilograms for ${exercise.targetSets} sets'}',
      child: Container(
      margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor, 
          width: needsCalibration ? 3 : 2,
        ),
        color: cardColor.withValues(alpha: 0.3),
        boxShadow: needsCalibration ? [
          BoxShadow(
            color: HeavyweightTheme.warning.withValues(alpha: 0.3),
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
            style: HeavyweightTheme.bodyMedium.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          
          // Exercise name with overflow protection
          Text(
            exercise.exercise.name.toUpperCase(),
            style: const TextStyle(
              color: HeavyweightTheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
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
                    style: HeavyweightTheme.labelSmall.copyWith(
                      color: HeavyweightTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingXs),
                  Text(
                    needsCalibration 
                      ? 'FIND 5RM'
                      : '${exercise.prescribedWeight} KG',
                    style: TextStyle(
                      color: needsCalibration ? HeavyweightTheme.warning : HeavyweightTheme.primary,
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
                    style: HeavyweightTheme.labelSmall.copyWith(
                      color: HeavyweightTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: HeavyweightTheme.spacingXs),
                  Text(
                    '${exercise.targetSets}',
                    style: const TextStyle(
                      color: HeavyweightTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Status with overflow protection
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'STATUS',
                      style: HeavyweightTheme.labelSmall.copyWith(
                        color: HeavyweightTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: HeavyweightTheme.spacingXs),
                    Text(
                      needsCalibration ? 'FIND 5RM' : 'FOLLOW PROTOCOL',
                      style: TextStyle(
                        color: HeavyweightTheme.warning,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          // Exercise Intel Access
          Semantics(
            button: true,
            label: 'View form protocol for ${exercise.exercise.name}',
            child: InkWell(
              onTap: () {
                context.go('/exercise-intel', extra: {
                  'exerciseId': exercise.exercise.id,
                  'exerciseName': exercise.exercise.name,
                });
              },
              child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: HeavyweightTheme.spacingSm, horizontal: HeavyweightTheme.spacingSm),
              decoration: BoxDecoration(
                border: Border.all(color: HeavyweightTheme.secondary),
                color: HeavyweightTheme.secondary.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: HeavyweightTheme.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: HeavyweightTheme.spacingSm),
                  Text(
                    'FORM_PROTOCOL',
                    style: TextStyle(
                      color: HeavyweightTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
  
  Widget _buildRestDay() {
    return HeavyweightScaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                color: HeavyweightTheme.danger,
                size: 100,
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              const Text(
                'REST DAY',
                style: TextStyle(
                  color: HeavyweightTheme.danger,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              Text(
                'Recovery is not optional.\nYour muscles grow during rest.',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXxl),
              Text(
                'NEXT WORKOUT: TOMORROW',
                style: HeavyweightTheme.labelSmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
    );
  }

}
