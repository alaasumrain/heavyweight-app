import 'package:carousel_slider/carousel_slider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'age_page_model.dart';
export 'age_page_model.dart';

class AgePageWidget extends StatefulWidget {
  const AgePageWidget({super.key});

  @override
  State<AgePageWidget> createState() => _AgePageWidgetState();
}

class _AgePageWidgetState extends State<AgePageWidget> {
  late AgePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgePageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              wrapWithModel(
                model: _model.appBarModel,
                updateCallback: () => setState(() {}),
                child: const AppBarWidget(
                  text: 'Age',
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Text(
                  'Select your age',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts: GoogleFonts.asMap().containsKey(
                            FlutterFlowTheme.of(context).bodyMediumFamily),
                      ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 20.0),
                  child: Stack(
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Container(
                          width: 285.0,
                          height: 160.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(48.0),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          child: Builder(
                            builder: (context) {
                              final ageList =
                                  functions.ageList()?.toList() ?? [];
                              return SizedBox(
                                width: double.infinity,
                                height: 600.0,
                                child: CarouselSlider.builder(
                                  itemCount: ageList.length,
                                  itemBuilder: (context, ageListIndex, _) {
                                    final ageListItem = ageList[ageListIndex];
                                    return Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                const AlignmentDirectional(0.0, 0.0),
                                            child: AutoSizeText(
                                              ageListItem,
                                              maxLines: 1,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: ageListIndex ==
                                                            _model
                                                                .carouselCurrentIndex
                                                        ? const Color(0xFF131313)
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                    fontSize: ageListIndex ==
                                                            _model
                                                                .carouselCurrentIndex
                                                        ? 110.0
                                                        : 60.0,
                                                    fontWeight: FontWeight.w800,
                                                    useGoogleFonts: GoogleFonts
                                                            .asMap()
                                                        .containsKey(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        if (ageListIndex ==
                                            _model.carouselCurrentIndex)
                                          Flexible(
                                            child: Text(
                                              'Years',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: const Color(0xFF131313),
                                                    fontSize: 30.0,
                                                    fontWeight: FontWeight.w500,
                                                    useGoogleFonts: GoogleFonts
                                                            .asMap()
                                                        .containsKey(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily),
                                                  ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                  carouselController:
                                      CarouselSliderController(),


                                  options: CarouselOptions(
                                    initialPage: min(25, ageList.length - 1),
                                    viewportFraction: 0.3,
                                    disableCenter: false,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.2,
                                    enableInfiniteScroll: true,
                                    scrollDirection: Axis.vertical,
                                    autoPlay: false,
                                    onPageChanged: (index, _) async {
                                      _model.carouselCurrentIndex = index;
                                      setState(() {
                                        FFAppState().updatePageAge =
                                            _model.carouselCurrentIndex;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 24.0),
                child: wrapWithModel(
                  model: _model.appButtonModel,
                  updateCallback: () => setState(() {}),
                  child: AppButtonWidget(
                    title: 'Continue',
                    action: () async {
                      context.safePop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
