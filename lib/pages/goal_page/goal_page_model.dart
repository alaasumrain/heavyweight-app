import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import 'goal_page_widget.dart' show GoalPageWidget;
import 'package:flutter/material.dart';

class GoalPageModel extends FlutterFlowModel<GoalPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for appBar component.
  late AppBarModel appBarModel;
  // Model for appButton component.
  late AppButtonModel appButtonModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    appButtonModel = createModel(context, () => AppButtonModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    appBarModel.dispose();
    appButtonModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
