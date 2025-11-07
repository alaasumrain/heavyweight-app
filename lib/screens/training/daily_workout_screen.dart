import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../fortress/engine/workout_engine.dart'
    show DailyWorkout, PlannedExercise;
import '../../fortress/viewmodels/workout_viewmodel.dart';
import '../../providers/workout_viewmodel_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/logging.dart';
import '../../core/workout_session_manager.dart';
import '../../providers/profile_provider.dart';
import '../../core/units.dart';

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
      _checkForActiveSession();
    });
  }

  /// Check if there's an active workout session to resume
  Future<void> _checkForActiveSession() async {
    HWLog.event('daily_workout_check_session');
    final router = GoRouter.of(context);
    final appState = context.read<AppStateProvider>().appState;
    final workoutViewModel = context.read<WorkoutViewModel>();

    final hasSession = await WorkoutSessionManager.hasActiveSession();

    HWLog.event('daily_workout_session_check_result', data: {
      'hasActiveSession': hasSession,
    });

    if (hasSession && mounted) {
      final shouldResume = await _showResumeDialog();
      if (!mounted) return;
      HWLog.event('daily_workout_resume_dialog_result', data: {
        'userChoseResume': shouldResume,
      });

      if (shouldResume) {
        final session = await WorkoutSessionManager.loadActiveSession();
        if (!mounted) return;
        if (session != null) {
          HWLog.event('daily_workout_resuming_session', data: {
            'exerciseIndex': session.currentExerciseIndex,
            'set': session.currentSet,
            'completedSets': session.sessionSets.length,
          });
          // Navigate directly to protocol with restored session
          router.go('/protocol', extra: session.workout);
          return;
        }
      } else {
        // User chose not to resume - clear the session
        HWLog.event('daily_workout_user_declined_resume');
        await WorkoutSessionManager.clearActiveSession();
        if (!mounted) return;
      }
    }

    // No session to resume, initialize normally
    final preferredStartingDay = appState.preferredStartingDay;
    workoutViewModel.initialize(preferredStartingDay: preferredStartingDay);
  }

  /// Show dialog asking user if they want to resume their workout
  Future<bool> _showResumeDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.background,
        title: const Text(
          'RESUME WORKOUT?',
          style: TextStyle(
            color: HeavyweightTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: const Text(
          'You have an unfinished workout session.\n\nWould you like to continue where you left off?',
          style: TextStyle(
            color: HeavyweightTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'START NEW',
              style: TextStyle(color: HeavyweightTheme.danger),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'RESUME',
              style: TextStyle(color: HeavyweightTheme.primary),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _beginProtocol() async {
    final viewModel = context.read<WorkoutViewModel>();
    if (viewModel.todaysWorkout == null) return;
    HWLog.event('daily_workout_begin_protocol');

    // Navigate to protocol screen - it will handle completion flow
    GoRouter.of(context).go('/protocol', extra: viewModel.todaysWorkout!);
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
          HWLog.event('daily_workout_state',
              data: {'state': 'error', 'error': viewModel.error.toString()});
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
      title: 'ASSIGNMENT',
      subtitle: DateTime.now().toString().split(' ').first,
      showNavigation: true,
      navIndex: 0,
      body: Padding(
        padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: HeavyweightTheme.danger, size: 48),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            Text('SYSTEM_FAULT',
                style: HeavyweightTheme.h3
                    .copyWith(color: HeavyweightTheme.danger)),
            const SizedBox(height: HeavyweightTheme.spacingSm),
            Text(
              error.toUpperCase(),
              textAlign: TextAlign.center,
              style: HeavyweightTheme.bodySmall
                  .copyWith(color: HeavyweightTheme.textSecondary),
            ),
            const SizedBox(height: HeavyweightTheme.spacingXl),
            CommandButton(
              text: 'RETRY',
              onPressed: () {
                final appState = context.read<AppStateProvider>().appState;
                final preferredStartingDay = appState.preferredStartingDay;
                context.read<WorkoutViewModel>().initialize(
                    preferredStartingDay: preferredStartingDay,
                    forceRefresh: true);
              },
            ),
            const SizedBox(height: HeavyweightTheme.spacingMd),
            CommandButton(
              text: 'RETURN_TO_ASSIGNMENT',
              variant: ButtonVariant.secondary,
              onPressed: () => context.go('/app?tab=0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkout(DailyWorkout workout) {
    final profile = context.watch<ProfileProvider>();
    final unit = profile.unit == Unit.kg ? HWUnit.kg : HWUnit.lb;
    final exercises = workout.exercises;

    return HeavyweightScaffold(
      title: 'ASSIGNMENT: ${workout.dayName.toUpperCase()}',
      subtitle: DateTime.now().toString().split(' ').first,
      navIndex: 0,
      showNavigation: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HeavyweightTheme.spacingLg,
          vertical: HeavyweightTheme.spacingLg,
        ),
        child: CommandButton(
          text: 'BEGIN TRAINING',
          onPressed: _beginProtocol,
        ),
      ),
      bodyPadding: EdgeInsets.fromLTRB(
        HeavyweightTheme.spacingMd,
        HeavyweightTheme.spacingMd,
        HeavyweightTheme.spacingMd,
        HeavyweightTheme.buttonHeight + HeavyweightTheme.spacingXxl,
      ),
      body: RefreshIndicator(
        color: HeavyweightTheme.primary,
        backgroundColor: HeavyweightTheme.surface,
        onRefresh: () async {
          final appState = context.read<AppStateProvider>().appState;
          await context.read<WorkoutViewModel>().initialize(
                preferredStartingDay: appState.preferredStartingDay,
                forceRefresh: true,
              );
        },
        child: ListView(
          children: [
            _buildMandateBanner(),
            const SizedBox(height: HeavyweightTheme.spacingLg),
            ...List.generate(
              exercises.length,
              (index) => _buildExerciseEntry(
                exercises[index],
                index + 1,
                unit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMandateBanner() {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.secondary),
        color: HeavyweightTheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MANDATE: 4-6 REPS',
            style: HeavyweightTheme.labelMedium.copyWith(
              color: HeavyweightTheme.primary,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          Text(
            'LOG TRUTH. ADJUST LOAD ONLY WHEN ORDERED.',
            style: HeavyweightTheme.bodySmall.copyWith(
              color: HeavyweightTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseEntry(PlannedExercise exercise, int order, HWUnit unit) {
    final needsCalibration = exercise.needsCalibration;
    final loadText = needsCalibration
        ? 'CALIBRATE'
        : '${formatWeightForUnit(exercise.prescribedWeight, unit)} ${unit == HWUnit.kg ? 'KG' : 'LB'}';

    return Container(
      margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(
          color: needsCalibration
              ? HeavyweightTheme.warning
              : HeavyweightTheme.secondary,
          width: needsCalibration ? 2.5 : 1.5,
        ),
        color: HeavyweightTheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "[${order.toString().padLeft(2, '0')}] ${exercise.exercise.name.toUpperCase()}",
            style: HeavyweightTheme.h4,
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TARGET: ${exercise.targetSets} SETS",
                style: HeavyweightTheme.bodySmall.copyWith(
                  color: HeavyweightTheme.textSecondary,
                ),
              ),
              Text(
                loadText,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: needsCalibration
                      ? HeavyweightTheme.warning
                      : HeavyweightTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (needsCalibration) ...[
            const SizedBox(height: HeavyweightTheme.spacingXs),
            Text(
              'FIND TRUE 5RM BEFORE PROCEEDING.',
              style: HeavyweightTheme.bodySmall
                  .copyWith(color: HeavyweightTheme.warning),
            ),
          ],
        ],
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
