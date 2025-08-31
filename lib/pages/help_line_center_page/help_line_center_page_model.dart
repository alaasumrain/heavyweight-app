import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/profile_component/profile_component_widget.dart';
import 'help_line_center_page_widget.dart' show HelpLineCenterPageWidget;
import 'package:flutter/material.dart';

class HelpLineCenterPageModel
    extends FlutterFlowModel<HelpLineCenterPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for appBar component.
  late AppBarModel appBarModel;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel1;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel2;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel3;
  // Model for profileComponent component.
  late ProfileComponentModel profileComponentModel4;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    profileComponentModel1 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel2 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel3 =
        createModel(context, () => ProfileComponentModel());
    profileComponentModel4 =
        createModel(context, () => ProfileComponentModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    appBarModel.dispose();
    profileComponentModel1.dispose();
    profileComponentModel2.dispose();
    profileComponentModel3.dispose();
    profileComponentModel4.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
