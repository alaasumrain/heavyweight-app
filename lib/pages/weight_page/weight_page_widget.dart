import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'weight_page_model.dart';
export 'weight_page_model.dart';

class WeightPageWidget extends StatefulWidget {
  const WeightPageWidget({super.key});

  @override
  State<WeightPageWidget> createState() => _WeightPageWidgetState();
}

class _WeightPageWidgetState extends State<WeightPageWidget> {
  late WeightPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeightPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
                  text: 'Weight',
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 0.0),
                child: Text(
                  'Select your weight',
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
                child: Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 300.0,
                    child: custom_widgets.ScaleIndicator(
                      width: double.infinity,
                      height: 300.0,
                      selectWeight: FFAppState().selectWeight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
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
