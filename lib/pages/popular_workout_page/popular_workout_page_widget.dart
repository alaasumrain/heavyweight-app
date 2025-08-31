import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/popular_workout_component/popular_workout_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'popular_workout_page_model.dart';
export 'popular_workout_page_model.dart';

class PopularWorkoutPageWidget extends StatefulWidget {
  const PopularWorkoutPageWidget({super.key});

  @override
  State<PopularWorkoutPageWidget> createState() =>
      _PopularWorkoutPageWidgetState();
}

class _PopularWorkoutPageWidgetState extends State<PopularWorkoutPageWidget>
    with TickerProviderStateMixin {
  late PopularWorkoutPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'gridViewOnPageLoadAnimation': AnimationInfo(
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
    _model = createModel(context, () => PopularWorkoutPageModel());
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
                  text: 'Popular workout',
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final popularWokoutList =
                          FFAppState().popularWorkoutList.toList();
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          16.0,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 2;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 4;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 6;
                            } else {
                              return 6;
                            }
                          }(),
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                        ),
                        scrollDirection: Axis.vertical,
                        itemCount: popularWokoutList.length,
                        itemBuilder: (context, popularWokoutListIndex) {
                          final popularWokoutListItem =
                              popularWokoutList[popularWokoutListIndex];
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
                            child: PopularWorkoutComponentWidget(
                              key: Key(
                                  'Keym2o_${popularWokoutListIndex}_of_${popularWokoutList.length}'),
                              image: popularWokoutListItem.image,
                              title: popularWokoutListItem.title,
                              time: popularWokoutListItem.time,
                              rating: popularWokoutListItem.rating,
                            ),
                          );
                        },
                      ).animateOnPageLoad(
                          animationsMap['gridViewOnPageLoadAnimation']!);
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
