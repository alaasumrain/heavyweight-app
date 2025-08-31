import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/profile_component/profile_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'help_line_center_page_model.dart';
export 'help_line_center_page_model.dart';

class HelpLineCenterPageWidget extends StatefulWidget {
  const HelpLineCenterPageWidget({super.key});

  @override
  State<HelpLineCenterPageWidget> createState() =>
      _HelpLineCenterPageWidgetState();
}

class _HelpLineCenterPageWidgetState extends State<HelpLineCenterPageWidget>
    with TickerProviderStateMixin {
  late HelpLineCenterPageModel _model;

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
    _model = createModel(context, () => HelpLineCenterPageModel());
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
                  text: 'Helpline center',
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                      child: wrapWithModel(
                        model: _model.profileComponentModel1,
                        updateCallback: () => setState(() {}),
                        child: ProfileComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ad8nsx9kjyrx/WhatsApp.png',
                          text: 'Whatsapp',
                          action: () async {},
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                      child: wrapWithModel(
                        model: _model.profileComponentModel2,
                        updateCallback: () => setState(() {}),
                        child: ProfileComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/c98c19cs2le5/Facebook.png',
                          text: 'Facebook',
                          action: () async {},
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                      child: wrapWithModel(
                        model: _model.profileComponentModel3,
                        updateCallback: () => setState(() {}),
                        child: ProfileComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ogsg9dny3e6z/Instagram.png',
                          text: 'Instagram',
                          action: () async {},
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                      child: wrapWithModel(
                        model: _model.profileComponentModel4,
                        updateCallback: () => setState(() {}),
                        child: ProfileComponentWidget(
                          image:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/he9vgggkp3he/Twitter_(X).png',
                          text: 'X',
                          action: () async {},
                        ),
                      ),
                    ),
                  ],
                ).animateOnPageLoad(
                    animationsMap['columnOnPageLoadAnimation']!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
