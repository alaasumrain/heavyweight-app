import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/app_bar/app_bar_widget.dart';
import '/pages/app_button/app_button_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_page_model.dart';
export 'edit_profile_page_model.dart';

class EditProfilePageWidget extends StatefulWidget {
  const EditProfilePageWidget({super.key});

  @override
  State<EditProfilePageWidget> createState() => _EditProfilePageWidgetState();
}

class _EditProfilePageWidgetState extends State<EditProfilePageWidget> {
  late EditProfilePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfilePageModel());

    _model.textController1 ??= TextEditingController(text: 'Ronald richards');
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??=
        TextEditingController(text: 'ronaldrichards@gmail.com');
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController(text: '4567259861');
    _model.textFieldFocusNode3 ??= FocusNode();
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
                  text: 'Edit profile',
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Stack(
                        alignment: const AlignmentDirectional(1.0, 1.0),
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 31.0, 0.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/Profileimage.png',
                                width: 102.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              final selectedMedia =
                                  await selectMediaWithSourceBottomSheet(
                                context: context,
                                allowPhoto: true,
                                backgroundColor:
                                    FlutterFlowTheme.of(context).alternate,
                                textColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                pickerFontFamily: 'Rubik',
                              );
                              if (selectedMedia != null &&
                                  selectedMedia.every((m) => validateFileFormat(
                                      m.storagePath, context))) {
                                setState(() => _model.isDataUploading = true);
                                var selectedUploadedFiles = <FFUploadedFile>[];

                                try {
                                  selectedUploadedFiles = selectedMedia
                                      .map((m) => FFUploadedFile(
                                            name: m.storagePath.split('/').last,
                                            bytes: m.bytes,
                                            height: m.dimensions?.height,
                                            width: m.dimensions?.width,
                                            blurHash: m.blurHash,
                                          ))
                                      .toList();
                                } finally {
                                  _model.isDataUploading = false;
                                }
                                if (selectedUploadedFiles.length ==
                                    selectedMedia.length) {
                                  setState(() {
                                    _model.uploadedLocalFile =
                                        selectedUploadedFiles.first;
                                  });
                                } else {
                                  setState(() {});
                                  return;
                                }
                              }
                            },
                            child: Container(
                              width: 34.0,
                              height: 34.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).accent2,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.61),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: Image.asset(
                                    'assets/images/camera.png',
                                    width: 20.78,
                                    height: 20.78,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 24.0, 16.0, 0.0),
                        child: TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Full name',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 15.0,
                                  useGoogleFonts: GoogleFonts.asMap()
                                      .containsKey(FlutterFlowTheme.of(context)
                                          .labelMediumFamily),
                                ),
                            hintText: 'Enter your full name',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 17.0,
                                  useGoogleFonts: GoogleFonts.asMap()
                                      .containsKey(FlutterFlowTheme.of(context)
                                          .labelMediumFamily),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          validator: _model.textController1Validator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 16.0, 16.0, 0.0),
                        child: TextFormField(
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Email address',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 15.0,
                                  useGoogleFonts: GoogleFonts.asMap()
                                      .containsKey(FlutterFlowTheme.of(context)
                                          .labelMediumFamily),
                                ),
                            hintText: 'Enter your email address',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 17.0,
                                  useGoogleFonts: GoogleFonts.asMap()
                                      .containsKey(FlutterFlowTheme.of(context)
                                          .labelMediumFamily),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          validator: _model.textController2Validator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 16.0, 16.0, 0.0),
                        child: Container(
                          height: 54.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 0.0, 0.0),
                                child: SizedBox(
                                  width: 75.0,
                                  height: 54.0,
                                  child: custom_widgets.CountryCodeWidget(
                                    width: 120.0,
                                    height: 56.0,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _model.textController3,
                                  focusNode: _model.textFieldFocusNode3,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: 'Phone number',
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Rubik',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 15.0,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey('Rubik'),
                                        ),
                                    hintText: 'Enter your phone number',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Rubik',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 17.0,
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey('Rubik'),
                                        ),
                                    errorStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: const Color(0xFFCD3232),
                                          useGoogleFonts: GoogleFonts.asMap()
                                              .containsKey(
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily),
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Rubik',
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontSize: 17.0,
                                        useGoogleFonts: GoogleFonts.asMap()
                                            .containsKey('Rubik'),
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model.textController3Validator
                                      .asValidator(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
                child: wrapWithModel(
                  model: _model.appButtonModel,
                  updateCallback: () => setState(() {}),
                  child: AppButtonWidget(
                    title: 'Save',
                    action: () async {
                      context.safePop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
