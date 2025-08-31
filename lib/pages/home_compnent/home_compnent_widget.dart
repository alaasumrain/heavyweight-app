import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts: GoogleFonts.asMap().containsKey(
                            FlutterFlowTheme.of(context).bodyMediumFamily),
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              0,
              0,
              0,
              20.0,
            ),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent2,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TODAY\'S_MANDATE\n4 OPERATIONS',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          fontSize: 18.0,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey(
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily),
                                          lineHeight: 1.7,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 0.0),
                                    child: Text(
                                      'CHEST DAY',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 15.0,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey(
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircularPercentIndicator(
                              percent: 0.0,
                              radius: 50.0,
                              lineWidth: 5.0,
                              animation: true,
                              animateFromLastPercent: true,
                              progressColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              backgroundColor:
                                  FlutterFlowTheme.of(context).alternate,
                              center: Text(
                                '0/4\nSETS',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .headlineSmallFamily,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.normal,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmallFamily),
                                      lineHeight: 1.3,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 31.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BENCH PRESS',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 17.0,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey(
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily),
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Text(
                                        '100 KG | 4-6 REPS',
                                        maxLines: 2,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 15.0,
                                              useGoogleFonts: GoogleFonts
                                                      .asMap()
                                                  .containsKey(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily),
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: LinearPercentIndicator(
                                        percent: 0.0,
                                        width: 100.0,
                                        lineHeight: 6.0,
                                        animation: true,
                                        animateFromLastPercent: true,
                                        progressColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        barRadius: const Radius.circular(0.0),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INCLINE PRESS',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 17.0,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey(
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily),
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Text(
                                        '80 KG | 4-6 REPS',
                                        maxLines: 2,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 15.0,
                                              useGoogleFonts: GoogleFonts
                                                      .asMap()
                                                  .containsKey(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily),
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: LinearPercentIndicator(
                                        percent: 0.0,
                                        width: 100.0,
                                        lineHeight: 6.0,
                                        animation: true,
                                        animateFromLastPercent: true,
                                        progressColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        barRadius: const Radius.circular(0.0),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DIPS',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 17.0,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey(
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily),
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Text(
                                        'BW+20 | 4-6 REPS',
                                        maxLines: 2,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 15.0,
                                              useGoogleFonts: GoogleFonts
                                                      .asMap()
                                                  .containsKey(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily),
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: LinearPercentIndicator(
                                        percent: 0.0,
                                        width: 100.0,
                                        lineHeight: 6.0,
                                        animation: true,
                                        animateFromLastPercent: true,
                                        progressColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        barRadius: const Radius.circular(0.0),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ].divide(const SizedBox(width: 15.0)),
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
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                            ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          'todayWorkoutPlanPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.rightToLeft,
                              duration: Duration(milliseconds: 300),
                            ),
                          },
                        );
                      },
                      child: Text(
                        'VIEW LOG',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 15.0,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Pure text session history
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent2,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2025-08-30 | BACK',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'DEADLIFT: 5,5,4',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                            Text(
                              'PULL UP: 6,5,5',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent2,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2025-08-29 | LEGS',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'SQUAT: 6,5,5',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                            Text(
                              'LEG PRESS: 5,5,4',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                        .divide(const SizedBox(width: 16.0))
                        .addToStart(const SizedBox(width: 16.0))
                        .addToEnd(const SizedBox(width: 16.0)),
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
                        'UPCOMING_ASSIGNMENTS',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                            ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          'popularWorkoutPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.rightToLeft,
                              duration: Duration(milliseconds: 300),
                            ),
                          },
                        );
                      },
                      child: Text(
                        'SCHEDULE',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 15.0,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Pure text upcoming schedule
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent2,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOMORROW',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'SHOULDERS',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent2,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2025-09-02',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 12.0,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'ARMS',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context).bodyMediumFamily),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                        .divide(const SizedBox(width: 16.0))
                        .addToStart(const SizedBox(width: 16.0))
                        .addToEnd(const SizedBox(width: 16.0)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}