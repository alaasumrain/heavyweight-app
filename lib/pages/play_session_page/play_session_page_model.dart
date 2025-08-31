import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'play_session_page_widget.dart' show PlaySessionPageWidget;
import 'package:flutter/material.dart';

class PlaySessionPageModel extends FlutterFlowModel<PlaySessionPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for appBar component.
  late AppBarModel appBarModel;
  // State field(s) for Timer widget.
  int timerMilliseconds = 1250000;
  String timerValue = StopWatchTimer.getDisplayTime(
    1250000,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    appBarModel.dispose();
    timerController.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
