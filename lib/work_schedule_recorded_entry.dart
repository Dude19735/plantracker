import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';

class WorkScheduleRecordedEntry extends StatelessWidget {
  final double _height;
  final double _width;
  final double _x;
  final double _y;
  final ScheduleRecordedData _recordedData;

  WorkScheduleRecordedEntry(
      this._x, this._y, this._width, this._height, this._recordedData);

  double y1() => _y;
  double y2() => _y + _height;
  double height() => _height;

  @override
  Widget build(BuildContext context) {
    // print("build entry ${_planData!.date}");

    return Transform(
        transform: Matrix4.translationValues(_x, _y, 0),
        child: Align(
            alignment: Alignment.topRight,
            child: Container(
                color: GlobalStyle.scheduleRecordedColor(
                    context, _recordedData.workUnitType),
                height: _height,
                width: _width * (1.0 - GlobalStyle.schedulePlanedUnitWithP))));
  }
}
