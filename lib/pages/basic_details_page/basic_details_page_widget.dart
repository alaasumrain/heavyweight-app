// ignore_for_file: null_check_always_fails

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import '/pages/basic_details_component/basic_details_component_widget.dart';
import '/pages/details_added_success/details_added_success_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'basic_details_page_model.dart';
export 'basic_details_page_model.dart';

class BasicDetailsPageWidget extends StatefulWidget {
  const BasicDetailsPageWidget({super.key});

  @override
  State<BasicDetailsPageWidget> createState() => _BasicDetailsPageWidgetState();
}

class _BasicDetailsPageWidgetState extends State<BasicDetailsPageWidget> {
  late BasicDetailsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BasicDetailsPageModel());
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: Text(
                  'Basic details',
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Rubik',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts:
                            GoogleFonts.asMap().containsKey('Rubik'),
                      ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 38.0, 0.0, 0.0),
                        child: Text(
                          'Please tell about yourself',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: GoogleFonts.asMap().containsKey(
                                    FlutterFlowTheme.of(context)
                                        .bodyMediumFamily),
                              ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 34.0, 0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.basicDetailsComponentModel1,
                          updateCallback: () => setState(() {}),
                          child: BasicDetailsComponentWidget(
                            title: 'Select your gender',
                            subTitle: FFAppState().genderList.isNotEmpty
                                ? FFAppState()
                                    .genderList[FFAppState().gender]
                                    .text
                                : null!,
                            action: () async {
                              context.pushNamed(
                                'genderPage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 300),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 26.0, 0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.basicDetailsComponentModel2,
                          updateCallback: () => setState(() {}),
                          child: BasicDetailsComponentWidget(
                            title: 'Choose your age',
                            subTitle: functions.ageList() != null &&
                                    (functions.ageList())!.isNotEmpty
                                ? (functions
                                    .ageList()![FFAppState().updatePageAge])
                                : null!,
                            action: () async {
                              context.pushNamed(
                                'agePage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 300),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 26.0, 0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.basicDetailsComponentModel3,
                          updateCallback: () => setState(() {}),
                          child: BasicDetailsComponentWidget(
                            title: 'Select your weight',
                            subTitle: '40',
                            action: () async {
                              context.pushNamed(
                                'weightPage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 300),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 26.0, 0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.basicDetailsComponentModel4,
                          updateCallback: () => setState(() {}),
                          child: BasicDetailsComponentWidget(
                            title: 'Select your height',
                            subTitle: functions.heightList() != null &&
                                    (functions.heightList())!.isNotEmpty
                                ? (functions
                                    .heightList()![FFAppState().updateHeight])
                                : null!,
                            action: () async {
                              context.pushNamed(
                                'heightPage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 300),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 26.0, 0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.basicDetailsComponentModel5,
                          updateCallback: () => setState(() {}),
                          child: BasicDetailsComponentWidget(
                            title: 'Select your goal',
                            subTitle: FFAppState().goalsList.isNotEmpty
                                ? FFAppState()
                                    .goalsList[FFAppState().selectYourGoal]
                                    .text
                                : null!,
                            action: () async {
                              context.pushNamed(
                                'goalPage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey: const TransitionInfo(
                                    hasTransition: true,
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 300),
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) => Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                  child: wrapWithModel(
                    model: _model.appButtonModel,
                    updateCallback: () => setState(() {}),
                    child: AppButtonWidget(
                      title: 'Continue',
                      action: () async {
                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              elevation: 0,
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              alignment: const AlignmentDirectional(0.0, 0.0)
                                  .resolve(Directionality.of(context)),
                              child: GestureDetector(
                                onTap: () => _model.unfocusNode.canRequestFocus
                                    ? FocusScope.of(context)
                                        .requestFocus(_model.unfocusNode)
                                    : FocusScope.of(context).unfocus(),
                                child: const DetailsAddedSuccessWidget(),
                              ),
                            );
                          },
                        ).then((value) => setState(() {}));
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
