import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_button.dart';
import 'package:scheduler/subject_dropdown.dart';
import 'dart:math';

class WatchManager extends StatefulWidget {
  final GlobalContext _globalContext;

  const WatchManager(this._globalContext);

  @override
  State<WatchManager> createState() => _WatchManager();
}

class _WatchManager extends State<WatchManager>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(controller)
      ..addListener(() {
        setState(() {
          // print("set state");
        });
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double num = 4;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // print(
      //     "maxWidth: ${constraints.maxWidth}, maxHeight: ${constraints.maxHeight}");
      double watchSize = min(constraints.maxWidth, constraints.maxHeight / 2);
      return Padding(
        padding: const EdgeInsets.all(GlobalStyle.cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: watchSize / 2),
              child: Container(
                  width: min((constraints.maxHeight - watchSize) / num,
                      constraints.maxWidth / 5),
                  height: min((constraints.maxHeight - watchSize) / num,
                      constraints.maxWidth / 5),
                  color: Colors.red),
            ),
            CustomPaint(painter: WatchPainter(watchSize)),
            Padding(
              padding: EdgeInsets.only(top: watchSize / 2),
              child: Container(
                  width: constraints.maxWidth,
                  height: 0.8 * (constraints.maxHeight - watchSize) / num,
                  color: Colors.amber,
                  child: SubjectDropdown(widget._globalContext)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: GlobalStyle.cardPadding),
              child: Container(
                  width: constraints.maxWidth,
                  height: 1.2 * (constraints.maxHeight - watchSize) / num,
                  color: Colors.blue,
                  child: Row(
                    children: [
                      WorkButton(widget._globalContext, WorkButtonType.red),
                      WorkButton(widget._globalContext, WorkButtonType.blue),
                    ],
                  )),
            )
          ],
        ),
      );
    });
  }
}

class WatchPainter extends CustomPainter {
  final double _size;
  WatchPainter(this._size);

  @override
  void paint(Canvas canvas, Size size) {
    Paint painter = Paint();
    painter.color = Colors.greenAccent;
    painter.style = PaintingStyle.fill;
    painter.strokeWidth = 1;

    const double strokeWidth = 10;
    Paint painter2 = Paint();
    painter2.color = Colors.cyan;
    painter2.style = PaintingStyle.stroke;
    painter2.strokeWidth = strokeWidth;
    painter2.strokeCap = StrokeCap.round;

    double s = _size - 2 * (GlobalStyle.cardPadding + strokeWidth);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        _size / 2 - GlobalStyle.cardPadding * 2, painter);
    canvas.drawArc(Rect.fromCenter(center: Offset(0, 0), width: s, height: s),
        0, pi / 4, false, painter2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
