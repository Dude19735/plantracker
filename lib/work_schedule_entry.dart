import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';

class WorkScheduleEntry extends StatelessWidget {
  final double _height;
  final double _width;

  WorkScheduleEntry(this._width, this._height);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.blue, height: _height, width: _width);
  }
}
