import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_date_bar.dart';
import 'package:scheduler/work_schedule_time_bar.dart';
import 'package:scheduler/work_schedule_entry.dart';
import 'package:scheduler/date.dart';

class WorkScheduleInnerView extends StatefulWidget {
  final int _pageDaysOffset;
  final BoxConstraints _constraints;
  WorkScheduleInnerView(this._pageDaysOffset, this._constraints);

  @override
  State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
}

class _WorkScheduleInnerView extends State<WorkScheduleInnerView> {
  late ScrollController _scrollController;
  // late List<WorkScheduleEntry> _container;

  List<List<WorkScheduleEntry>> _getEntries(double width) {
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;

    double sm = GlobalStyle.summaryCardMargin;

    List<List<WorkScheduleEntry>> entries = [];
    int oldDayOffset = -1;
    for (var d = from; d.compareTo(to) <= 0; d = d.addDays(1)) {
      int key = d.toInt();
      var week = GlobalContext.data.schedulePlanData.data[key];

      if (week != null) {
        for (var e in week) {
          double y = e.fromTime *
                  (GlobalStyle.scheduleCellHeightPx +
                      GlobalStyle.scheduleGridStrokeWidth) /
                  GlobalSettings.scheduleBoxRangeS +
              sm;

          double height = (e.toTime - e.fromTime) *
                  (GlobalStyle.scheduleCellHeightPx +
                      GlobalStyle.scheduleGridStrokeWidth) /
                  GlobalSettings.scheduleBoxRangeS -
              GlobalStyle.scheduleGridStrokeWidth;

          var date = Date.fromInt(e.date);
          int dayOffset = from.absDiff(date);
          if (dayOffset != oldDayOffset) {
            entries.add([WorkScheduleEntry(y, width, height, e)]);
          } else {
            entries.last.add(WorkScheduleEntry(y, width, height, e));
          }
          oldDayOffset = dayOffset;
        }
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController(
        initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
        keepScrollOffset: true);

    int ccsbx = GlobalContext.fromDateWindow
        .absWindowSizeWith(GlobalContext.toDateWindow);

    double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

    GlobalContext.scheduleWindowOutlineRect = Rect.fromLTRB(
        0, 0, widget._constraints.maxWidth, widget._constraints.maxHeight);

    GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
        0,
        GlobalStyle.scheduleDateBarHeight,
        widget._constraints.maxWidth,
        GlobalStyle.scheduleCellHeightPx * numBoxes +
            //(numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth +
            GlobalStyle.scheduleDateBarHeight);

    double boxWidth = (GlobalContext.scheduleWindowInlineRect.width -
            GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
        ccsbx;

    List<List<WorkScheduleEntry>> container = _getEntries(boxWidth);

    // _container = List<Container>.filled(
    //     ccsbx,
    //     Container(
    //         margin: EdgeInsets.only(
    //             left: GlobalStyle.summaryCardMargin,
    //             right: GlobalStyle.summaryCardMargin),
    //         width: boxWidth,
    //         height: 100,
    //         color: Colors.yellow));

    var view = CustomScrollView(controller: _scrollController, slivers: [
      SliverAppBar(
        pinned: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.black,
        // leadingWidth: GlobalStyle.scheduleTimeBarWidth +
        //     GlobalStyle.summaryCardMargin,
        // leading: Container(
        //     height: GlobalStyle.scheduleDateBarHeight,
        //     color: Colors.red),
        flexibleSpace: WorkScheduleDateBar(widget._pageDaysOffset),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Row(
              children: [
                WorkScheduleTimeBar(),
                Expanded(
                  child: Stack(
                    children: [
                      WorkScheduleGrid(
                          GlobalContext.scheduleWindowInlineRect.width),
                      WorkScheduleSelector(_scrollController),
                      Container(
                        margin: EdgeInsets.only(
                            left: GlobalStyle.summaryCardMargin,
                            right: GlobalStyle.summaryCardMargin),
                        child: Row(
                          children: [
                            for (var day in container)
                              Expanded(
                                child: Column(children: day),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // ),
              ],
            );
          },
          childCount: 1,
        ),
      )
    ]);

    return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            GlobalContext.scheduleWindowScrollOffset =
                notification.metrics.pixels;
            return true; // cut event propagation
          }
          return false;
        },
        child: view);
  }
}

class _SelectedBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final double secondsFrom;
  final double secondsTo;
  final int date;
  _SelectedBox(this.x, this.y, this.width, this.height, this.secondsFrom,
      this.secondsTo, this.date);

  @override
  String toString() {
    return "\nx: $x\ny: $y\nwidth: $width\nheight: $height\nsecondsFrom: $secondsFrom\nsecondsTo: $secondsTo\ndate: $date\n";
  }
}

// class _WorkScheduleInnerView2 extends State<WorkScheduleInnerView2> {
//   late ScrollController _scrollController;

//   _WorkScheduleInnerView2();

//   @override
//   Widget build(BuildContext context) {
//     // return
//     // LayoutBuilder(
//     //   builder: (BuildContext context, BoxConstraints constraints) {
//     print("rebuild inner view");
//     Debugger.workScheduleInnerView(
//         " ========> rebuild work schedule inner view ${widget._pageDaysOffset} from ${GlobalContext.fromDateWindow.day} to ${GlobalContext.toDateWindow.day}");
//     double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

//     GlobalContext.scheduleWindowOutlineRect = Rect.fromLTRB(
//         0, 0, widget._constraints.maxWidth, widget._constraints.maxHeight);

//     GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
//         0,
//         GlobalStyle.scheduleDateBarHeight,
//         widget._constraints.maxWidth,
//         GlobalStyle.scheduleCellHeightPx * numBoxes +
//             //(numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth +
//             GlobalStyle.scheduleDateBarHeight);

//     _scrollController = ScrollController(
//         initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
//         keepScrollOffset: true);

//     // if (_currentEntry != null) {
//     //   _currentEntry = _getEntry();
//     // }

//     var innerView = Stack(children: [
//       WorkScheduleGrid(widget._constraints.maxWidth),
//       // if (_currentEntry != null) _currentEntry!
//       // for (var e in _getEntries(constraints)) e
//     ]);

//     var view = GestureDetector(
//         onVerticalDragUpdate: (details) {
//           double localDy = details.localPosition.dy;
//           double localDx = details.localPosition.dx;
//           double ddy = details.delta.dy;
//           setState(() {
//             _verticalDragging = true;
//             _autoScroll(localDy);

//             if (_resetSelection(ddy)) return;

//             double yMousePos = localDy + _scrollController.offset;
//             double xMousePos = _roundToVFrame(localDx);

//             if (_clampConditions(xMousePos, yMousePos)) return;

//             double ypos = _roundToHFrame(yMousePos);
//             if (GlobalContext.scheduleWindowSelectionBox == null) {
//               _initSelection(xMousePos, ypos);
//             } else {
//               _continueSelection(xMousePos, ypos, ddy);
//             }
//           });
//         },
//         onVerticalDragEnd: (details) {
//           setState(() {
//             _verticalDragging = false;
//             _currentEntry = _getEntry();
//             // if (entry != null) _entries.add(entry);
//             _reset();
//           });
//         },
//         child: CustomScrollView(controller: _scrollController, slivers: [
//           SliverAppBar(
//             pinned: true,
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             surfaceTintColor: Colors.transparent,
//             foregroundColor: Colors.transparent,
//             shadowColor: Colors.black,
//             // leadingWidth: GlobalStyle.scheduleTimeBarWidth +
//             //     GlobalStyle.summaryCardMargin,
//             // leading: Container(
//             //     height: GlobalStyle.scheduleDateBarHeight,
//             //     color: Colors.red),
//             flexibleSpace: WorkScheduleDateBar(widget._pageDaysOffset),
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 return Row(
//                   children: [
//                     WorkScheduleTimeBar(),
//                     innerView,
//                   ],
//                 );
//               },
//               childCount: 1,
//             ),
//           )
//         ]));

//     return NotificationListener(
//         onNotification: (notification) {
//           if (notification is ScrollNotification) {
//             GlobalContext.scheduleWindowScrollOffset =
//                 notification.metrics.pixels;
//             return true; // cut event propagation
//           }
//           return false;
//         },
//         child: view);
//     //   },
//     // );
//   }
// }

class WorkScheduleSelector extends StatefulWidget {
  // final int _pageDaysOffset;
  // final BoxConstraints _constraints;
  final ScrollController _scrollController;
  WorkScheduleSelector(this._scrollController);

  @override
  State<WorkScheduleSelector> createState() => _WorkScheduleSelector();
}

class _WorkScheduleSelector extends State<WorkScheduleSelector>
    with SingleTickerProviderStateMixin {
  final double _topFrame = 0;
  final double _sideFrame = 0;

  late Animation<double> _animation;
  late AnimationController _controller;
  late double _curXPos;
  late double _curYPos;
  bool _animBackwards = false;
  bool _verticalDragging = false;
  WorkScheduleEntry? _currentEntry;

  double _roundToVFrame(double xval) {
    double xpos = (xval - _sideFrame - GlobalStyle.scheduleTimeBarWidth) -
        (xval - _sideFrame - GlobalStyle.scheduleTimeBarWidth) %
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
    return !GlobalContext.scheduleWindowInlineRect
        .contains(Offset(xMousePos, yMousePos));
  }

  void _autoScroll(double dy) {
    if (!_verticalDragging) return;

    double height = GlobalContext.scheduleWindowOutlineRect.height;
    if (dy > height + GlobalSettings.scheduleWindowAutoScrollOffset) {
      widget._scrollController.jumpTo(widget._scrollController.offset + 5);

      // this is more of an emergency solution than something usefull!
      // if (!_scrollController.position.atEdge) {
      //   Future<void>.delayed(Duration(milliseconds: 100))
      //       .then((value) => _autoScroll(dy + 5));
      // }
    } else if (dy < GlobalSettings.scheduleWindowAutoScrollOffset) {
      widget._scrollController.jumpTo(widget._scrollController.offset - 5);
    }
  }

  bool _resetSelection(double dy) {
    if (_resetConditions(dy)) {
      return true;
    }
    return false;
  }

  void _reset() {
    _controller.reset();
    GlobalContext.scheduleWindowSelectionBox = null;
    _curYPos = -1;
    _curXPos = -1;
    _animBackwards = false;
  }

  _SelectedBox _getSelectedTime() {
    double x = GlobalContext.scheduleWindowSelectionBox!.left;
    double y = GlobalContext.scheduleWindowSelectionBox!.top;
    double width = GlobalContext.scheduleWindowSelectionBox!.width;
    double height = GlobalContext.scheduleWindowSelectionBox!.height;

    double secondsFrom = y /
        (GlobalStyle.scheduleCellHeightPx +
            GlobalStyle.scheduleGridStrokeWidth) *
        GlobalSettings.scheduleBoxRangeS;

    double ch =
        GlobalStyle.scheduleCellHeightPx + GlobalStyle.scheduleGridStrokeWidth;
    double rHeight =
        ch * (height / ch).ceil() - GlobalStyle.scheduleGridStrokeWidth;

    double secondsTo = secondsFrom +
        (rHeight + GlobalStyle.scheduleGridStrokeWidth) /
            (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth) *
            GlobalSettings.scheduleBoxRangeS;

    int yearOffset =
        (x / (width + GlobalStyle.scheduleGridStrokeWidth)).round();
    Date year = GlobalContext.fromDateWindow.addDays(yearOffset);

    return _SelectedBox(
        x + GlobalStyle.summaryCardMargin,
        y + GlobalStyle.summaryCardMargin,
        width,
        rHeight,
        secondsFrom,
        secondsTo,
        year.toInt());
  }

  WorkScheduleEntry? _getEntry() {
    if (GlobalContext.scheduleWindowSelectionBox == null) return null;
    if (GlobalContext.scheduleWindowSelectionBox!.height < 0) return null;

    var t = _getSelectedTime();
    // print(t.toString());
    // print(t["secondsFrom"]! / 60);
    return WorkScheduleEntry(t.y, t.width, t.height, null);
  }

  bool _resetConditions(double dy) {
    bool reset = dy < 0 &&
        (GlobalContext.scheduleWindowSelectionBox == null ||
            GlobalContext.scheduleWindowSelectionBox!.height <
                GlobalStyle.scheduleCellHeightPx);

    return reset;
  }

  void _initSelection(double xpos, double ypos) {
    if (_curYPos != ypos) {
      _curYPos = ypos;
      _curXPos = xpos; //xMousePos;
      GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
          _curXPos,
          ypos,
          GlobalContext.scheduleWindowCell.width,
          GlobalStyle.scheduleCellHeightPx);

      _animBackwards = false;
      // _controller.reset();
      // _controller.forward();
    }
  }

  void _continueSelection(double xpos, double ypos, double dy) {
    if (_curYPos != ypos) {
      _curYPos = ypos;
      _curXPos = xpos; //xMousePos;
      GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
          _curXPos,
          GlobalContext.scheduleWindowSelectionBox!.top,
          GlobalContext.scheduleWindowCell.width,
          _curYPos +
              GlobalStyle.scheduleCellHeightPx -
              GlobalContext.scheduleWindowSelectionBox!.top);

      _animBackwards = dy < 0; // details.delta.dy < 0;
      _controller.reset();
      _animBackwards ? _controller.reverse(from: 1) : _controller.forward();
    } else if (_curXPos != xpos) {
      GlobalContext.scheduleWindowSelectionBox = GlobalContext
          .scheduleWindowSelectionBox!
          .translate(xpos - _curXPos, 0);
      _curXPos = xpos;
    }
  }

  @override
  void initState() {
    super.initState();
    _curXPos = -1;
    _curYPos = -1;
    _controller = AnimationController(
        duration:
            Duration(milliseconds: GlobalSettings.animationScheduleSelectorMS),
        vsync: this);
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

  @override
  Widget build(BuildContext context) {
    var view = GestureDetector(
        onVerticalDragUpdate: (details) {
          double localDy = details.localPosition.dy;
          double localDx = details.localPosition.dx;
          double ddy = details.delta.dy;
          setState(() {
            print("drag update");
            _verticalDragging = true;
            // _autoScroll(localDy);

            if (_resetSelection(ddy)) return;

            double yMousePos = localDy + widget._scrollController.offset;
            double xMousePos = _roundToVFrame(localDx);

            if (_clampConditions(xMousePos, yMousePos)) return;

            double ypos = _roundToHFrame(yMousePos);
            if (GlobalContext.scheduleWindowSelectionBox == null) {
              _initSelection(xMousePos, ypos);
            } else {
              _continueSelection(xMousePos, ypos, ddy);
            }
          });
        },
        onVerticalDragEnd: (details) {
          setState(() {
            print("drag end");
            _verticalDragging = false;
            _currentEntry = _getEntry();
            // if (entry != null) _entries.add(entry);
            _reset();
          });
        },
        child: Container(
            margin: EdgeInsets.only(
                left: GlobalStyle.summaryCardMargin,
                right: GlobalStyle.summaryCardMargin),
            width: GlobalContext.scheduleWindowInlineRect.width,
            height: GlobalContext.scheduleWindowInlineRect.height,
            color: Colors.green.withAlpha(128)));

    return view;
  }
}

// #########################################################################################3

class WorkScheduleGrid extends StatelessWidget {
  final double _maxWidth;

  WorkScheduleGrid(this._maxWidth);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
      width: _maxWidth -
          GlobalStyle.scheduleTimeBarWidth -
          2 * GlobalStyle.summaryCardMargin,
      height: GlobalContext.scheduleWindowInlineRect.height,
      child: CustomPaint(painter: _GridPainter(context)),
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();
  Paint rectPainter = Paint();
  BuildContext _context;

  _GridPainter(this._context) {
    backgroundPainter.color = GlobalStyle.scheduleBackgroundColor(_context);
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = GlobalStyle.scheduleGridStrokeWidth;
    gridPainter.strokeCap = StrokeCap.round;

    rectPainter.style = PaintingStyle.fill;
    rectPainter.strokeWidth = 1;
    rectPainter.color = GlobalStyle.scheduleSelectionColor(_context);
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("paint canvas");
    int ccsbx = GlobalContext.fromDateWindow
        .absWindowSizeWith(GlobalContext.toDateWindow);

    double boxWidth =
        (size.width - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    double xOffset = boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;
    gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
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
        gridPainter.color = GlobalStyle.scheduleGridColorFullHour(_context);
      } else {
        gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
      }
      canvas.drawLine(
          Offset(0, yOffset), Offset(size.width, yOffset), gridPainter);
      counter++;
      yOffset += GlobalStyle.scheduleGridStrokeWidth +
          GlobalStyle.scheduleCellHeightPx;
    }

    if (GlobalContext.scheduleWindowSelectionBox != null) {
      canvas.drawRect(GlobalContext.scheduleWindowSelectionBox!, rectPainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
