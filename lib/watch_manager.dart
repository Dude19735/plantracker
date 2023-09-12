import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_button.dart';
import 'package:scheduler/subject_dropdown.dart';
import 'package:scheduler/work_toggler.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Timer _watchTimeout([int milliseconds = 1000]) {
    watchState.update();
    controller.reset();
    controller.forward();
    return Timer(Duration(milliseconds: milliseconds), () {
      setState(() {
        if (active) {
          _watchTimeout();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    watchState = WatchState();

    // run the animation shit
    controller = AnimationController(
        duration: const Duration(milliseconds: 950), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    // ..addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {}
    // });

    active = true;
    _watchTimeout();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double clockPadding = 15;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GlobalStyle.createShadowContainer(
            context,
            WorkToggler(
                onHitL: () {
                  print("L");
                },
                onHitR: () {
                  print("R");
                },
                restingColorL: GlobalStyle.markerRed,
                restingColorR: GlobalStyle.markerRed,
                handleRadius: 15.0,
                iconAssetStr: "lib/img/dismiss.svg"),
            width: GlobalStyle.clockBarWidth - clockPadding,
            height: 30.0,
            color: Colors.transparent),
        Container(height: GlobalStyle.globalCardPadding),
        GlobalStyle.createShadowContainer(
            context,
            CustomPaint(
                painter: WatchPainter(GlobalStyle.clockBarWidth - clockPadding,
                    watchState, watchState.getArc(animation))),
            margin: 0.0,
            borderRadius: GlobalStyle.clockBarWidth / 2,
            width: GlobalStyle.clockBarWidth - clockPadding,
            height: GlobalStyle.clockBarWidth - clockPadding),
        Container(height: GlobalStyle.globalCardPadding),
        GlobalStyle.createShadowContainer(
            context, SubjectDropdown(widget._globalContext),
            margin: 0.0,
            width: GlobalStyle.clockBarWidth - clockPadding,
            height: GlobalStyle.clockBarWidth / 3),
        Container(height: GlobalStyle.globalCardPadding),
        GlobalStyle.createShadowContainer(
            context, WorkButton(widget._globalContext),
            margin: 0.0,
            width: GlobalStyle.clockBarWidth - clockPadding,
            height: GlobalStyle.clockBarWidth * 1.5),
      ],
    );
  }
}

enum WatchStateState { warmUp, goGoGo }

class WatchState {
  WatchStateState state = WatchStateState.warmUp;
  int seconds = GlobalSettings.initialWorkCountdownInterval;

  void update() {
    if (seconds <= GlobalSettings.initialWorkCountdownInterval) {
      seconds--;
      if (seconds < 0) {
        seconds = GlobalSettings.initialWorkCountdownInterval + 1;
        state = WatchStateState.goGoGo;
      }
    } else {
      seconds++;
    }
  }

  double getArc(Animation animation) {
    return (seconds + exp(-6 * animation.value)) *
        2.0 *
        pi /
        GlobalSettings.initialWorkCountdownInterval;
  }

  void reset() {
    state = WatchStateState.warmUp;
    seconds = GlobalSettings.initialWorkCountdownInterval;
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
  final double _arcRadius;
  final double _size;
  final WatchState _watchState;
  final double strokeWidth = 15;
  final double fontSize = 17;

  Paint backgroundPainter = Paint();
  Paint redCirclePainter = Paint();

  WatchPainter(this._size, this._watchState, this._arcRadius) {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;
    backgroundPainter.strokeWidth = 1;

    redCirclePainter.color = GlobalStyle.markerRed;
    redCirclePainter.style = PaintingStyle.stroke;
    redCirclePainter.strokeWidth = strokeWidth;
    redCirclePainter.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double s = _size - strokeWidth;

    // var path = Path();
    // path.addOval(Rect.fromCircle(
    //     center: Offset(size.width / 2, size.height / 2),
    //     radius: _size / 2 - GlobalStyle.cardPadding * 2));
    // canvas.drawShadow(path, Colors.black, 10, true);
    // canvas.drawPath(path, backgroundPainter);

    Offset off = Offset(_size / 2, _size / 2);
    canvas.drawArc(Rect.fromCenter(center: off, width: s, height: s), 0,
        _arcRadius, false, redCirclePainter);

    // canvas.drawShadow(path, color, elevation, transparentOccluder)

    final textStyle = TextStyle(
        color: Colors.black, fontSize: fontSize, fontWeight: FontWeight.bold);
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

    Offset off2 = Offset(
      // Do calculations here:
      (size.width - textPainter.width) * 0.5,
      (size.height - textPainter.height) * 0.5,
    );
    textPainter.paint(canvas, off2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
