import '/flutter_flow/flutter_flow_util.dart';
import '/pages/calander_page/calander_page_widget.dart';
import '/pages/home_compnent/home_compnent_widget.dart';
import '/pages/profile_page/profile_page_widget.dart';
import '/pages/report_page/report_page_widget.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Model for homeCompnent component.
  late HomeCompnentModel homeCompnentModel;
  // Model for reportPage component.
  late ReportPageModel reportPageModel;
  // Model for calanderPage component.
  late CalanderPageModel calanderPageModel;
  // Model for profilePage component.
  late ProfilePageModel profilePageModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    homeCompnentModel = createModel(context, () => HomeCompnentModel());
    reportPageModel = createModel(context, () => ReportPageModel());
    calanderPageModel = createModel(context, () => CalanderPageModel());
    profilePageModel = createModel(context, () => ProfilePageModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    homeCompnentModel.dispose();
    reportPageModel.dispose();
    calanderPageModel.dispose();
    profilePageModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
