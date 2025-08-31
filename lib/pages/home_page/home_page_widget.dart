import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/calander_page/calander_page_widget.dart';
import '/pages/home_compnent/home_compnent_widget.dart';
import '/pages/profile_page/profile_page_widget.dart';
import '/pages/report_page/report_page_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        setState(() {
          _isKeyboardVisible = visible;
        });
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: 500.0,
                child: PageView(
                  controller: _model.pageViewController ??=
                      PageController(initialPage: 0),
                  onPageChanged: (_) async {
                    setState(() {
                      FFAppState().selectPageIndex =
                          _model.pageViewCurrentIndex;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  children: [
                    wrapWithModel(
                      model: _model.homeCompnentModel,
                      updateCallback: () => setState(() {}),
                      child: const HomeCompnentWidget(),
                    ),
                    wrapWithModel(
                      model: _model.reportPageModel,
                      updateCallback: () => setState(() {}),
                      child: const ReportPageWidget(),
                    ),
                    wrapWithModel(
                      model: _model.calanderPageModel,
                      updateCallback: () => setState(() {}),
                      child: const CalanderPageWidget(),
                    ),
                    wrapWithModel(
                      model: _model.profilePageModel,
                      updateCallback: () => setState(() {}),
                      child: const ProfilePageWidget(),
                    ),
                  ],
                ),
              ),
            ),
            if (!(isWeb
                ? MediaQuery.viewInsetsOf(context).bottom > 0
                : _isKeyboardVisible))
              Container(
                width: double.infinity,
                height: 95.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 26.0,
                      color: Color(0x14959595),
                      offset: Offset(0.0, -4.0),
                      spreadRadius: 0.0,
                    )
                  ],
                ),
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          setState(() {
                            FFAppState().selectPageIndex = 0;
                          });
                          await _model.pageViewController?.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Container(
                          width: 59.0,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 4.0, 0.0, 0.0),
                                child: Stack(
                                  children: [
                                    if (FFAppState().selectPageIndex == 0)
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(0.0, -1.0),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 7.0),
                                          child: Container(
                                            width: 59.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313926),
                                              borderRadius:
                                                  BorderRadius.circular(170.0),
                                            ),
                                            child: Visibility(
                                              visible: FFAppState()
                                                      .selectPageIndex ==
                                                  0,
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        17.0, 4.0, 17.0, 4.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                  child: Image.asset(
                                                    'assets/images/home-2.png',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (FFAppState().selectPageIndex != 0)
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(0.0, -1.0),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 7.0),
                                          child: Container(
                                            width: 59.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(170.0),
                                            ),
                                            child: Visibility(
                                              visible: FFAppState()
                                                      .selectPageIndex !=
                                                  0,
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        17.0, 4.0, 17.0, 4.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                  child: Image.asset(
                                                    'assets/images/homeUnselect.png',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                'ASSIGNMENT',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: valueOrDefault<Color>(
                                        FFAppState().selectPageIndex == 0
                                            ? FlutterFlowTheme.of(context)
                                                .primary
                                            : const Color(0xFF696969),
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          setState(() {
                            FFAppState().selectPageIndex = 1;
                          });
                          await _model.pageViewController?.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  if (FFAppState().selectPageIndex == 1)
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(0.0, -1.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 7.0),
                                        child: Container(
                                          width: 59.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF313926),
                                            borderRadius:
                                                BorderRadius.circular(120.0),
                                          ),
                                          alignment:
                                              const AlignmentDirectional(0.0, 0.0),
                                          child: Visibility(
                                            visible:
                                                FFAppState().selectPageIndex ==
                                                    1,
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      17.0, 4.0, 17.0, 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/reportSelect.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (FFAppState().selectPageIndex != 1)
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(0.0, -1.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 7.0),
                                        child: Container(
                                          width: 59.0,
                                          height: 32.0,
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Visibility(
                                            visible:
                                                FFAppState().selectPageIndex !=
                                                    1,
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      17.0, 4.0, 17.0, 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/reportUnselect.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                'TRAINING_LOG',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FFAppState().selectPageIndex == 1
                                          ? FlutterFlowTheme.of(context).primary
                                          : const Color(0xFF696969),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          setState(() {
                            FFAppState().selectPageIndex = 2;
                          });
                          await _model.pageViewController?.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  if (FFAppState().selectPageIndex == 2)
                                    Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 7.0),
                                        child: Container(
                                          width: 59.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF313926),
                                            borderRadius:
                                                BorderRadius.circular(120.0),
                                          ),
                                          alignment:
                                              const AlignmentDirectional(0.0, 0.0),
                                          child: Visibility(
                                            visible:
                                                FFAppState().selectPageIndex ==
                                                    2,
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      17.0, 4.0, 17.0, 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/calanderSelect.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (FFAppState().selectPageIndex != 2)
                                    Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 7.0),
                                        child: Container(
                                          width: 59.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(170.0),
                                          ),
                                          child: Visibility(
                                            visible:
                                                FFAppState().selectPageIndex !=
                                                    2,
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      17.0, 4.0, 17.0, 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/calendar.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                'SCHEDULE',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FFAppState().selectPageIndex == 2
                                          ? FlutterFlowTheme.of(context).primary
                                          : const Color(0xFF696969),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          setState(() {
                            FFAppState().selectPageIndex = 3;
                          });
                          await _model.pageViewController?.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  if (FFAppState().selectPageIndex == 3)
                                    Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 7.0),
                                        child: Container(
                                          width: 59.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF313926),
                                            borderRadius:
                                                BorderRadius.circular(170.0),
                                          ),
                                          child: Visibility(
                                            visible:
                                                FFAppState().selectPageIndex ==
                                                    3,
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      17.0, 4.0, 17.0, 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/frame.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (FFAppState().selectPageIndex != 3)
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(0.0, -1.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 7.0),
                                        child: Container(
                                          width: 59.0,
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(170.0),
                                          ),
                                          child: Visibility(
                                            visible:
                                                FFAppState().selectPageIndex !=
                                                    3,
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      17.0, 4.0, 17.0, 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/prodileUnselect.png',
                                                  width: 24.0,
                                                  height: 24.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                'SYSTEM_SETTINGS',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FFAppState().selectPageIndex == 3
                                          ? FlutterFlowTheme.of(context).primary
                                          : const Color(0xFF696969),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
