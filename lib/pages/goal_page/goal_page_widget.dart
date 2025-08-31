import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'goal_page_model.dart';
export 'goal_page_model.dart';

class GoalPageWidget extends StatefulWidget {
  const GoalPageWidget({super.key});

  @override
  State<GoalPageWidget> createState() => _GoalPageWidgetState();
}

class _GoalPageWidgetState extends State<GoalPageWidget> {
  late GoalPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoalPageModel());
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
              wrapWithModel(
                model: _model.appBarModel,
                updateCallback: () => setState(() {}),
                child: const AppBarWidget(
                  text: 'Goal',
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                child: Text(
                  'Select your goal',
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
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final goalsList = FFAppState().goalsList.toList();
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: goalsList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                        itemBuilder: (context, goalsListIndex) {
                          final goalsListItem = goalsList[goalsListIndex];
                          return InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              setState(() {
                                FFAppState().selectYourGoal = goalsListIndex;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FFAppState().selectYourGoal ==
                                        goalsListIndex
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).accent2,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        if (FFAppState().selectYourGoal !=
                                            goalsListIndex)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.network(
                                              goalsListItem.unselectImage,
                                              width: 24.0,
                                              height: 24.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (FFAppState().selectYourGoal ==
                                            goalsListIndex)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              goalsListItem.selectImage,
                                              width: 24.0,
                                              height: 24.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            8.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          goalsListItem.text,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color: FFAppState()
                                                            .selectYourGoal ==
                                                        goalsListIndex
                                                    ? const Color(0xFF131313)
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w600,
                                                useGoogleFonts: GoogleFonts
                                                        .asMap()
                                                    .containsKey(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        if (FFAppState().selectYourGoal ==
                                            goalsListIndex)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.network(
                                              goalsListItem.checkSelect,
                                              width: 24.0,
                                              height: 24.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (FFAppState().selectYourGoal !=
                                            goalsListIndex)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.network(
                                              goalsListItem.checkUnSelect,
                                              width: 24.0,
                                              height: 24.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                child: wrapWithModel(
                  model: _model.appButtonModel,
                  updateCallback: () => setState(() {}),
                  child: AppButtonWidget(
                    title: 'Continue',
                    action: () async {
                      context.safePop();
                    },
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
