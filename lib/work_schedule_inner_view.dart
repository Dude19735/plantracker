import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

class WorkScheduleInnerView extends StatelessWidget {
  ScrollController _controller;
  WorkScheduleInnerView(this._controller);

  @override
  Widget build(BuildContext context) {
    double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(children: [
          // NotificationListener(
          //   onNotification: (notification) {
          //     if (notification is UserScrollNotification) {
          //       print("hello world");
          //       return false;
          //     }
          //     return false;
          //   },
          // child:
          SingleChildScrollView(
            controller: _controller,
            child: Container(
                margin: const EdgeInsets.all(GlobalStyle.globalCardMargin),
                width: constraints.maxWidth,
                height: GlobalStyle.scheduleBoxHeightPx * numBoxes +
                    2 *
                        (GlobalStyle.globalCardPadding +
                            GlobalStyle.globalCardMargin) +
                    (numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth,
                child: Padding(
                  padding: EdgeInsets.all(GlobalStyle.globalCardPadding),
                  child: GlobalStyle.createShadowContainer(
                      context, CustomPaint(painter: _GridPainter())),
                )),
          ),
          // Container(
          //     color: Colors.black12.withAlpha(125),
          //     child: Center(
          //         child: LoadingAnimationWidget.newtonCradle(
          //             color: Colors.white, size: 200.0)))
        ]);
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();

  _GridPainter() {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = GlobalStyle.scheduleGridStrokeWidth;
    gridPainter.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int ccsbx = GlobalContext.fromDateWindow
            .difference(GlobalContext.toDateWindow)
            .inDays
            .abs() +
        1;

    double boxWidth =
        (size.width - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    double xOffset = boxWidth;
    gridPainter.color = GlobalStyle.scheduleGridColorBox;
    while (xOffset < size.width - boxWidth / 2) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
      xOffset += boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    }

    double yOffset = GlobalStyle.scheduleBoxHeightPx -
        GlobalStyle.scheduleGridStrokeWidth / 2;
    int counter = 1;
    while (yOffset < size.height - GlobalStyle.scheduleGridStrokeWidth) {
      if (counter % 4 == 0) {
        gridPainter.color = GlobalStyle.scheduleGridColorFullHour;
      } else {
        gridPainter.color = GlobalStyle.scheduleGridColorBox;
      }
      canvas.drawLine(
          Offset(0, yOffset), Offset(size.width, yOffset), gridPainter);
      counter++;
      yOffset +=
          GlobalStyle.scheduleGridStrokeWidth + GlobalStyle.scheduleBoxHeightPx;
    }

    // var rect = Rect.fromLTWH(left, top, boxWidth, GlobalStyle.scheduleBoxHeightPx as double);
    // canvas.drawRect(, paint)
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
