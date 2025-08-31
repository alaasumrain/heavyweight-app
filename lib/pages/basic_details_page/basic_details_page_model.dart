import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import '/pages/basic_details_component/basic_details_component_widget.dart';
import 'basic_details_page_widget.dart' show BasicDetailsPageWidget;
import 'package:flutter/material.dart';

class BasicDetailsPageModel extends FlutterFlowModel<BasicDetailsPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for basicDetailsComponent component.
  late BasicDetailsComponentModel basicDetailsComponentModel1;
  // Model for basicDetailsComponent component.
  late BasicDetailsComponentModel basicDetailsComponentModel2;
  // Model for basicDetailsComponent component.
  late BasicDetailsComponentModel basicDetailsComponentModel3;
  // Model for basicDetailsComponent component.
  late BasicDetailsComponentModel basicDetailsComponentModel4;
  // Model for basicDetailsComponent component.
  late BasicDetailsComponentModel basicDetailsComponentModel5;
  // Model for appButton component.
  late AppButtonModel appButtonModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    basicDetailsComponentModel1 =
        createModel(context, () => BasicDetailsComponentModel());
    basicDetailsComponentModel2 =
        createModel(context, () => BasicDetailsComponentModel());
    basicDetailsComponentModel3 =
        createModel(context, () => BasicDetailsComponentModel());
    basicDetailsComponentModel4 =
        createModel(context, () => BasicDetailsComponentModel());
    basicDetailsComponentModel5 =
        createModel(context, () => BasicDetailsComponentModel());
    appButtonModel = createModel(context, () => AppButtonModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    basicDetailsComponentModel1.dispose();
    basicDetailsComponentModel2.dispose();
    basicDetailsComponentModel3.dispose();
    basicDetailsComponentModel4.dispose();
    basicDetailsComponentModel5.dispose();
    appButtonModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
