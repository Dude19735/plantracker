import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'dart:ui';

import 'package:scheduler/work_schedule_date_bar.dart';

// class WorkScheduleInnerView extends StatefulWidget {
//   final ScrollController _controller;
//   WorkScheduleInnerView(this._controller);

//   @override
//   State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
// }

class WorkScheduleInnerView extends StatelessWidget {
  //State<WorkScheduleInnerView> {
  // final ScrollController _controller;

  // final ScrollController _controller = ScrollController(
  //     initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
  //     keepScrollOffset: true);

  WorkScheduleInnerView();

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
            GlobalStyle.scheduleCellHeightPx * numBoxes +
                (numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth);

        var controller = ScrollController(
            initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
            keepScrollOffset: true);

        var view = //Stack(children: [
            // NotificationListener(
            //   onNotification: (notification) {
            //     if (notification is UserScrollNotification) {
            //       print("hello world");
            //       return false;
            //     }
            //     return false;
            //   },
            // child:

            GestureDetector(
                onVerticalDragUpdate: (details) {
                  print("vertical drag update ${details.localPosition}");
                },
                //   RawGestureDetector(
                // gestures: <Type, GestureRecognizerFactory>{
                //   PanGestureRecognizer:
                //       GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                //     () => PanGestureRecognizer(),
                //     (PanGestureRecognizer instance) {
                //       instance.onUpdate = (details) {
                //         print(details);
                //       };
                //       // ..onTapDown = (TapDownDetails details) { setState(() { _last = 'down'; }); }
                //       // ..onTapUp = (TapUpDetails details) { setState(() { _last = 'up'; }); }
                //       // ..onTap = () { setState(() { _last = 'tap'; }); }
                //       // ..onTapCancel = () { setState(() { _last = 'cancel'; }); };
                //     },
                //   ),
                // },
                child: CustomScrollView(controller: controller, slivers: [
                  // SliverAppBar(
                  //   pinned: true,
                  //   expandedHeight: 90,
                  //   flexibleSpace:
                  //       FlexibleSpaceBar(background: Container(color: Colors.white)),
                  // ),
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    shadowColor: Colors.black,
                    flexibleSpace: WorkScheduleDateBar(),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // return Container(
                        //     color: Colors.white,
                        //     width: constraints.maxWidth,
                        //     height: GlobalContext.scheduleWindowInlineRect.height);
                        return Container(
                            margin:
                                EdgeInsets.all(GlobalStyle.summaryCardMargin),
                            width: constraints.maxWidth,
                            height:
                                GlobalContext.scheduleWindowInlineRect.height,
                            child: CustomPaint(painter: _GridPainter()));
                      },
                      childCount: 1,
                    ),
                  )
                ]

                    // child: Container(
                    //     color: Colors.red,
                    //     margin: EdgeInsets.only(
                    //         left: GlobalStyle.cardMargin,
                    //         right: GlobalStyle.cardMargin,
                    //         bottom: GlobalStyle.cardMargin)),
                    ));
        // );
        // Container(
        //     color: Colors.black12.withAlpha(125),
        //     child: Center(
        //         child: LoadingAnimationWidget.newtonCradle(
        //             color: Colors.white, size: 200.0)))
        // ]);

        return NotificationListener(
            onNotification: (notification) {
              if (notification is ScrollNotification) {
                GlobalContext.scheduleWindowScrollOffset =
                    notification.metrics.pixels;
              }
              return false;
            },
            child: view);
        // return view;
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
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    double xOffset = boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;
    gridPainter.color = GlobalStyle.scheduleGridColorBox;
    while (xOffset < size.width - boxWidth / 2) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
      xOffset += boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    }

    double yOffset = GlobalStyle.scheduleCellHeightPx +
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
      yOffset += GlobalStyle.scheduleGridStrokeWidth +
          GlobalStyle.scheduleCellHeightPx;
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
