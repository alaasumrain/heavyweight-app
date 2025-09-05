import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../components/ui/warning_stripes.dart';
import '../../core/theme/heavyweight_theme.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);
  
  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool _showTutorial = false;
  
  // Current training focus - could be determined by workout logic
  final String _currentDay = 'DAY 1';
  final List<String> _todaysExercises = ['SQUAT', 'BENCH_PRESS', 'BARBELL_ROW'];
  
  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }
  
  String _getBodyPartFocus() {
    // Determine body part focus based on exercises
    final exercises = _todaysExercises.map((e) => e.toLowerCase()).toList();
    
    if (exercises.contains('bench_press') || exercises.contains('incline_press')) {
      return 'CHEST & TRICEPS FOCUS';
    } else if (exercises.contains('squat') || exercises.contains('deadlift')) {
      return 'LEGS & GLUTES FOCUS';
    } else if (exercises.contains('barbell_row') || exercises.contains('pull_up')) {
      return 'BACK & BICEPS FOCUS';
    } else if (exercises.contains('overhead_press') || exercises.contains('shoulder_press')) {
      return 'SHOULDERS & ARMS FOCUS';
    } else {
      return 'FULL BODY FOCUS';
    }
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    
    return Stack(
      children: [
        HeavyweightScaffold(
          title: 'ASSIGNMENT_$dateStr',
          subtitle: 'STATUS: PROTOCOL_READY',
          navIndex: 0,
          showNavigation: true,
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Training Day & Body Part Focus Banner
          WarningStripes.warning(
            height: 55,
            text: '$_currentDay: ${_getBodyPartFocus()}',
            textStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 3,
            ),
          ),
          
          
          // Training cycle progress indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: HeavyweightTheme.spacingMd,
              vertical: HeavyweightTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: HeavyweightTheme.warning, width: 4),
              ),
              color: HeavyweightTheme.warning.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRAINING CYCLE: WEEK 2 OF 4',
                  style: HeavyweightTheme.labelSmall.copyWith(
                    color: HeavyweightTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'PROGRESSION: ON TRACK',
                  style: HeavyweightTheme.labelSmall.copyWith(
                    color: HeavyweightTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingLg),
          
          // Terminal-style assignment header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: HeavyweightTheme.primary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM_STATUS: OPERATIONAL',
                  style: HeavyweightTheme.bodyMedium.copyWith(
                    color: HeavyweightTheme.primary,
                  ),
                ),
                const SizedBox(height: HeavyweightTheme.spacingSm),
                Text(
                  'LAST_SESSION: 2_DAYS_AGO',
                  style: HeavyweightTheme.labelSmall,
                ),
                Text(
                  'STREAK: 12_SESSIONS',
                  style: HeavyweightTheme.labelSmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
          
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
            child: ListView(
              children: [
                _buildTerminalExerciseEntry('01', 'SQUAT', '80.0', 'KG', '0/3', '6@77.5KG'),
                _buildTerminalExerciseEntry('02', 'BENCH_PRESS', '60.0', 'KG', '0/3', '5@57.5KG'),
                _buildTerminalExerciseEntry('03', 'BARBELL_ROW', '55.0', 'KG', '0/3', '6@52.5KG'),
                
                const SizedBox(height: HeavyweightTheme.spacingXl),
                
                // Session summary
                Container(
                  padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SESSION_SUMMARY:',
                        style: HeavyweightTheme.labelMedium.copyWith(
                          color: HeavyweightTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: HeavyweightTheme.spacingSm),
                      Text(
                        'TOTAL_SETS: 9',
                        style: HeavyweightTheme.bodySmall,
                      ),
                      Text(
                        'EST_DURATION: 45_MIN',
                        style: HeavyweightTheme.bodySmall,
                      ),
                      Text(
                        'TOTAL_VOLUME: 1755_KG',
                        style: HeavyweightTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
          
          // Begin Protocol button
          CommandButton(
            text: 'EXECUTE_PROTOCOL',
            variant: ButtonVariant.primary,
            onPressed: () {
              context.go('/session-active');
            },
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingLg),
          ],
        ),
        ),
        
        // HUD Tutorial Overlay
        if (_showTutorial)
          _buildHudTutorialOverlay(),
      ],
    );
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
                          _buildHudLabel('[1] YOUR MANDATE', 'Today\'s assigned training protocol'),
                          const SizedBox(height: 24),
                          _buildHudLabel('[2] YOUR LOGBOOK', 'Access via bottom navigation'),
                          const SizedBox(height: 24),
                          _buildHudLabel('[3] YOUR PROFILE', 'Calibration & system settings'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dismiss button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _dismissTutorial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'INTERFACE_UNDERSTOOD',
                    style: HeavyweightTheme.bodyMedium.copyWith(
                      color: Colors.black,
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
  
  Widget _buildTerminalExerciseEntry(String number, String exercise, String weight, String unit, String progress, String lastPerformance) {
    return Container(
      margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.textSecondary, width: 1),
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
    );
  }
}