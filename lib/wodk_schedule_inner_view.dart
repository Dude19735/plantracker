import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'dart:math';

class WorkScheduleInnerView extends StatefulWidget {
  final GlobalContext _globalContext;

  WorkScheduleInnerView(this._globalContext);

  // @override
  // Widget build(BuildContext context) {
  //   return DefaultTabController(
  //     length: 3,
  //     child: const TabBarView(children: <Widget>[
  //       Center(
  //         child: Text("It's cloudy here"),
  //       ),
  //       Center(
  //         child: Text("It's rainy here"),
  //       ),
  //       Center(
  //         child: Text("It's sunny here"),
  //       ),
  //     ]),
  //   );
  // }

  @override
  State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
}

class _WorkScheduleInnerView extends State<WorkScheduleInnerView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  Widget build(BuildContext context) {
    final int childCount = (CurrentConfig.scheduleCrossAxisBoxCount *
            (86400 / CurrentConfig.scheduleBoxRangeS))
        .round();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.all(GlobalStyle.globalCardMargin),
                width: constraints.maxWidth,
                height: GlobalStyle.scheduleBoxHeightPx * 96 +
                    2 *
                        (GlobalStyle.globalCardPadding +
                            GlobalStyle.globalCardMargin),
                child: Padding(
                    padding: EdgeInsets.all(GlobalStyle.globalCardPadding),
                    child: GlobalStyle.createShadowContainer(
                        context, CustomPaint(painter: _GridPainter()))
                    // child: CustomPaint(
                    //   painter: _GridPainter(constraints.maxWidth - 2 * padding),
                    // ),
                    )));
        // return GridView.count(
        //   crossAxisCount: CurrentConfig.scheduleCrossAxisBoxCount,
        //   mainAxisSpacing: 3,
        //   crossAxisSpacing: 3,
        //   childAspectRatio:
        //       (constraints.maxWidth / CurrentConfig.scheduleCrossAxisBoxCount) /
        //           CurrentConfig.scheduleBoxHeightPx,
        //   children: [
        //     for (int i = 0; i < childCount; ++i)
        //       Container(
        //           padding: const EdgeInsets.all(4.0),
        //           color: Colors.blueGrey,
        //           child: Text(i.toString())),
        //   ],
        // );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  // late final double _boxWidth;
  // late final double _totalWidth;
  // final double _totalHeight = CurrentConfig.scheduleBoxHeightPx * 96;

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
    int ccsbx = CurrentConfig.scheduleCrossAxisBoxCount;
    double boxWidth =
        (size.width - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    // canvas.drawPaint(backgroundPainter);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
