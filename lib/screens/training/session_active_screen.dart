import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../components/ui/selector_wheel.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../core/logging.dart';

class SessionActiveScreen extends StatefulWidget {
  const SessionActiveScreen({super.key});

  @override
  State<SessionActiveScreen> createState() => _SessionActiveScreenState();
}

class _SessionActiveScreenState extends State<SessionActiveScreen> {
  // Current session state
  int currentExercise = 1;
  int currentSet = 1;
  int totalSets = 3;
  String exerciseName = 'SQUAT';
  double currentWeight = 80.0;
  int repsCompleted = 0;

  // Session log
  List<Map<String, dynamic>> sessionLog = [];

  // UI state
  bool isLogging = false;
  String? lastFeedback;
  bool _sessionComplete = false;

  @override
  Widget build(BuildContext context) {
    HWLog.screen('Training/SessionActive');
    return HeavyweightScaffold(
      title: 'SESSION_ACTIVE',
      subtitle:
          'EXERCISE_${currentExercise.toString().padLeft(2, '0')}_SET_${currentSet.toString().padLeft(2, '0')}',
      showNavigation: false, // Hide nav during session
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current exercise display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
            decoration: BoxDecoration(
              border: Border.all(color: HeavyweightTheme.primary, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      exerciseName,
                      style: HeavyweightTheme.h2,
                    ),
                    Text(
                      '[$currentSet/$totalSets]',
                      style: HeavyweightTheme.h3.copyWith(
                        color: HeavyweightTheme.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: HeavyweightTheme.spacingMd),
                Row(
                  children: [
                    Text(
                      'LOAD: ',
                      style: HeavyweightTheme.labelMedium,
                    ),
                    Text(
                      '${currentWeight.toStringAsFixed(1)} KG',
                      style: HeavyweightTheme.h3.copyWith(
                        color: HeavyweightTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: HeavyweightTheme.spacingXl),

          // Rep input section
          Text(
            'INPUT_REPS:',
            style: HeavyweightTheme.labelMedium.copyWith(
              color: HeavyweightTheme.primary,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingMd),

          Center(
            child: SelectorWheel(
              value: repsCompleted,
              min: 0,
              max: 15,
              onChanged: (value) {
                HWLog.event('session_active_reps_change',
                    data: {'value': value});
                setState(() {
                  repsCompleted = value;
                });
              },
              suffix: 'REPS',
            ),
          ),

          const SizedBox(height: HeavyweightTheme.spacingXl),

          // Log set button
          CommandButton(
            text: isLogging ? 'LOGGING...' : 'LOG_SET',
            variant: ButtonVariant.primary,
            onPressed: isLogging
                ? null
                : () {
                    HWLog.event('session_active_log_set',
                        data: {'reps': repsCompleted, 'weight': currentWeight});
                    _logSet();
                  },
          ),

          const SizedBox(height: HeavyweightTheme.spacingLg),

          // Feedback display
          if (lastFeedback != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border.all(color: HeavyweightTheme.accent, width: 1),
              ),
              child: Text(
                lastFeedback!,
                style: HeavyweightTheme.bodyMedium.copyWith(
                  color: HeavyweightTheme.accent,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: HeavyweightTheme.spacingXl),

          // Session log
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESSION_LOG:',
                  style: HeavyweightTheme.labelMedium.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: HeavyweightTheme.spacingMd),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: HeavyweightTheme.textSecondary, width: 1),
                    ),
                    child: sessionLog.isEmpty
                        ? Text(
                            'NO_SETS_LOGGED',
                            style: HeavyweightTheme.bodySmall.copyWith(
                              color: HeavyweightTheme.textSecondary,
                            ),
                          )
                        : ListView.separated(
                            itemCount: sessionLog.length,
                            separatorBuilder: (_, __) => const SizedBox(
                                height: HeavyweightTheme.spacingSm),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final entry = sessionLog[index];
                              return Text(
                                '${entry['exercise']} SET_${entry['set']}: ${entry['reps']}@${entry['weight']}KG ${entry['status']}',
                                style: HeavyweightTheme.bodySmall,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: HeavyweightTheme.spacingLg),

          // Session controls
          Row(
            children: [
              Expanded(
                child: CommandButton(
                  text: 'TERMINATE_SESSION',
                  variant: ButtonVariant.danger,
                  onPressed: () {
                    HWLog.event('session_active_terminate');
                    _terminateSession();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _logSet() async {
    if (repsCompleted == 0) {
      setState(() {
        lastFeedback = 'ERROR: REPS_REQUIRED';
      });
      return;
    }

    setState(() {
      isLogging = true;
      lastFeedback = null;
    });

    // Simulate logging delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Determine feedback based on reps
    String status;
    String feedback;

    if (repsCompleted <= 3) {
      status = 'BELOW_RANGE';
      feedback = 'ADJUST_WEIGHT_DOWN';
    } else if (repsCompleted >= 7) {
      status = 'ABOVE_RANGE';
      feedback = 'ADJUST_WEIGHT_UP';
    } else {
      status = 'IN_RANGE';
      feedback = 'LOAD_OK';
    }

    // Add to session log
    final entry = {
      'exercise': exerciseName,
      'set': currentSet,
      'reps': repsCompleted,
      'weight': currentWeight,
      'status': status,
    };

    setState(() {
      sessionLog.add(entry);
      isLogging = false;
      lastFeedback = feedback;

      // Progress to next set or exercise
      if (currentSet < totalSets) {
        currentSet++;
      } else {
        // Move to next exercise or complete session
        if (currentExercise < 3) {
          currentExercise++;
          currentSet = 1;
          _loadNextExercise();
        } else {
          _completeSession();
        }
      }

      // Reset reps for next set
      repsCompleted = 0;
    });

    // Auto-trigger rest period if not last set
    if (!_sessionComplete && currentSet <= totalSets && currentExercise <= 3) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!_sessionComplete && mounted) {
          _startRestPeriod();
        }
      });
    }
  }

  void _loadNextExercise() {
    switch (currentExercise) {
      case 2:
        exerciseName = 'BENCH_PRESS';
        currentWeight = 60.0;
        break;
      case 3:
        exerciseName = 'BARBELL_ROW';
        currentWeight = 55.0;
        break;
    }
  }

  void _startRestPeriod() {
    // Navigate to enforced rest screen
    context.go('/enforced-rest');
  }

  void _completeSession() {
    _sessionComplete = true;
    // Navigate to session complete screen (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SESSION_COMPLETE',
          style: HeavyweightTheme.bodyMedium.copyWith(
            color: HeavyweightTheme.textPrimary,
          ),
        ),
        backgroundColor: HeavyweightTheme.surface,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _terminateSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.surface,
        title: Text(
          'TERMINATE_SESSION?',
          style: HeavyweightTheme.h4,
        ),
        content: Text(
          'ALL_PROGRESS_WILL_BE_LOST',
          style: HeavyweightTheme.bodyMedium,
        ),
        actions: [
          CommandButton(
            text: 'CANCEL',
            variant: ButtonVariant.secondary,
            size: ButtonSize.medium,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: HeavyweightTheme.spacingMd),
          CommandButton(
            text: 'TERMINATE',
            variant: ButtonVariant.danger,
            size: ButtonSize.medium,
            onPressed: () {
              context.pop();
              context.pop(); // Return to assignment
            },
          ),
        ],
      ),
    );
  }
}
