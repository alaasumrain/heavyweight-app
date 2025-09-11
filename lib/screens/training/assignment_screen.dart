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
import '../../providers/app_state_provider.dart';
import '../../fortress/engine/workout_engine.dart';
import '../../fortress/engine/models/exercise.dart';
import '../../core/logging.dart';

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
    HWLog.screen('Training/Assignment');
    // HUD tutorial disabled per UX feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HWLog.event('assignment_init_post_frame');
      // Get preferred starting day from app state
      final appState = context.read<AppStateProvider>().appState;
      final preferredStartingDay = appState.preferredStartingDay;
      context.read<WorkoutViewModel>().initialize(preferredStartingDay: preferredStartingDay);
      _loadSessionStats();
    });
  }
  
  Future<void> _loadSessionStats() async {
    try {
      HWLog.event('assignment_load_stats_start');
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
        HWLog.event('assignment_load_stats_done', data: {
          'lastSession': _lastSessionText,
          'streak': _streakText,
        });
      }
    } catch (e) {
      HWLog.event('assignment_load_stats_error', data: {'error': e.toString()});
      if (mounted) {
        setState(() {
          _lastSessionText = 'SYNC_FAILED';
          _streakText = 'SYNC_FAILED';
        });
      }
    }
  }
  
  String _getBodyPartFocus(DailyWorkout? workout) {
    if (workout == null) return 'INITIALIZING...';
    
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
    HWLog.event('assignment_show_exercise_info', data: {'exercise': exercise.id});
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: HeavyweightTheme.background,
        child: Container(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
          decoration: BoxDecoration(
            border: Border.all(color: HeavyweightTheme.primary),
            color: HeavyweightTheme.background,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name.toUpperCase(),
                style: HeavyweightTheme.h4,
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              Text(
                'EXERCISE_INTEL:',
                style: HeavyweightTheme.labelSmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingSm),
              Text(
                (exercise.description?.isNotEmpty ?? false)
                    ? exercise.description! 
                    : 'COMPOUND_MOVEMENT. FOCUS_ON_FORM. PROGRESSIVE_OVERLOAD.',
                style: HeavyweightTheme.bodyMedium,
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
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
    HWLog.event('assignment_build');
    return Consumer<WorkoutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          HWLog.event('assignment_state', data: {'state': 'loading'});
          return HeavyweightScaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: HeavyweightTheme.primary,
              ),
            ),
          );
        }
        
        if (viewModel.error != null) {
          HWLog.event('assignment_state', data: {'state': 'error', 'error': viewModel.error.toString()});
          return _buildError(viewModel.error!);
        }
        
        if (!viewModel.hasWorkout) {
          HWLog.event('assignment_state', data: {'state': 'rest_day'});
          return _buildRestDay();
        }
        
        return Stack(
          children: [
            HeavyweightScaffold(
              title: _getBodyPartFocus(viewModel.todaysWorkout),
              subtitle: _getSubtitle(),
              showNavigation: false,
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
    return HeavyweightScaffold(
      body: SafeArea(
        child: Center(
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
                style: HeavyweightTheme.h3.copyWith(
                  color: HeavyweightTheme.danger,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingSm),
              Text(
                error,
                style: HeavyweightTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HeavyweightTheme.spacingLg),
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
    return HeavyweightScaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                color: HeavyweightTheme.danger,
                size: 100,
              ),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              Text(
                'REST DAY ENFORCED',
                style: HeavyweightTheme.h2.copyWith(
                  color: HeavyweightTheme.danger,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingMd),
              Text(
                'Recovery is mandatory.\\nYour muscles grow during rest.',
                textAlign: TextAlign.center,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingXxl),
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
    return RepaintBoundary(
      child: GestureDetector(
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
        ),
      ),
    );
  }
  
  Widget _buildHudTutorialOverlay() {
    return Container(
      color: HeavyweightTheme.background.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: HeavyweightTheme.spacingXl),
              
              // Tutorial content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // HUD label
                    Text(
                      'HUD_ORIENTATION',
                      style: HeavyweightTheme.h3,
                    ),
                    
                    const SizedBox(height: HeavyweightTheme.spacingXxl),
                    
                    // Interface elements
                    Container(
                      padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
                      decoration: BoxDecoration(
                        border: Border.all(color: HeavyweightTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildHudLabel('[1] YOUR WORKOUT', 'Today\'s assigned training protocol'),
                          const SizedBox(height: HeavyweightTheme.spacingLg),
                          _buildHudLabel('[2] YOUR LOGBOOK', 'Access via bottom navigation'),
                          const SizedBox(height: HeavyweightTheme.spacingLg),
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
        const SizedBox(width: HeavyweightTheme.spacingMd),
        Expanded(
          child: Text(
            description,
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
