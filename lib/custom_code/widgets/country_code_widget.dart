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

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:country_code_picker/country_code_picker.dart';

class CountryCodeWidget extends StatefulWidget {
  const CountryCodeWidget({
    Key? key,
    this.width,
    this.height,
    required this.color,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color color;

  @override
  _CountryCodeWidgetState createState() => _CountryCodeWidgetState();
}

class _CountryCodeWidgetState extends State<CountryCodeWidget> {
  @override
  Widget build(BuildContext context) => new Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Container(
          height: widget.height,
          width: widget.width,
          // margin: EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              )),
          child: CountryCodePicker(
            onChanged: print,
            backgroundColor: widget.color,
            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
            initialSelection: 'IN',
            favorite: ['+91', 'IN'],
            padding: EdgeInsets.zero,
            textStyle: TextStyle(
              color: Colors.white,
              fontFamily: "Rubik",
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
            dialogTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: "Rubik",
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
            hideSearch: true,
            barrierColor: Colors.transparent,
            dialogBackgroundColor: Color(0xFF1E1E1E),
            // optional. Shows only country name and flag
            showCountryOnly: false,
            showFlag: false,

            showDropDownButton: true,
            // optional. Shows only country name and flag when popup is closed.
            showOnlyCountryWhenClosed: false,
            // optional. aligns the flag and the Text left
            alignLeft: false,
          ),
        )),
      );
}
