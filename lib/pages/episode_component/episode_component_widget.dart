import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'episode_component_model.dart';
export 'episode_component_model.dart';

class EpisodeComponentWidget extends StatefulWidget {
  const EpisodeComponentWidget({
    super.key,
    required this.image,
    required this.title,
    required this.playText,
  });

  final String? image;
  final String? title;
  final String? playText;

  @override
  State<EpisodeComponentWidget> createState() => _EpisodeComponentWidgetState();
}

class _EpisodeComponentWidgetState extends State<EpisodeComponentWidget> {
  late EpisodeComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EpisodeComponentModel());
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
      height: 108.0,
      decoration: BoxDecoration(
        color: const Color(0xFF3A434F),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.network(
                widget.image!,
                width: 84.0,
                height: 84.0,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title!,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: GoogleFonts.asMap().containsKey(
                                FlutterFlowTheme.of(context).bodyMediumFamily),
                          ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(0.0),
                            child: Image.asset(
                              'assets/images/play.png',
                              width: 16.0,
                              height: 16.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                4.0, 0.0, 0.0, 0.0),
                            child: Text(
                              widget.playText!,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color: const Color(0xFFC0BFBF),
                                    fontSize: 15.0,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(
                                            FlutterFlowTheme.of(context)
                                                .bodyMediumFamily),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/arrow-right.png',
                width: 24.0,
                height: 24.0,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
