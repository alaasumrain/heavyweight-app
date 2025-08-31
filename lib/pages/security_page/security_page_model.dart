import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import '/pages/security_component/security_component_widget.dart';
import 'security_page_widget.dart' show SecurityPageWidget;
import 'package:flutter/material.dart';

class SecurityPageModel extends FlutterFlowModel<SecurityPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for appBar component.
  late AppBarModel appBarModel;
  // Model for securityComponent component.
  late SecurityComponentModel securityComponentModel1;
  // Model for securityComponent component.
  late SecurityComponentModel securityComponentModel2;
  // Model for securityComponent component.
  late SecurityComponentModel securityComponentModel3;
  // Model for securityComponent component.
  late SecurityComponentModel securityComponentModel4;
  // Model for appButton component.
  late AppButtonModel appButtonModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    securityComponentModel1 =
        createModel(context, () => SecurityComponentModel());
    securityComponentModel2 =
        createModel(context, () => SecurityComponentModel());
    securityComponentModel3 =
        createModel(context, () => SecurityComponentModel());
    securityComponentModel4 =
        createModel(context, () => SecurityComponentModel());
    appButtonModel = createModel(context, () => AppButtonModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    appBarModel.dispose();
    securityComponentModel1.dispose();
    securityComponentModel2.dispose();
    securityComponentModel3.dispose();
    securityComponentModel4.dispose();
    appButtonModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
