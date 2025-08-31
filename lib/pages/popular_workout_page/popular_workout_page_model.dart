import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import 'popular_workout_page_widget.dart' show PopularWorkoutPageWidget;
import 'package:flutter/material.dart';

class PopularWorkoutPageModel
    extends FlutterFlowModel<PopularWorkoutPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for appBar component.
  late AppBarModel appBarModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    appBarModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
