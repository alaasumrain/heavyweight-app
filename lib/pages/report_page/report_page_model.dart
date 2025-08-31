import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/pages/empty_component/empty_component_widget.dart';
import 'report_page_widget.dart' show ReportPageWidget;
import 'package:flutter/material.dart';

class ReportPageModel extends FlutterFlowModel<ReportPageWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Model for emptyComponent component.
  late EmptyComponentModel emptyComponentModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    emptyComponentModel = createModel(context, () => EmptyComponentModel());
  }

  @override
  void dispose() {
    emptyComponentModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
