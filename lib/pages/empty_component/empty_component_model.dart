import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import 'empty_component_widget.dart' show EmptyComponentWidget;
import 'package:flutter/material.dart';

class EmptyComponentModel extends FlutterFlowModel<EmptyComponentWidget> {
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
