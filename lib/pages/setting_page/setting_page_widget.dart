import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/delete_account_dailog/delete_account_dailog_widget.dart';
import '/pages/profile_component/profile_component_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'setting_page_model.dart';
export 'setting_page_model.dart';

class SettingPageWidget extends StatefulWidget {
  const SettingPageWidget({super.key});

  @override
  State<SettingPageWidget> createState() => _SettingPageWidgetState();
}

class _SettingPageWidgetState extends State<SettingPageWidget>
    with TickerProviderStateMixin {
  late SettingPageModel _model;

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
    _model = createModel(context, () => SettingPageModel());
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
                  text: 'Setting',
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
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/u36hzplf4gb2/security.png',
                          text: 'Security',
                          action: () async {
                            context.pushNamed(
                              'securityPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType:
                                      PageTransitionType.rightToLeft,
                                  duration: Duration(milliseconds: 300),
                                ),
                              },
                            );
                          },
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
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/vithw1qhrxi6/lock.png',
                          text: 'Change password',
                          action: () async {
                            context.pushNamed(
                              'changePasswordPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType:
                                      PageTransitionType.rightToLeft,
                                  duration: Duration(milliseconds: 300),
                                ),
                              },
                            );
                          },
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
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/n9i3k1o8ov2t/info_circle.png',
                          text: 'Terms & condition',
                          action: () async {
                            context.pushNamed(
                              'termsAndConditionPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType:
                                      PageTransitionType.rightToLeft,
                                  duration: Duration(milliseconds: 300),
                                ),
                              },
                            );
                          },
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
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/xnjhx5ei8qtb/privacy.png',
                          text: 'Help center',
                          action: () async {
                            context.pushNamed(
                              'helpLineCenterPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType:
                                      PageTransitionType.rightToLeft,
                                  duration: Duration(milliseconds: 300),
                                ),
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) => Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 16.0, 16.0, 0.0),
                        child: wrapWithModel(
                          model: _model.profileComponentModel5,
                          updateCallback: () => setState(() {}),
                          child: ProfileComponentWidget(
                            image:
                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pluse-up-fitness-app-q38cto/assets/toi3mbq0064b/delectAcount.png',
                            text: 'Delete account',
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
                                    child: GestureDetector(
                                      onTap: () => _model
                                              .unfocusNode.canRequestFocus
                                          ? FocusScope.of(context)
                                              .requestFocus(_model.unfocusNode)
                                          : FocusScope.of(context).unfocus(),
                                      child: const DeleteAccountDailogWidget(),
                                    ),
                                  );
                                },
                              ).then((value) => setState(() {}));
                            },
                          ),
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
