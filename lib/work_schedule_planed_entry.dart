import 'package:flutter/material.dart';
import 'package:scheduler/work_schedule_entry.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';

class WorkSchedulePlanedEntry extends WorkScheduleEntry<SchedulePlanData> {
  WorkSchedulePlanedEntry(double x, double y, double width, double height,
      SchedulePlanData? planData)
      : super(x, y, width, height, planData);

  @override
  Widget build(BuildContext context) {
    // print("build entry ${_planData!.date}");
    Widget? child;
    Color color = Colors.blue;
    if (data() != null) {
      child = Text("${data()!.subject.subjectName}\n${data()!.date}");
      color = data()!.subject.subjectColor;
    }
    return Transform(
        transform: Matrix4.translationValues(x1(), y1(), 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: color,
            width: width(),
            height: height(),
            child: child,
          ),
        ));
  }
}
