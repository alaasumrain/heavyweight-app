import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/logout_dailog/logout_dailog_widget.dart';
import '/pages/profile_component/profile_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page_model.dart';
export 'profile_page_model.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget>
    with TickerProviderStateMixin {
  late ProfilePageModel _model;

  final animationsMap = {
    'listViewOnPageLoadAnimation': AnimationInfo(
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
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfilePageModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, -1.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
            child: Text(
              'Profile',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    useGoogleFonts: GoogleFonts.asMap().containsKey(
                        FlutterFlowTheme.of(context).bodyMediumFamily),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 46.0, 0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/profile.png',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
            child: Text(
              'Ronald richards',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: GoogleFonts.asMap().containsKey(
                        FlutterFlowTheme.of(context).bodyMediumFamily),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
            child: Text(
              'ronaldrichards@gmail.com',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 17.0,
                    useGoogleFonts: GoogleFonts.asMap().containsKey(
                        FlutterFlowTheme.of(context).bodyMediumFamily),
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  16.0,
                ),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  wrapWithModel(
                    model: _model.profileComponentModel1,
                    updateCallback: () => setState(() {}),
                    child: ProfileComponentWidget(
                      image:
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/9dr7hqa789fc/profilePage.png',
                      text: 'My profile',
                      action: () async {
                        context.pushNamed(
                          'myProfilePage',
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
                  wrapWithModel(
                    model: _model.profileComponentModel2,
                    updateCallback: () => setState(() {}),
                    child: ProfileComponentWidget(
                      image:
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/n9i3k1o8ov2t/info_circle.png',
                      text: 'About us',
                      action: () async {
                        context.pushNamed(
                          'aboutUs',
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
                  wrapWithModel(
                    model: _model.profileComponentModel3,
                    updateCallback: () => setState(() {}),
                    child: ProfileComponentWidget(
                      image:
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/xnjhx5ei8qtb/privacy.png',
                      text: 'Privacy policy',
                      action: () async {
                        context.pushNamed(
                          'privacyPolicyPage',
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
                  wrapWithModel(
                    model: _model.profileComponentModel4,
                    updateCallback: () => setState(() {}),
                    child: ProfileComponentWidget(
                      image:
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/ru8m41f24jcj/setting.png',
                      text: 'Setting',
                      action: () async {
                        context.pushNamed(
                          'settingPage',
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
                  Builder(
                    builder: (context) => wrapWithModel(
                      model: _model.profileComponentModel5,
                      updateCallback: () => setState(() {}),
                      child: ProfileComponentWidget(
                        image:
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/in7du9251r0t/logout.png',
                        text: 'Log out',
                        action: () async {
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: const AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: const LogoutDailogWidget(),
                              );
                            },
                          ).then((value) => setState(() {}));
                        },
                      ),
                    ),
                  ),
                ].divide(const SizedBox(height: 16.0)),
              ).animateOnPageLoad(
                  animationsMap['listViewOnPageLoadAnimation']!),
            ),
          ),
        ],
      ),
    );
  }
}
