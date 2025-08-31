import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import 'details_added_success_widget.dart' show DetailsAddedSuccessWidget;
import 'package:flutter/material.dart';

class DetailsAddedSuccessModel
    extends FlutterFlowModel<DetailsAddedSuccessWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for appButton component.
  late AppButtonModel appButtonModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appButtonModel = createModel(context, () => AppButtonModel());
  }

  @override
  void dispose() {
    appButtonModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
