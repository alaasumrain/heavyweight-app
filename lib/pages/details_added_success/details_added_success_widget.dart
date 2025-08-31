// ignore_for_file: use_build_context_synchronously

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'details_added_success_model.dart';
export 'details_added_success_model.dart';

class DetailsAddedSuccessWidget extends StatefulWidget {
  const DetailsAddedSuccessWidget({super.key});

  @override
  State<DetailsAddedSuccessWidget> createState() =>
      _DetailsAddedSuccessWidgetState();
}

class _DetailsAddedSuccessWidgetState extends State<DetailsAddedSuccessWidget> {
  late DetailsAddedSuccessModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetailsAddedSuccessModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 30.0, 16.0, 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120.0,
                height: 120.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F8EE),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Image.asset(
                      'assets/images/tick-mark_1.png',
                      width: 64.0,
                      height: 64.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 28.0, 0.0, 0.0),
                child: Text(
                  'Details added success',
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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 18.0, 0.0, 0.0),
                child: Text(
                  'You have successfully add your basic details\nplease go to home to continue journey',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        fontSize: 17.0,
                        useGoogleFonts: GoogleFonts.asMap().containsKey(
                            FlutterFlowTheme.of(context).bodyMediumFamily),
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(54.0, 28.0, 54.0, 0.0),
                child: wrapWithModel(
                  model: _model.appButtonModel,
                  updateCallback: () => setState(() {}),
                  child: AppButtonWidget(
                    title: 'Go to home',
                    action: () async {
                      await actions.setBasicDetails(
                        true,
                      );

                      context.goNamed(
                        'homePage',
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.rightToLeft,
                            duration: Duration(milliseconds: 300),
                          ),
                        },
                      );
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
