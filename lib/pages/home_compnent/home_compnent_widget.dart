import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_compnent_model.dart';
export 'home_compnent_model.dart';

class HomeCompnentWidget extends StatefulWidget {
  const HomeCompnentWidget({super.key});

  @override
  State<HomeCompnentWidget> createState() => _HomeCompnentWidgetState();
}

class _HomeCompnentWidgetState extends State<HomeCompnentWidget> {
  late HomeCompnentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeCompnentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  'ASSIGNMENT\nCHEST',
                  style: GoogleFonts.ibmPlexMono(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    border: Border.all(
                      color: const Color(0xFF444444),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY\'S_MANDATE',
                          style: GoogleFonts.ibmPlexMono(
                            color: const Color(0xFF666666),
                            fontSize: 12.0,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'CHEST',
                          style: GoogleFonts.ibmPlexMono(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '3 OPERATIONS | 9 SETS TOTAL',
                          style: GoogleFonts.ibmPlexMono(
                            color: const Color(0xFF999999),
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            border: Border.all(
                              color: const Color(0xFF333333),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOperationRow('01', 'BENCH PRESS', '100 KG', '4-6 REPS'),
                              const SizedBox(height: 12.0),
                              _buildOperationRow('02', 'INCLINE PRESS', '80 KG', '4-6 REPS'),
                              const SizedBox(height: 12.0),
                              _buildOperationRow('03', 'DIPS', 'BW+20 KG', '4-6 REPS'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // START SESSION BUTTON
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              'workoutDetailsPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.rightToLeft,
                                  duration: Duration(milliseconds: 300),
                                ),
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60.0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'START_SESSION',
                              style: GoogleFonts.ibmPlexMono(
                                color: Colors.black,
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
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        'LAST_SESSION',
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2025-08-30 | BACK',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'DEADLIFT: 5,5,4\nPULL UP: 6,5,5\nROW: 6,6,5',
                            style: GoogleFonts.ibmPlexMono(
                              color: const Color(0xFF999999),
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(right: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2025-08-29 | LEGS',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'SQUAT: 6,5,5\nLEG PRESS: 5,5,4\nRDL: 6,6,5',
                            style: GoogleFonts.ibmPlexMono(
                              color: const Color(0xFF999999),
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        'UPCOMING_ASSIGNMENTS',
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOMORROW',
                            style: GoogleFonts.ibmPlexMono(
                              color: const Color(0xFF666666),
                              fontSize: 12.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'SHOULDERS',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(right: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2025-09-02',
                            style: GoogleFonts.ibmPlexMono(
                              color: const Color(0xFF666666),
                              fontSize: 12.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'ARMS',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOperationRow(String number, String name, String weight, String reps) {
    return Row(
      children: [
        Text(
          number,
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFF666666),
            fontSize: 12.0,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          '$weight | $reps',
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFF999999),
            fontSize: 12.0,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}