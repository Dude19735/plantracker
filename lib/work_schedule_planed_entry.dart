import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';

class WorkSchedulePlanedEntry extends StatelessWidget {
  final double _height;
  final double _width;
  final double _x;
  final double _y;
  final SchedulePlanData? _planData;

  WorkSchedulePlanedEntry(
      this._x, this._y, this._width, this._height, this._planData);

  double y1() => _y;
  double y2() => _y + _height;

  @override
  Widget build(BuildContext context) {
    // print("build entry ${_planData!.date}");
    Widget? child;
    Color color = Colors.blue;
    if (_planData != null) {
      child = Text("${_planData!.subject.subjectName}\n${_planData!.date}");
      color = _planData!.subject.subjectColor;
    }
    return Transform(
        transform: Matrix4.translationValues(_x, _y, 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: color,
            height: _height,
            width: _width * GlobalStyle.schedulePlanedUnitWithP,
            child: child,
          ),
        ));
  }
}
