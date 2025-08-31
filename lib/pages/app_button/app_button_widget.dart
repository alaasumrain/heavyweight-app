import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_button_model.dart';
export 'app_button_model.dart';

class AppButtonWidget extends StatefulWidget {
  const AppButtonWidget({
    super.key,
    required this.title,
    this.action,
  });

  final String? title;
  final Future Function()? action;

  @override
  State<AppButtonWidget> createState() => _AppButtonWidgetState();
}

class _AppButtonWidgetState extends State<AppButtonWidget> {
  late AppButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        await widget.action?.call();
      },
      text: widget.title!,
      options: FFButtonOptions(
        width: double.infinity,
        height: 56.0,
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              fontFamily: 'Rubik',
              color: const Color(0xFF131313),
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              useGoogleFonts: GoogleFonts.asMap().containsKey('Rubik'),
            ),
        elevation: 0.0,
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
