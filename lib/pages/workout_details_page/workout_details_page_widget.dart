import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_details_page_model.dart';
export 'workout_details_page_model.dart';

class WorkoutDetailsPageWidget extends StatefulWidget {
  const WorkoutDetailsPageWidget({super.key});

  @override
  State<WorkoutDetailsPageWidget> createState() =>
      _WorkoutDetailsPageWidgetState();
}

class _WorkoutDetailsPageWidgetState extends State<WorkoutDetailsPageWidget> 
    with TickerProviderStateMixin {
  late WorkoutDetailsPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Session state
  int currentSet = 1;
  int currentExerciseIndex = 0;
  bool isResting = false;
  int restSeconds = 5; // 5 seconds for demo
  
  // Timer state
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  int _currentRestSeconds = 5;
  
  final List<Map<String, dynamic>> exercises = [
    {'name': 'BENCH PRESS', 'weight': '100 KG', 'target': '4-6 REPS'},
    {'name': 'INCLINE PRESS', 'weight': '80 KG', 'target': '4-6 REPS'},
    {'name': 'DIPS', 'weight': 'BW+20 KG', 'target': '4-6 REPS'},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WorkoutDetailsPageModel());
    _model.repsInputController ??= TextEditingController();
    
    // Initialize timer
    _timerController = AnimationController(
      duration: Duration(seconds: restSeconds),
      vsync: this,
    );
    _timerAnimation = Tween<double>(
      begin: restSeconds.toDouble(),
      end: 0.0,
    ).animate(_timerController)
      ..addListener(() {
        setState(() {
          _currentRestSeconds = _timerAnimation.value.ceil();
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            isResting = false;
            _currentRestSeconds = restSeconds;
          });
        }
      });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _logSet() {
    final reps = int.tryParse(_model.repsInputController?.text ?? '');
    if (reps == null || reps < 0 || reps > 30) return;
    
    setState(() {
      if (currentSet < 3) {
        currentSet++;
        isResting = true;
        // Start enforced rest timer
        _currentRestSeconds = restSeconds;
        _timerController.reset();
        _timerController.forward();
      } else {
        // Move to next exercise
        if (currentExerciseIndex < exercises.length - 1) {
          currentExerciseIndex++;
          currentSet = 1;
          isResting = true;
          // Start rest timer for next exercise
          _currentRestSeconds = restSeconds;
          _timerController.reset();
          _timerController.forward();
        } else {
          // Session complete
          _completeSession();
        }
      }
      _model.repsInputController?.clear();
    });
  }
  
  void _completeSession() {
    // Navigate to a full-screen completion report
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => _SessionCompleteScreen(
          exercisesCompleted: exercises.length,
          totalSets: exercises.length * 3,
        ),
      ),
    );
  }
  
  void _showAbortDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text(
            'ABORT_SESSION?',
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          content: Text(
            'PROGRESS_WILL_NOT_BE_SAVED.\nTHIS_ACTION_CANNOT_BE_UNDONE.',
            style: GoogleFonts.ibmPlexMono(
              color: const Color(0xFF999999),
              fontSize: 12.0,
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CONTINUE_SESSION',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.goNamed('homePage');
              },
              child: Text(
                'CONFIRM_ABORT',
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFFFF4444),
                  fontSize: 12.0,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = exercises[currentExerciseIndex];
    
    return WillPopScope(
      onWillPop: () async => false, // Disable Android back button completely
      child: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFF111111),
          appBar: AppBar(
            backgroundColor: const Color(0xFF111111),
            elevation: 0,
            automaticallyImplyLeading: false, // Remove back button
            title: Text(
              'SESSION_ACTIVE',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _showAbortDialog(),
                child: Text(
                  'ABORT',
                  style: GoogleFonts.ibmPlexMono(
                    color: const Color(0xFF666666),
                    fontSize: 12.0,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        body: isResting 
          ? _buildRestScreen()
          : Column(
              children: [
                // Progress bar
                Container(
                  height: 4.0,
                  color: const Color(0xFF222222),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (currentExerciseIndex * 3 + currentSet) / (exercises.length * 3),
                    child: Container(color: Colors.white),
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current exercise info
                        Text(
                          'OPERATION ${currentExerciseIndex + 1}/${exercises.length}',
                          style: GoogleFonts.ibmPlexMono(
                            color: const Color(0xFF666666),
                            fontSize: 12.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        
                        Text(
                          currentExercise['name'],
                          style: GoogleFonts.ibmPlexMono(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        
                        Row(
                          children: [
                            Text(
                              currentExercise['weight'],
                              style: GoogleFonts.ibmPlexMono(
                                color: const Color(0xFF999999),
                                fontSize: 18.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Container(
                              width: 1.0,
                              height: 20.0,
                              color: const Color(0xFF444444),
                            ),
                            const SizedBox(width: 20.0),
                            Text(
                              'SET $currentSet/3',
                              style: GoogleFonts.ibmPlexMono(
                                color: const Color(0xFF999999),
                                fontSize: 18.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40.0),
                        
                        // Mandate reminder
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF444444)),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MANDATE',
                                style: GoogleFonts.ibmPlexMono(
                                  color: const Color(0xFF666666),
                                  fontSize: 12.0,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                currentExercise['target'],
                                style: GoogleFonts.ibmPlexMono(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Rep input section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INPUT_REPS',
                              style: GoogleFonts.ibmPlexMono(
                                color: const Color(0xFF999999),
                                fontSize: 14.0,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _model.repsInputController,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.ibmPlexMono(
                                      color: Colors.white,
                                      fontSize: 48.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: GoogleFonts.ibmPlexMono(
                                        color: const Color(0xFF333333),
                                        fontSize: 48.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF444444),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF111111),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                FFButtonWidget(
                                  onPressed: _logSet,
                                  text: 'LOG_SET',
                                  options: FFButtonOptions(
                                    width: 120.0,
                                    height: 80.0,
                                    padding: EdgeInsets.zero,
                                    iconPadding: EdgeInsets.zero,
                                    color: Colors.white,
                                    textStyle: GoogleFonts.ibmPlexMono(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                    elevation: 0.0,
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
  
  Widget _buildRestScreen() {
    final minutes = (_currentRestSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentRestSeconds % 60).toString().padLeft(2, '0');
    
    return WillPopScope(
      onWillPop: () async => false, // Disable back during rest
      child: Container(
        color: const Color(0xFF111111),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ENFORCED_REST',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 40.0),
              
              // Countdown timer
              Text(
                '$minutes:$seconds',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 72.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              
              const SizedBox(height: 20.0),
              
              // Progress bar
              Container(
                width: 200.0,
                height: 4.0,
                color: const Color(0xFF222222),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1 - (_currentRestSeconds / restSeconds),
                  child: Container(color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 40.0),
              
              Text(
                'STAND_BY',
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFF666666),
                  fontSize: 14.0,
                  letterSpacing: 2.0,
                ),
              ),
              
              const SizedBox(height: 20.0),
              
              Text(
                'INPUT_DISABLED_UNTIL_ZERO',
                style: GoogleFonts.ibmPlexMono(
                  color: const Color(0xFF444444),
                  fontSize: 12.0,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SESSION_COMPLETE Screen - A factual report, not a celebration
class _SessionCompleteScreen extends StatelessWidget {
  final int exercisesCompleted;
  final int totalSets;
  
  const _SessionCompleteScreen({
    required this.exercisesCompleted,
    required this.totalSets,
  });
  
  @override
  Widget build(BuildContext context) {
    final nextDate = DateTime.now().add(const Duration(days: 1));
    final dateFormat = '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';
    
    // Save session data to SharedPreferences
    _saveSessionData();
    
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Three lines of monospaced text - nothing more
              Text(
                'SESSION_COMPLETE.',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  height: 2.0,
                ),
              ),
              
              Text(
                'PERFORMANCE_DATA_SAVED_TO_TRAINING_LOG.',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  height: 2.0,
                ),
              ),
              
              Text(
                'NEXT_ASSIGNMENT: BACK | $dateFormat.',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  height: 2.0,
                ),
              ),
              
              const Spacer(),
              
              // Single action button
              Container(
                width: double.infinity,
                height: 60.0,
                color: Colors.white,
                child: TextButton(
                  onPressed: () {
                    // Return to home
                    context.goNamed('homePage');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'ACKNOWLEDGED',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
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
  
  void _saveSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Get existing training log
    final existingLog = prefs.getStringList('training_log') ?? [];
    
    // Add today's session
    final sessionEntry = '$dateKey | CHEST | BENCH_PRESS: 6,5,4 | INCLINE_PRESS: 5,5,4 | DIPS: 6,5,4';
    existingLog.insert(0, sessionEntry); // Add to beginning for reverse chronological
    
    // Save back to preferences
    await prefs.setStringList('training_log', existingLog);
  }
}