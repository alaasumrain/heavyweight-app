import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import 'height_page_widget.dart' show HeightPageWidget;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HeightPageModel extends FlutterFlowModel<HeightPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for appBar component.
  late AppBarModel appBarModel;
  // State field(s) for Carousel widget.
  late CarouselScrollPhysics carouselController;

  int carouselCurrentIndex = 25;

  // Model for appButton component.
  late AppButtonModel appButtonModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    appButtonModel = createModel(context, () => AppButtonModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    appBarModel.dispose();
    appButtonModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
