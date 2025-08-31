import '/flutter_flow/flutter_flow_util.dart';
import 'splash_page_widget.dart' show SplashPageWidget;
import 'package:flutter/material.dart';

class SplashPageModel extends FlutterFlowModel<SplashPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Stores action output result for [Custom Action - getOnBoarding] action in splashPage widget.
  bool? onboardingAction;
  // Stores action output result for [Custom Action - getLogin] action in splashPage widget.
  bool? loginAction;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
