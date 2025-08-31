import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/empty_component/empty_component_widget.dart';
import 'calander_page_widget.dart' show CalanderPageWidget;
import 'package:flutter/material.dart';

class CalanderPageModel extends FlutterFlowModel<CalanderPageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for emptyComponent component.
  late EmptyComponentModel emptyComponentModel;
  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    emptyComponentModel = createModel(context, () => EmptyComponentModel());
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {
    emptyComponentModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
