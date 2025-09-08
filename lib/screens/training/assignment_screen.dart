import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../fortress/viewmodels/workout_viewmodel.dart';
import '../../providers/workout_viewmodel_provider.dart';
import '../../providers/repository_provider.dart';
import '../../fortress/engine/workout_engine.dart';
import '../../fortress/engine/models/exercise.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);
  
  static Widget withProvider() {
    return const WorkoutViewModelProvider(
      child: AssignmentScreen(),
    );
  }
  
  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool _showTutorial = false;
  String _lastSessionText = 'LOADING';
  String _streakText = 'LOADING';
  
  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutViewModel>().initialize();
      _loadSessionStats();
    });
  }
  
  Future<void> _loadSessionStats() async {
    try {
      final viewModel = context.read<WorkoutViewModel>();
      final stats = await viewModel.getStats();
      
      // Get last session from repository
      final repository = context.read<RepositoryProvider>().repository;
      if (repository != null) {
        final lastSession = await repository.getLastSession();
        
        // Calculate days since last session
        String lastSessionDisplay = 'NO_PREVIOUS_SESSION';
        if (lastSession != null) {
          final daysSince = DateTime.now().difference(lastSession.date).inDays;
          if (daysSince == 0) {
            lastSessionDisplay = 'TODAY';
          } else if (daysSince == 1) {
            lastSessionDisplay = '1_DAY_AGO';
          } else {
            lastSessionDisplay = '${daysSince}_DAYS_AGO';
          }
        }
        
        // Set streak based on workout days
        final streakDisplay = '${stats.workoutDays}_SESSIONS';
        
        if (mounted) {
          setState(() {
            _lastSessionText = lastSessionDisplay;
            _streakText = streakDisplay;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastSessionText = 'ERROR_LOADING';
          _streakText = 'ERROR_LOADING';
        });
      }
    }
  }
  
  String _getBodyPartFocus(DailyWorkout? workout) {
    if (workout == null) return 'LOADING';
    
    // Just show the day name without date
    return workout.dayName;
  }
  
  String _getSubtitle() {
    final now = DateTime.now();
    final dayNames = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    final dayName = dayNames[now.weekday - 1];
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    
    return '$dayName | $dateStr';
  }
  
  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_hud_tutorial') ?? false;
    
    if (!hasSeenTutorial && mounted) {
      // Show tutorial after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showTutorial = true;
          });
        }
      });
    }
  }
  
  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_hud_tutorial', true);
    
    setState(() {
      _showTutorial = false;
    });
  }

  void _showExerciseInfo(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            color: Colors.black,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'EXERCISE_INTEL:',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (exercise.description?.isNotEmpty ?? false)
                    ? exercise.description! 
                    : 'COMPOUND_MOVEMENT. FOCUS_ON_FORM. PROGRESSIVE_OVERLOAD.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              CommandButton(
                text: 'COMMAND: CLOSE',
                variant: ButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          ),
        ),
      ),
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
        
        return Stack(
          children: [
            HeavyweightScaffold(
              title: _getBodyPartFocus(viewModel.todaysWorkout),
              subtitle: _getSubtitle(),
              navIndex: 0,
              showNavigation: true,
              body: _buildWorkoutContent(viewModel.todaysWorkout!),
            ),
            
            // HUD Tutorial Overlay
            if (_showTutorial)
              _buildHudTutorialOverlay(),
          ],
        );
      },
    );
  }
  
  Widget _buildWorkoutContent(DailyWorkout workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // Terminal-style exercise list
        Text(
          'PROTOCOL_SEQUENCE:',
          style: HeavyweightTheme.labelMedium.copyWith(
            color: HeavyweightTheme.primary,
          ),
        ),
        const SizedBox(height: HeavyweightTheme.spacingMd),
            
        // Exercise assignments
        Expanded(
          child: ListView.builder(
            itemCount: workout.exercises.length,
            itemBuilder: (context, index) {
              final exercise = workout.exercises[index];
              return _buildTerminalExerciseEntry(
                '${(index + 1).toString().padLeft(2, '0')}',
                exercise.exercise.name.toUpperCase().replaceAll(' ', '_'),
                exercise.prescribedWeight.toString(),
                'KG',
                '0/${exercise.targetSets}',
                'LAST: --',
                onTap: () => _showExerciseInfo(exercise.exercise),
              );
            },
          ),
        ),
        
        const SizedBox(height: HeavyweightTheme.spacingXl),
        
        // Begin Protocol button  
        CommandButton(
          text: 'BEGIN_WORKOUT',
          variant: ButtonVariant.primary,
          onPressed: () {
            context.go('/daily-workout');
          },
        ),
        
        const SizedBox(height: HeavyweightTheme.spacingLg),
      ],
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
                style: HeavyweightTheme.h3.copyWith(
                  color: Colors.red,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CommandButton(
                text: 'RETRY',
                onPressed: () {
                  context.read<WorkoutViewModel>().initialize();
                },
              ),
            ],
          ),
        ),
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
              Text(
                'REST DAY ENFORCED',
                style: HeavyweightTheme.h2.copyWith(
                  color: Colors.red,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Recovery is mandatory.\\nYour muscles grow during rest.',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'NEXT WORKOUT: TOMORROW',
                style: HeavyweightTheme.labelSmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTerminalExerciseEntry(String number, String exercise, String weight, String unit, String progress, String lastPerformance, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingXs),
        padding: const EdgeInsets.all(HeavyweightTheme.spacingXs),
        decoration: BoxDecoration(
          border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
          color: onTap != null ? HeavyweightTheme.surface : HeavyweightTheme.background,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise line with ASCII-style formatting
          Row(
            children: [
              Text(
                '[$number]',
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.primary,
                ),
              ),
              const SizedBox(width: HeavyweightTheme.spacingSm),
              Expanded(
                child: Text(
                  exercise,
                  style: HeavyweightTheme.h4,
                ),
              ),
              Text(
                '[$progress]',
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingSm),
          
          // Terminal-style data display
          Row(
            children: [
              Text(
                '├─ LOAD: ',
                style: HeavyweightTheme.bodySmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              Text(
                '$weight $unit',
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.primary,
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Text(
                '├─ STATUS: ',
                style: HeavyweightTheme.bodySmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              Text(
                'READY',
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.accent,
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Text(
                '└─ LAST: ',
                style: HeavyweightTheme.bodySmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              Text(
                lastPerformance,
                style: HeavyweightTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    ));
  }
  
  Widget _buildHudTutorialOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Tutorial content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // HUD label
                    Text(
                      'HUD_ORIENTATION',
                      style: HeavyweightTheme.h3.copyWith(
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Interface elements
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildHudLabel('[1] YOUR WORKOUT', 'Today\'s assigned training protocol'),
                          const SizedBox(height: 24),
                          _buildHudLabel('[2] YOUR LOGBOOK', 'Access via bottom navigation'),
                          const SizedBox(height: 24),
                          _buildHudLabel('[3] YOUR PROFILE', 'Settings & system configuration'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dismiss button
              CommandButton(
                text: 'INTERFACE_UNDERSTOOD',
                onPressed: _dismissTutorial,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHudLabel(String label, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HeavyweightTheme.bodyMedium.copyWith(
            color: HeavyweightTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            description,
            style: HeavyweightTheme.bodySmall.copyWith(
              color: Colors.grey.shade300,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}