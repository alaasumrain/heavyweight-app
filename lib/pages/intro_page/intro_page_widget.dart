// ignore_for_file: use_build_context_synchronously

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'intro_page_model.dart';
export 'intro_page_model.dart';

class IntroPageWidget extends StatefulWidget {
  const IntroPageWidget({super.key});

  @override
  State<IntroPageWidget> createState() => _IntroPageWidgetState();
}

class _IntroPageWidgetState extends State<IntroPageWidget>
    with TickerProviderStateMixin {
  late IntroPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'imageOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IntroPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

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
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Container(
                  width: 511.0,
                  height: 974.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 500.0,
                    child: Stack(
                      children: [
                        PageView(
                          controller: _model.pageViewController ??=
                              PageController(initialPage: 0),
                          onPageChanged: (_) async {
                            setState(() {
                              FFAppState().introIndex =
                                  _model.pageViewCurrentIndex;
                            });
                          },
                          scrollDirection: Axis.horizontal,
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(0.0),
                                    child: Image.asset(
                                      'assets/images/introOne.png',
                                      width: 578.0,
                                      height: 964.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ).animateOnPageLoad(animationsMap[
                                      'imageOnPageLoadAnimation']!),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(-0.01, 0.21),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: AutoSizeText(
                                      'Improve your overall health \nand wellbeing with us',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Rubik',
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey('Rubik'),
                                          ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.39),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: AutoSizeText(
                                      'Shape up and stand out achieve your fitness goals and turn heads',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Rubik',
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 17.0,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey('Rubik'),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: Image.asset(
                                    'assets/images/introTwo.png',
                                    width: 584.0,
                                    height: 976.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.09, 0.2),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: AutoSizeText(
                                      'Unleash your potential with\nthese fitness tips',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Rubik',
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey('Rubik'),
                                          ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.39),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: AutoSizeText(
                                      'Uncover your fitness potential with expert \nguidance with us',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Rubik',
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.normal,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey('Rubik'),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: Image.asset(
                                    'assets/images/introthree.png',
                                    width: 667.0,
                                    height: 974.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.23),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: AutoSizeText(
                                      'Push your limits and crush\nyour fitness plateaus',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Rubik',
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey('Rubik'),
                                          ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.41),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: AutoSizeText(
                                      'Simple steps to incorporate exercise into \nyour daily life',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Rubik',
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 17.0,
                                            useGoogleFonts: GoogleFonts.asMap()
                                                .containsKey('Rubik'),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 165.0),
                            child: smooth_page_indicator.SmoothPageIndicator(
                              controller: _model.pageViewController ??=
                                  PageController(initialPage: 0),
                              count: 3,
                              axisDirection: Axis.horizontal,
                              onDotClicked: (i) async {
                                await _model.pageViewController!.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              effect: smooth_page_indicator.ExpandingDotsEffect(
                                expansionFactor: 3.0,
                                spacing: 6.0,
                                radius: 22.0,
                                dotWidth: 6.0,
                                dotHeight: 7.0,
                                dotColor: const Color(0x4CA2ED3A),
                                activeDotColor:
                                    FlutterFlowTheme.of(context).primary,
                                paintStyle: PaintingStyle.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: _model.pageViewCurrentIndex == 2 ? 0.0 : 1.0,
                child: Align(
                  alignment: const AlignmentDirectional(0.01, 0.91),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await actions.setOnBoarding(
                        true,
                      );

                      context.goNamed(
                        'loginPage',
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
                      'Skip',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Rubik',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 17.0,
                            useGoogleFonts:
                                GoogleFonts.asMap().containsKey('Rubik'),
                          ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.78),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: wrapWithModel(
                    model: _model.appButtonModel,
                    updateCallback: () => setState(() {}),
                    child: AppButtonWidget(
                      title:
                          FFAppState().introIndex == 2 ? 'Get started' : 'Next',
                      action: () async {
                        if (FFAppState().introIndex == 2) {
                          await actions.setOnBoarding(
                            true,
                          );

                          context.goNamed(
                            'loginPage',
                            extra: <String, dynamic>{
                              kTransitionInfoKey: const TransitionInfo(
                                hasTransition: true,
                                transitionType: PageTransitionType.rightToLeft,
                                duration: Duration(milliseconds: 300),
                              ),
                            },
                          );
                        } else {
                          await _model.pageViewController?.animateToPage(
                            FFAppState().introIndex + 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
                      },
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
}
