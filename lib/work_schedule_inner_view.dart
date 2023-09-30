import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'dart:ui';

import 'package:scheduler/work_schedule_date_bar.dart';

class WorkScheduleInnerView extends StatefulWidget {
  WorkScheduleInnerView();

  @override
  State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
}

class _WorkScheduleInnerView extends State<WorkScheduleInnerView>
    with SingleTickerProviderStateMixin {
  //State<WorkScheduleInnerView> {
  // final ScrollController _controller;

  // final ScrollController _controller = ScrollController(
  //     initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
  //     keepScrollOffset: true);

  final double _topFrame = 0;
  final double _sideFrame = GlobalStyle.splitterCellMargin;

  late Animation<double> _animation;
  late AnimationController _controller;
  late double _curXPos;
  late double _curYPos;
  bool _animBackwards = false;

  _WorkScheduleInnerView();

  @override
  void initState() {
    super.initState();
    _curXPos = -1;
    _curYPos = -1;
    _controller =
        AnimationController(duration: Duration(milliseconds: 125), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          if (GlobalContext.scheduleWindowSelectionBox != null) {
            double top = GlobalContext.scheduleWindowSelectionBox!.top;
            GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
                _curXPos,
                top,
                GlobalContext.scheduleWindowCell.width,
                _curYPos -
                    top +
                    _animation.value * GlobalStyle.scheduleCellHeightPx +
                    (_animBackwards ? GlobalStyle.scheduleCellHeightPx : 0));
          }

          if (_controller.status == AnimationStatus.completed) {}
        });
      });
  }

  double _roundToVFrame(double xval) {
    double xpos = (xval - _sideFrame) -
        (xval - _sideFrame) %
            (GlobalContext.scheduleWindowCell.width +
                GlobalStyle.scheduleGridStrokeWidth);

    return xpos;
  }

  double _roundToHFrame(double yval) {
    double yvalOffset = yval - _topFrame - GlobalStyle.scheduleDateBarHeight;
    double ypos = yvalOffset -
        yvalOffset %
            (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth);

    return ypos;
  }

  bool _clampConditions(double xMousePos, double yMousePos) {
    // print(
    //     "$yMousePos ${GlobalContext.scheduleWindowInlineRect.height + GlobalStyle.scheduleDateBarHeight - _bottomFrame}");
    // bool clamp = yMousePos < 0 ||
    //     yMousePos > GlobalContext.scheduleWindowInlineRect.height ||
    //     xMousePos < 0 ||
    //     xMousePos >
    //         GlobalContext.scheduleWindowInlineRect.width - 2 * _sideFrame;

    bool clamp = !GlobalContext.scheduleWindowInlineRect
        .contains(Offset(xMousePos, yMousePos));

    return clamp;
  }

  bool _resetConditions(double dy) {
    bool reset = dy < 0 &&
        (GlobalContext.scheduleWindowSelectionBox == null ||
            GlobalContext.scheduleWindowSelectionBox!.height <
                GlobalStyle.scheduleCellHeightPx);

    return reset;
  }

  void _syncVertScrollPos(double ypos) {
    if (ypos >
        GlobalContext.scheduleWindowOutlineRect.height +
            // GlobalStyle.scheduleDateBarHeight -
            GlobalSettings.scheduleWindowAutoScrollOffset) {
      GlobalContext.scheduleWindowScrollOffset += 5;
    } else if (ypos < GlobalSettings.scheduleWindowAutoScrollOffset) {
      GlobalContext.scheduleWindowScrollOffset -= 5;
    }
  }

  void _resetSelection() {
    _controller.reset();
    GlobalContext.scheduleWindowSelectionBox = null;
    _curYPos = -1;
    _curXPos = -1;
    _animBackwards = false;
    // _initSelection = false;
  }

  @override
  Widget build(BuildContext context) {
    double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        GlobalContext.scheduleWindowOutlineRect =
            Rect.fromLTRB(0, 0, constraints.maxWidth, constraints.maxHeight);

        GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
            0,
            GlobalStyle.scheduleDateBarHeight,
            constraints.maxWidth,
            GlobalStyle.scheduleCellHeightPx * numBoxes +
                (numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth +
                GlobalStyle.scheduleDateBarHeight);

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
                  // print("vertical drag update ${details.localPosition}");

                  // _syncVertScrollPos(details.localPosition.dy);
                  // GlobalContext.scheduleWindowScrollOffset = controller.offset;
                  setState(() {
                    if (details.localPosition.dy >
                        GlobalContext.scheduleWindowOutlineRect.height +
                            GlobalSettings.scheduleWindowAutoScrollOffset) {
                      // GlobalContext.scheduleWindowScrollOffset += 5;
                      controller.jumpTo(controller.offset + 5);
                    } else if (details.localPosition.dy <
                        GlobalSettings.scheduleWindowAutoScrollOffset) {
                      // GlobalContext.scheduleWindowScrollOffset -= 5;
                      controller.jumpTo(controller.offset - 5);
                    }

                    // _syncVertScrollPos(details.localPosition.dy);

                    if (_resetConditions(details.delta.dy)) {
                      _resetSelection();
                      return;
                    }

                    // double offset = GlobalContext.scheduleWindowScrollOffset;
                    //widget._innerViewScrollController.offset;
                    // GlobalContext.scheduleWindowScrollOffset =
                    //     controller.offset;
                    double yMousePos =
                        details.localPosition.dy + controller.offset;
                    double xMousePos = _roundToVFrame(details.localPosition.dx);

                    if (_clampConditions(xMousePos, yMousePos)) {
                      return;
                    }

                    double ypos = _roundToHFrame(yMousePos);

                    if (GlobalContext.scheduleWindowSelectionBox == null) {
                      // stick to beginning of cells

                      if (_curYPos != ypos) {
                        _curYPos = ypos;
                        _curXPos = xMousePos;
                        GlobalContext.scheduleWindowSelectionBox =
                            Rect.fromLTWH(
                                _curXPos,
                                ypos,
                                GlobalContext.scheduleWindowCell.width,
                                GlobalStyle.scheduleCellHeightPx);

                        _animBackwards = false;
                        // _controller.reset();
                        // _controller.forward();
                      }
                      // else if (_initSelection == false) {
                      //   print("init $_curYPos $ypos");
                      //   _initSelection = true;
                      //   _curYPos = ypos;
                      // }
                    } else {
                      if (_curYPos != ypos) {
                        _curYPos = ypos;
                        _curXPos = xMousePos;
                        GlobalContext.scheduleWindowSelectionBox =
                            Rect.fromLTWH(
                                _curXPos,
                                GlobalContext.scheduleWindowSelectionBox!.top,
                                GlobalContext.scheduleWindowCell.width,
                                _curYPos +
                                    GlobalStyle.scheduleCellHeightPx -
                                    GlobalContext
                                        .scheduleWindowSelectionBox!.top);

                        _animBackwards = details.delta.dy < 0;
                        _controller.reset();
                        _animBackwards
                            ? _controller.reverse(from: 1)
                            : _controller.forward();
                      } else if (_curXPos != xMousePos) {
                        GlobalContext.scheduleWindowSelectionBox = GlobalContext
                            .scheduleWindowSelectionBox!
                            .translate(xMousePos - _curXPos, 0);
                        _curXPos = xMousePos;
                      }
                    }
                  });
                },
                onVerticalDragEnd: (details) {
                  setState(() {
                    _resetSelection();
                  });
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
                // print(
                //     "looool ${controller.offset} ${notification.metrics.pixels}");
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
