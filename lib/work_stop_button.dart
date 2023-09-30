import 'package:flutter/material.dart';

enum WorkButtonType { red, blue }

class WorkStopButton extends StatefulWidget {
  @override
  State<WorkStopButton> createState() => _WorkStopButton();
}

class _WorkStopButton extends State<WorkStopButton> {
  @override
  Widget build(BuildContext context) {
    var button = IconButton(
      onPressed: () {},
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.zero))),
      icon: Icon(Icons.stop_circle_rounded),
      iconSize: 40,
    );

    return button;
  }
}
