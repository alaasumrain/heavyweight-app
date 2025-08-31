import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/app_button/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'empty_component_model.dart';
export 'empty_component_model.dart';

class EmptyComponentWidget extends StatefulWidget {
  const EmptyComponentWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String? image;
  final String? title;
  final String? subTitle;

  @override
  State<EmptyComponentWidget> createState() => _EmptyComponentWidgetState();
}

class _EmptyComponentWidgetState extends State<EmptyComponentWidget> {
  late EmptyComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyComponentModel());
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
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(19.0, 0.0, 19.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.network(
                widget.image!,
                width: 120.0,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 28.0, 0.0, 0.0),
              child: Text(
                widget.title!,
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
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 18.0, 0.0, 0.0),
              child: Text(
                widget.subTitle!,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
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
    );
  }
}
