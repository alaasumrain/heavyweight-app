import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_bar_model.dart';
export 'app_bar_model.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({
    super.key,
    this.text,
  });

  final String? text;

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  late AppBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: const AlignmentDirectional(0.0, 0.0),
              children: [
                Align(
                  alignment: const AlignmentDirectional(-1.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0.0),
                          child: Image.asset(
                            'assets/images/arrow-left.png',
                            width: 28.0,
                            height: 30.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.text!,
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Rubik',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts:
                            GoogleFonts.asMap().containsKey('Rubik'),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
