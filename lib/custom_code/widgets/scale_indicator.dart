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

import 'package:animated_weight_picker/animated_weight_picker.dart';

class ScaleIndicator extends StatefulWidget {
  ScaleIndicator({
    super.key,
    this.width,
    this.height,
    required this.selectWeight,
  });

  final double? width;
  final double? height;
  String selectWeight;

  @override
  State<ScaleIndicator> createState() => _ScaleIndicatorState();
}

class _ScaleIndicatorState extends State<ScaleIndicator> {
  final double min = 10;
  final double max = 90;

  @override
  void initState() {
    widget.selectWeight = min.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Center(
        child: SizedBox(
          width: 500,
          child: AnimatedWeightPicker(
            min: 0,
            max: 10,
            selectedValueColor: Colors.white,
            suffixTextColor: Color(0xFF696969),
            dialThickness: 5,
            selectedValueStyle: TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
            ),
            showSelectedValue: true,
            dialColor: const Color(0xFFA2ED3A),
            onChange: (newValue) {
              setState(() {
                widget.selectWeight = newValue;
              });
            },
          ),
        ),
      ),
    );
  }
}
