import 'dart:async';

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
  late WatchState watchState;
  bool active = false;

  // late Stream<void> stream;

  // void watchTimeout() {
  //   // callback function
  //   // Do some work.
  //   watchState.update();
  // }

  Timer _watchTimeout([int milliseconds = 1000]) =>
      Timer(Duration(milliseconds: milliseconds), () {
        setState(() {
          watchState.update();
          if (active) {
            _watchTimeout();
          }
        });
      });

  // void start() {
  //   _active = true;
  //   _watchTimeout();
  // }

  // void stop() {
  //   _active = false;
  // }

  // void _update() {
  //   time = DateTime.now();
  //   if (_active) {
  //     // print("watch timeout");
  //     _watchTimeout();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    watchState = WatchState();
    active = true;
    _watchTimeout();
    // watchState.start();
    // stream = Stream.periodic(const Duration(seconds: 1), (count) {
    //   //return true if the time now is after set time
    //   if (DateTime.now().isAfter(watchState.time)) {
    //     print("update watch");
    //     watchState.update();
    //   }
    // });

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
    const double num = 7;
    return Padding(
        padding: const EdgeInsets.all(GlobalStyle.cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: GlobalStyle.clockBarWidth / 2),
              child: Container(
                  width: GlobalStyle.clockBarWidth,
                  height: GlobalStyle.clockBarWidth,
                  color: Colors.red),
            ),
            CustomPaint(
                painter: WatchPainter(GlobalStyle.clockBarWidth, watchState)),
            Padding(
              padding: EdgeInsets.only(top: GlobalStyle.clockBarWidth / 2),
              child: Container(
                  width: GlobalStyle.clockBarWidth,
                  height: GlobalStyle.subjectSelectorHeight,
                  color: Colors.amber,
                  child: SubjectDropdown(widget._globalContext)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: GlobalStyle.cardPadding),
              child: Container(
                  width: GlobalStyle.clockBarWidth,
                  color: Colors.blue,
                  child: Column(
                    children: [
                      WorkButton(widget._globalContext, WorkButtonType.red,
                          GlobalStyle.clockBarWidth, GlobalStyle.clockBarWidth),
                      WorkButton(widget._globalContext, WorkButtonType.blue,
                          GlobalStyle.clockBarWidth, GlobalStyle.clockBarWidth)
                    ],
                  )),
            )
          ],
        ));
  }
}

class WatchState {
  int seconds = GlobalSettings.initialCountdownInterval;

  void update() {
    if (seconds <= GlobalSettings.initialCountdownInterval) {
      seconds--;
      if (seconds < 0) {
        seconds = GlobalSettings.initialCountdownInterval + 1;
      }
    } else {
      seconds++;
    }
  }

  @override
  String toString() {
    int minss = seconds % 3600;
    int hours = (seconds - minss) ~/ 3600;
    int secss = minss % 60;
    int minutes = (minss - secss) ~/ 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secss.toString().padLeft(2, '0')}";
  }
}

class WatchPainter extends CustomPainter {
  final double _size;
  final WatchState _watchState;
  WatchPainter(this._size, this._watchState);

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

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 15,
    );
    final textSpan = TextSpan(
      text: _watchState.toString(),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: GlobalStyle.clockBarWidth,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
