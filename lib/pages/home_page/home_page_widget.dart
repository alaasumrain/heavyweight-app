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
                height: 60.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF333333),
                      width: 1.0,
                    ),
                  ),
                ),
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: FFAppState().selectPageIndex == 0
                                ? const Color(0xFF1A1A1A)
                                : Colors.transparent,
                            border: FFAppState().selectPageIndex == 0
                                ? const Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ASSIGNMENT',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: FFAppState().selectPageIndex == 0
                                  ? Colors.white
                                  : const Color(0xFF666666),
                              fontSize: 11.0,
                              fontWeight: FFAppState().selectPageIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 1.0,
                            ),
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
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: FFAppState().selectPageIndex == 1
                                ? const Color(0xFF1A1A1A)
                                : Colors.transparent,
                            border: FFAppState().selectPageIndex == 1
                                ? const Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'TRAINING_LOG',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: FFAppState().selectPageIndex == 1
                                  ? Colors.white
                                  : const Color(0xFF666666),
                              fontSize: 11.0,
                              fontWeight: FFAppState().selectPageIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 1.0,
                            ),
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
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: FFAppState().selectPageIndex == 2
                                ? const Color(0xFF1A1A1A)
                                : Colors.transparent,
                            border: FFAppState().selectPageIndex == 2
                                ? const Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'SCHEDULE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: FFAppState().selectPageIndex == 2
                                  ? Colors.white
                                  : const Color(0xFF666666),
                              fontSize: 11.0,
                              fontWeight: FFAppState().selectPageIndex == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 1.0,
                            ),
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
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: FFAppState().selectPageIndex == 3
                                ? const Color(0xFF1A1A1A)
                                : Colors.transparent,
                            border: FFAppState().selectPageIndex == 3
                                ? const Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'SETTINGS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: FFAppState().selectPageIndex == 3
                                  ? Colors.white
                                  : const Color(0xFF666666),
                              fontSize: 11.0,
                              fontWeight: FFAppState().selectPageIndex == 3
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 1.0,
                            ),
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
