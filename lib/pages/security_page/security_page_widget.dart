import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import '/pages/security_component/security_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'security_page_model.dart';
export 'security_page_model.dart';

class SecurityPageWidget extends StatefulWidget {
  const SecurityPageWidget({super.key});

  @override
  State<SecurityPageWidget> createState() => _SecurityPageWidgetState();
}

class _SecurityPageWidgetState extends State<SecurityPageWidget>
    with TickerProviderStateMixin {
  late SecurityPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'columnOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 50.ms,
          duration: 400.ms,
          begin: 0.15,
          end: 1.0,
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SecurityPageModel());
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
                  text: 'Security',
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.securityComponentModel1,
                        updateCallback: () => setState(() {}),
                        child: SecurityComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/oklze3iz9669/2_factor.png',
                          text: '2 Factor authenticator',
                          isTrue: true,
                          action: () async {},
                        ),
                      ),
                      wrapWithModel(
                        model: _model.securityComponentModel2,
                        updateCallback: () => setState(() {}),
                        child: SecurityComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/cekzg7k78ak1/Google_Authenticator.png',
                          text: 'Google authenticator',
                          isTrue: true,
                          action: () async {},
                        ),
                      ),
                      wrapWithModel(
                        model: _model.securityComponentModel3,
                        updateCallback: () => setState(() {}),
                        child: SecurityComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/1uyoadbn5uv0/face_id.png',
                          text: 'Face ID',
                          isTrue: false,
                          action: () async {},
                        ),
                      ),
                      wrapWithModel(
                        model: _model.securityComponentModel4,
                        updateCallback: () => setState(() {}),
                        child: SecurityComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/5yd38yjhm9of/fingerprint-scan_1.png',
                          text: 'Biometric unlock',
                          isTrue: true,
                          action: () async {},
                        ),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ).animateOnPageLoad(
                      animationsMap['columnOnPageLoadAnimation']!),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                child: wrapWithModel(
                  model: _model.appButtonModel,
                  updateCallback: () => setState(() {}),
                  child: AppButtonWidget(
                    title: 'Save Settings',
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
