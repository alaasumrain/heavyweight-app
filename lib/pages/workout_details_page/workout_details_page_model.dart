import '/flutter_flow/flutter_flow_util.dart';
import 'workout_details_page_widget.dart' show WorkoutDetailsPageWidget;
import 'package:flutter/material.dart';

class WorkoutDetailsPageModel
    extends FlutterFlowModel<WorkoutDetailsPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  
  // Text controller for rep input
  TextEditingController? repsInputController;
  String? Function(BuildContext, String?)? repsInputControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    // Initialize without app button
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    repsInputController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
