import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'dart:ui';

// class WorkScheduleInnerView extends StatefulWidget {
//   final ScrollController _controller;
//   WorkScheduleInnerView(this._controller);

//   @override
//   State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
// }

class WorkScheduleInnerView extends StatelessWidget {
  //State<WorkScheduleInnerView> {
  final ScrollController _controller;
  WorkScheduleInnerView(this._controller);

  @override
  Widget build(BuildContext context) {
    double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        GlobalContext.scheduleWindowOutlineRect =
            Rect.fromLTRB(0, 0, constraints.maxWidth, constraints.maxHeight);

        GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
            0,
            0,
            constraints.maxWidth,
            GlobalStyle.scheduleBoxHeightPx * numBoxes +
                2 *
                    (GlobalStyle.globalCardPadding +
                        GlobalStyle.globalCardMargin) +
                (numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth);

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
              height: GlobalContext.scheduleWindowInlineRect.height,
              child: Padding(
                padding: EdgeInsets.all(GlobalStyle.globalCardPadding),
                child: GlobalStyle.createShadowContainer(
                    context,
                    // GestureDetector(
                    // onVerticalDragUpdate: (details) {
                    //   //   // if (details.localPosition.dy >
                    //   //   //     constraints.maxHeight) {
                    //   //   //   widget._controller
                    //   //   //       .jumpTo(details.localPosition.dy);
                    //   //   // }
                    //   //   // widget._controller.animateTo(
                    //   //   //     details.localPosition.dx,
                    //   //   //     duration: Duration(seconds: 1),
                    //   //   //     curve: Curves.linear);
                    //   //   // UserScrollNotification(metrics: metrics, context: context, direction: direction)
                    // },
                    // child:
                    CustomPaint(painter: _GridPainter())),
              ),
            ),
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
  Paint rectPainter = Paint();

  _GridPainter() {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = GlobalStyle.scheduleGridStrokeWidth;
    gridPainter.strokeCap = StrokeCap.round;

    rectPainter.style = PaintingStyle.fill;
    rectPainter.strokeWidth = 1;
    rectPainter.color = GlobalStyle.scheduleSelectionColor;
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
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleBoxHeightPx);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    double xOffset = boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;
    gridPainter.color = GlobalStyle.scheduleGridColorBox;
    while (xOffset < size.width - boxWidth / 2) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
      xOffset += boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    }

    double yOffset = GlobalStyle.scheduleBoxHeightPx +
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

    // var rect = Rect.fromLTWH(
    //     0,
    //     GlobalStyle.scheduleGridStrokeWidth + GlobalStyle.scheduleBoxHeightPx,
    //     boxWidth,
    //     GlobalStyle.scheduleBoxHeightPx);
    if (GlobalContext.scheduleWindowSelectionBox != null) {
      canvas.drawRect(GlobalContext.scheduleWindowSelectionBox!, rectPainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
