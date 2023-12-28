import 'package:flutter/material.dart';

class WorkScheduleEntry<TData> extends StatelessWidget {
  final double _height;
  final double _width;
  final double _x;
  final double _y;
  final TData? _data;

  WorkScheduleEntry(this._x, this._y, this._width, this._height, this._data);

  double height() => _height;
  double width() => _width;
  double x1() => _x;
  double x2() => _x + _width;
  TData? data() => _data;
  double y1() => _y;
  double y2() => _y + _height;

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
