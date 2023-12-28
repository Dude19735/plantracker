import 'package:flutter/material.dart';
import 'package:scheduler/work_schedule_entry.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';

class WorkScheduleRecordedEntry
    extends WorkScheduleEntry<ScheduleRecordedData> {
  WorkScheduleRecordedEntry(double x, double y, double width, double height,
      ScheduleRecordedData? data)
      : super(x, y, width, height, data);

  @override
  Widget build(BuildContext context) {
    // print("build entry ${_planData!.date}");
    // Widget? child;
    // Color color = Colors.blue;
    // if (data() != null) {
    //   child = Text("${data()!.subject.subjectName}\n${data()!.date}");
    //   color = data()!.subject.subjectColor;
    // }
    return Transform(
        transform: Matrix4.translationValues(x1(), y1(), 0),
        child: Align(
            alignment: Alignment.topRight,
            child: Container(
                color: GlobalStyle.scheduleRecordedColor(
                    context, data()!.workUnitType),
                height: height(),
                width: width() * (1.0 - GlobalStyle.schedulePlanedUnitWithP))));
  }
}

// class WorkScheduleRecordedEntry extends StatelessWidget {
//   final double _height;
//   final double _width;
//   final double _x;
//   final double _y;
//   final ScheduleRecordedData _recordedData;

//   WorkScheduleRecordedEntry(
//       this._x, this._y, this._width, this._height, this._recordedData);

//   double y1() => _y;
//   double y2() => _y + _height;
//   double height() => _height;

//   @override
//   Widget build(BuildContext context) {
//     // print("build entry ${_planData!.date}");

//     return Transform(
//         transform: Matrix4.translationValues(_x, _y, 0),
//         child: Align(
//             alignment: Alignment.topRight,
//             child: Container(
//                 color: GlobalStyle.scheduleRecordedColor(
//                     context, _recordedData.workUnitType),
//                 height: _height,
//                 width: _width * (1.0 - GlobalStyle.schedulePlanedUnitWithP))));
//   }
// }
