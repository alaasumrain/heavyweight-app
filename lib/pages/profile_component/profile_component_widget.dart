import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_component_model.dart';
export 'profile_component_model.dart';

class ProfileComponentWidget extends StatefulWidget {
  const ProfileComponentWidget({
    super.key,
    required this.image,
    required this.text,
    required this.action,
  });

  final String? image;
  final String? text;
  final Future Function()? action;

  @override
  State<ProfileComponentWidget> createState() => _ProfileComponentWidgetState();
}

class _ProfileComponentWidgetState extends State<ProfileComponentWidget> {
  late ProfileComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.action?.call();
      },
      child: Container(
        width: double.infinity,
        height: 64.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).accent2,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 16.0, 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F2F2F),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Image.network(
                      widget.image!,
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
                  child: Text(
                    widget.text!,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          fontSize: 17.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              FlutterFlowTheme.of(context).bodyMediumFamily),
                        ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.asset(
                  'assets/images/arrow-right.png',
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
