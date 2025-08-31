import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'verification_page_model.dart';
export 'verification_page_model.dart';

class VerificationPageWidget extends StatefulWidget {
  const VerificationPageWidget({super.key});

  @override
  State<VerificationPageWidget> createState() => _VerificationPageWidgetState();
}

class _VerificationPageWidgetState extends State<VerificationPageWidget> {
  late VerificationPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerificationPageModel());
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
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wrapWithModel(
                  model: _model.appBarModel,
                  updateCallback: () => setState(() {}),
                  child: const AppBarWidget(
                    text: 'Verification',
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 38.0, 16.0, 0.0),
                  child: Text(
                    'Enter your email for the verification process. we will send 6 digits code to your email.',
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
                Align(
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                    child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Code sent to',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 17.0,
                                  useGoogleFonts: GoogleFonts.asMap()
                                      .containsKey(FlutterFlowTheme.of(context)
                                          .bodyMediumFamily),
                                ),
                          ),
                          TextSpan(
                            text: ' email',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.0,
                            ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 6,
                    textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          fontSize: 17.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              FlutterFlowTheme.of(context).bodyLargeFamily),
                        ),
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    enableActiveFill: false,
                    autoFocus: false,
                    enablePinAutofill: false,
                    errorTextSpace: 16.0,
                    showCursor: true,
                    cursorColor: FlutterFlowTheme.of(context).primary,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      fieldHeight: 50.0,
                      fieldWidth: 50.0,
                      borderWidth: 1.5,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                      shape: PinCodeFieldShape.box,
                      activeColor: FlutterFlowTheme.of(context).alternate,
                      inactiveColor: FlutterFlowTheme.of(context).alternate,
                      selectedColor: FlutterFlowTheme.of(context).primary,
                      activeFillColor: FlutterFlowTheme.of(context).alternate,
                      inactiveFillColor: FlutterFlowTheme.of(context).alternate,
                      selectedFillColor: FlutterFlowTheme.of(context).primary,
                    ),
                    controller: _model.pinCodeController,
                    onChanged: (_) {},
                    autovalidateMode: AutovalidateMode.disabled,
                    validator:
                        _model.pinCodeControllerValidator.asValidator(context),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 30.0, 16.0, 0.0),
                  child: wrapWithModel(
                    model: _model.appButtonModel,
                    updateCallback: () => setState(() {}),
                    child: AppButtonWidget(
                      title: 'Verify',
                      action: () async {
                        if (_model.formKey.currentState == null ||
                            !_model.formKey.currentState!.validate()) {
                          return;
                        }

                        context.pushNamed(
                          'resetPasswordPage',
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
      ),
    );
  }
}
