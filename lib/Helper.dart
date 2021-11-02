import 'package:flutter/material.dart';

//a helper method to quickly create a preset Text Widget
class LabelInput extends StatelessWidget {
  final String labelTextInput;
  final bool isWarning;

  LabelInput(this.labelTextInput, {this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: double.infinity,
      child: Text(
        labelTextInput,
        style: TextStyle(
          fontSize: 16,
          color: (this.isWarning ? Colors.red : Colors.black),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
