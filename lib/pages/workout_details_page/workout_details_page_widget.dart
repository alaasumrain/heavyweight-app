import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'workout_details_page_model.dart';
export 'workout_details_page_model.dart';

class WorkoutDetailsPageWidget extends StatefulWidget {
  const WorkoutDetailsPageWidget({super.key});

  @override
  State<WorkoutDetailsPageWidget> createState() =>
      _WorkoutDetailsPageWidgetState();
}

class _WorkoutDetailsPageWidgetState extends State<WorkoutDetailsPageWidget> {
  late WorkoutDetailsPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Session state
  int currentSet = 1;
  int currentExerciseIndex = 0;
  bool isResting = false;
  int restSeconds = 180;
  
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
  }

  @override
  void dispose() {
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
        // Start rest timer
      } else {
        // Move to next exercise
        if (currentExerciseIndex < exercises.length - 1) {
          currentExerciseIndex++;
          currentSet = 1;
          isResting = true;
        } else {
          // Session complete
          _completeSession();
        }
      }
      _model.repsInputController?.clear();
    });
  }
  
  void _completeSession() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'SESSION_COMPLETE',
          style: GoogleFonts.ibmPlexMono(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        content: Text(
          'PERFORMANCE_DATA_SAVED.',
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFF999999),
            fontSize: 14.0,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.safePop();
            },
            child: Text(
              'RETURN',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = exercises[currentExerciseIndex];
    
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'SESSION_ACTIVE',
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
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
    );
  }
  
  Widget _buildRestScreen() {
    // TODO: Implement enforced rest timer
    return Center(
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
          Text(
            '03:00',
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 72.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
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
        ],
      ),
    );
  }
}