import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../components/ui/warning_stripes.dart';
import '../../core/theme/heavyweight_theme.dart';

class EnforcedRestScreen extends StatefulWidget {
  const EnforcedRestScreen({Key? key}) : super(key: key);

  @override
  State<EnforcedRestScreen> createState() => _EnforcedRestScreenState();
}

class _EnforcedRestScreenState extends State<EnforcedRestScreen> {
  static const int totalRestSeconds = 180; // 3 minutes
  int remainingSeconds = totalRestSeconds;
  Timer? _timer;
  bool isRestComplete = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          isRestComplete = true;
          _timer?.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progressPercentage {
    return (totalRestSeconds - remainingSeconds) / totalRestSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return HeavyweightScaffold(
      title: 'ENFORCED_REST',
      subtitle: isRestComplete ? 'STATUS: READY_TO_CONTINUE' : 'STATUS: REST_MANDATORY',
      showNavigation: false, // No navigation during rest
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200, // Account for scaffold
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning stripes when rest is complete or in final countdown
              if (isRestComplete || remainingSeconds <= 30)
                WarningStripes.warning(
                  height: 45,
                  text: isRestComplete 
                      ? 'CONTINUE_PROTOCOL' 
                      : 'PREPARE_TO_CONTINUE',
                  animated: isRestComplete,
                ),
              
              if (isRestComplete || remainingSeconds <= 30)
                const SizedBox(height: HeavyweightTheme.spacingLg),
          // Large countdown display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HeavyweightTheme.spacingXl),
            decoration: BoxDecoration(
              border: Border.all(
                color: remainingSeconds <= 30 
                    ? HeavyweightTheme.error 
                    : HeavyweightTheme.primary,
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formattedTime,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: remainingSeconds <= 30 
                        ? HeavyweightTheme.error 
                        : HeavyweightTheme.textPrimary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: HeavyweightTheme.spacingMd),
                
                // Progress bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border.all(color: HeavyweightTheme.textSecondary),
                  ),
                  child: LinearProgressIndicator(
                    value: _progressPercentage,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      remainingSeconds <= 30 
                          ? HeavyweightTheme.error 
                          : HeavyweightTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
          
          // Rest status message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
            decoration: BoxDecoration(
              border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  isRestComplete 
                      ? 'REST_PERIOD_COMPLETE' 
                      : 'REST_PERIOD_ACTIVE',
                  style: HeavyweightTheme.h4.copyWith(
                    color: isRestComplete 
                        ? HeavyweightTheme.accent 
                        : HeavyweightTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: HeavyweightTheme.spacingSm),
                Text(
                  isRestComplete
                      ? 'SYSTEM_READY_FOR_NEXT_SET'
                      : 'ALL_COMMANDS_LOCKED',
                  style: HeavyweightTheme.bodyMedium.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
          
          // Next set preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT_SET_PREVIEW:',
                  style: HeavyweightTheme.labelMedium.copyWith(
                    color: HeavyweightTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: HeavyweightTheme.spacingSm),
                Row(
                  children: [
                    Text(
                      '├─ EXERCISE: ',
                      style: HeavyweightTheme.bodySmall.copyWith(
                        color: HeavyweightTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'SQUAT',
                      style: HeavyweightTheme.bodyMedium.copyWith(
                        color: HeavyweightTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '├─ SET: ',
                      style: HeavyweightTheme.bodySmall.copyWith(
                        color: HeavyweightTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '2/3',
                      style: HeavyweightTheme.bodyMedium.copyWith(
                        color: HeavyweightTheme.accent,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '└─ LOAD: ',
                      style: HeavyweightTheme.bodySmall.copyWith(
                        color: HeavyweightTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '80.0 KG',
                      style: HeavyweightTheme.bodyMedium.copyWith(
                        color: HeavyweightTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Continue button (only enabled when rest is complete)
          CommandButton(
            text: isRestComplete ? 'CONTINUE_PROTOCOL' : 'REST_MANDATORY',
            variant: isRestComplete ? ButtonVariant.primary : ButtonVariant.secondary,
            onPressed: isRestComplete ? _continueProtocol : null,
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          // Emergency terminate button
          CommandButton(
            text: 'TERMINATE_SESSION',
            variant: ButtonVariant.danger,
            onPressed: _terminateSession,
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
  
  void _continueProtocol() {
    // Return to session active screen
    context.pop();
  }
  
  void _terminateSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HeavyweightTheme.surface,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WarningStripes.danger(
              height: 35,
              text: 'CRITICAL_ACTION',
              animated: true,
            ),
            const SizedBox(height: 16),
            Text(
              'TERMINATE_SESSION?',
              style: HeavyweightTheme.h4,
            ),
          ],
        ),
        content: Text(
          'ALL_PROGRESS_WILL_BE_LOST',
          style: HeavyweightTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'CANCEL',
              style: HeavyweightTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Return to assignment
              context.pop(); // Exit session active too
            },
            child: Text(
              'TERMINATE',
              style: HeavyweightTheme.bodyMedium.copyWith(
                color: HeavyweightTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


