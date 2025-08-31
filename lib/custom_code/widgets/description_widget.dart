// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Imports custom actions
import 'package:readmore/readmore.dart';

class DescriptionWidget extends StatefulWidget {
  const DescriptionWidget({
    super.key,
    this.width,
    this.height,
    this.text,
  });

  final double? width;
  final double? height;
  final String? text;

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  @override
  Widget build(BuildContext context) => new Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          // height: widget.height,
          // width: widget.width,
          // margin: EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: ReadMoreText(
            widget.text!,
            trimLines: 4,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Read more',
            trimExpandedText: ' Read less',
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w400,
                fontSize: 17,
                height: 1.3),
            lessStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA2ED3A),
            ),
            moreStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA2ED3A),
            ),
          ),
        ),
      );
}
