import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_text_filde_model.dart';
export 'custom_text_filde_model.dart';

class CustomTextFildeWidget extends StatefulWidget {
  const CustomTextFildeWidget({
    super.key,
    required this.labal,
    required this.hint,
    this.sufix,
    this.prefix,
  });

  final String? labal;
  final String? hint;
  final Widget? sufix;
  final Widget? prefix;

  @override
  State<CustomTextFildeWidget> createState() => _CustomTextFildeWidgetState();
}

class _CustomTextFildeWidgetState extends State<CustomTextFildeWidget> {
  late CustomTextFildeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomTextFildeModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: TextFormField(
        controller: _model.textController,
        focusNode: _model.textFieldFocusNode,
        autofocus: true,
        obscureText: false,
        decoration: InputDecoration(
          isDense: true,
          labelText: widget.labal,
          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                fontSize: 15.0,
                useGoogleFonts: GoogleFonts.asMap().containsKey(
                    FlutterFlowTheme.of(context).labelMediumFamily),
              ),
          hintText: widget.hint,
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                fontSize: 17.0,
                useGoogleFonts: GoogleFonts.asMap().containsKey(
                    FlutterFlowTheme.of(context).labelMediumFamily),
              ),
          errorStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).error,
                fontSize: 15.0,
                useGoogleFonts: GoogleFonts.asMap()
                    .containsKey(FlutterFlowTheme.of(context).bodyMediumFamily),
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF2F2F2F),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: widget.prefix,
          suffixIcon: widget.sufix,
        ),
        style: FlutterFlowTheme.of(context).bodyMedium,
        validator: _model.textControllerValidator.asValidator(context),
      ),
    );
  }
}
