import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';

class WorkScheduleEntry extends StatelessWidget {
  final double _height;
  final double _width;
  final double _x;
  final double _y;
  final SchedulePlanData? _planData;

  WorkScheduleEntry(
      this._x, this._y, this._width, this._height, this._planData);

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    Widget? child;
    if (_planData != null) {
      child = Text(_planData!.subject.toString());
    }
    return Transform(
        transform: Matrix4.translationValues(_x, _y, 0),
        child: Container(
          color: Colors.blue,
          height: _height,
          width: _width,
          child: child,
        ));
  }
}
