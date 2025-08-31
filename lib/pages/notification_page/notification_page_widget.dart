import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/notification_common_component/notification_common_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'notification_page_model.dart';
export 'notification_page_model.dart';

class NotificationPageWidget extends StatefulWidget {
  const NotificationPageWidget({super.key});

  @override
  State<NotificationPageWidget> createState() => _NotificationPageWidgetState();
}

class _NotificationPageWidgetState extends State<NotificationPageWidget>
    with TickerProviderStateMixin {
  late NotificationPageModel _model;

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
    _model = createModel(context, () => NotificationPageModel());
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
                  text: 'Notifications',
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final notificationList =
                          FFAppState().notificationList.toList();
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          16.0,
                        ),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: notificationList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                        itemBuilder: (context, notificationListIndex) {
                          final notificationListItem =
                              notificationList[notificationListIndex];
                          return NotificationCommonComponentWidget(
                            key: Key(
                                'Keyuy7_${notificationListIndex}_of_${notificationList.length}'),
                            title: notificationListItem.title,
                            subTitle: notificationListItem.subTitle,
                            time: notificationListItem.time,
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
