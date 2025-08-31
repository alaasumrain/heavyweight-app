import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/recent_workout_component/recent_workout_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'recent_workout_page_model.dart';
export 'recent_workout_page_model.dart';

class RecentWorkoutPageWidget extends StatefulWidget {
  const RecentWorkoutPageWidget({super.key});

  @override
  State<RecentWorkoutPageWidget> createState() =>
      _RecentWorkoutPageWidgetState();
}

class _RecentWorkoutPageWidgetState extends State<RecentWorkoutPageWidget>
    with TickerProviderStateMixin {
  late RecentWorkoutPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'listViewOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 50.ms,
          duration: 400.ms,
          begin: 0.15,
          end: 1.0,
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecentWorkoutPageModel());
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
                  text: 'Recent workout',
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final recentWorkoutList =
                          FFAppState().recentWorkout.toList();
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          16.0,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: recentWorkoutList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                        itemBuilder: (context, recentWorkoutListIndex) {
                          final recentWorkoutListItem =
                              recentWorkoutList[recentWorkoutListIndex];
                          return InkWell(
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
                                    transitionType:
                                        PageTransitionType.rightToLeft,
                                    duration: Duration(milliseconds: 300),
                                  ),
                                },
                              );
                            },
                            child: RecentWorkoutComponentWidget(
                              key: Key(
                                  'Keysk7_${recentWorkoutListIndex}_of_${recentWorkoutList.length}'),
                              title: recentWorkoutListItem.title,
                              subTitle: recentWorkoutListItem.subText,
                              time: recentWorkoutListItem.time,
                            ),
                          );
                        },
                      ).animateOnPageLoad(
                          animationsMap['listViewOnPageLoadAnimation']!);
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
