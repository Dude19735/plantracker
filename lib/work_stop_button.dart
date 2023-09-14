// import 'animated_toggle.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/work_toggler.dart';

/// Flutter code sample for [IconButton].

enum WorkButtonType { red, blue }

class WorkStopButton extends StatefulWidget {
  final GlobalContext _globalContext;
  late final String _label;

  WorkStopButton(this._globalContext);

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
