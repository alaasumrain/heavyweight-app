import '/flutter_flow/flutter_flow_util.dart';
import '/pages/profile_component/profile_component_widget.dart';
import 'profile_page_widget.dart' show ProfilePageWidget;
import 'package:flutter/material.dart';

class ProfilePageModel extends FlutterFlowModel<ProfilePageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel1;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel2;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel3;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel4;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel5;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    profileComponentModel1 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel2 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel3 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel4 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel5 =
        createModel(context, () => ProfileComponentModel());
  }

  @override
  void dispose() {
    profileComponentModel1.dispose();
    profileComponentModel2.dispose();
    profileComponentModel3.dispose();
    profileComponentModel4.dispose();
    profileComponentModel5.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
