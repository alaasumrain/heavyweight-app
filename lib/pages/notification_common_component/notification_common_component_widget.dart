import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_common_component_model.dart';
export 'notification_common_component_model.dart';

class NotificationCommonComponentWidget extends StatefulWidget {
  const NotificationCommonComponentWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.time,
  });

  final String? title;
  final String? subTitle;
  final String? time;

  @override
  State<NotificationCommonComponentWidget> createState() =>
      _NotificationCommonComponentWidgetState();
}

class _NotificationCommonComponentWidgetState
    extends State<NotificationCommonComponentWidget> {
  late NotificationCommonComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationCommonComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 152.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent2,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15.0,
                    color: Color(0x19000000),
                    offset: Offset(0.0, 4.0),
                  )
                ],
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image.asset(
                    'assets/images/Alert.png',
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 7.0, 0.0, 0.0),
                      child: Text(
                        widget.title!,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: AutoSizeText(
                        widget.subTitle!,
                        maxLines: 2,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 17.0,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                              lineHeight: 1.3,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        widget.time!,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 15.0,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  FlutterFlowTheme.of(context)
                                      .bodyMediumFamily),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
