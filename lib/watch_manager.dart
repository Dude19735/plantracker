import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_button.dart';
import 'package:scheduler/subject_dropdown.dart';
import 'package:scheduler/work_toggler.dart';
import 'package:scheduler/work_stop_button.dart';
import 'dart:math';

class WatchManager extends StatefulWidget {
  final double _width;
  const WatchManager(this._width);

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
    final double bWidth = widget._width;
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(GlobalStyle.clockBarPadding),
        child: Column(
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
                    restingColorL: GlobalStyle.markerRed(context),
                    restingColorR: GlobalStyle.markerRed(context),
                    handleRadius: 15.0,
                    iconAssetStr: [
                      "lib/img/dismiss.svg",
                      "lib/img/dismiss.svg"
                    ]),
                width: bWidth,
                height: 30.0,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                color: Colors.transparent),
            Container(height: GlobalStyle.clockBarSpacingDistance),
            GlobalStyle.createShadowContainer(
                context,
                CustomPaint(
                    painter: WatchPainter(context, bWidth, watchState,
                        watchState.getArc(animation))),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                borderRadius: bWidth / 2,
                width: bWidth,
                height: bWidth),
            Container(height: GlobalStyle.clockBarSpacingDistance),
            GlobalStyle.createShadowContainer(context, SubjectDropdown(),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                borderRadius: GlobalStyle.clockBarBoxRadius,
                width: bWidth,
                height: bWidth / 3),
            Container(height: GlobalStyle.clockBarSpacingDistance),
            GlobalStyle.createShadowContainer(context, WorkStopButton(),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                borderRadius: GlobalStyle.clockBarBoxRadius,
                width: bWidth,
                height: bWidth),
            Container(height: GlobalStyle.clockBarSpacingDistance),
            GlobalStyle.createShadowContainer(context, WorkButton(),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                borderRadius: GlobalStyle.clockBarBoxRadius,
                width: bWidth,
                height: bWidth * 1.5),
          ],
        ),
      ),
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
  final double fontSize = 12;
  final BuildContext _context;

  Paint backgroundPainter = Paint();
  Paint redCirclePainter = Paint();

  WatchPainter(this._context, this._size, this._watchState, this._arcRadius) {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;
    backgroundPainter.strokeWidth = 1;

    redCirclePainter.color = GlobalStyle.markerRed(_context);
    redCirclePainter.style = PaintingStyle.stroke;
    redCirclePainter.strokeWidth = strokeWidth;
    redCirclePainter.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double s = _size - strokeWidth;

    Offset off = Offset(_size / 2, _size / 2);
    canvas.drawArc(Rect.fromCenter(center: off, width: s, height: s), 0,
        _arcRadius, false, redCirclePainter);

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
