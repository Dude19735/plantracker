import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_date_bar.dart';
import 'package:scheduler/work_schedule_time_bar.dart';
import 'package:scheduler/work_schedule_entry.dart';
import 'package:scheduler/date.dart';
import 'package:scheduler/work_schedule_selection_overlay.dart';

class WorkScheduleInnerView extends StatefulWidget {
  final int _pageDaysOffset;
  WorkScheduleInnerView(this._pageDaysOffset);

  @override
  State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
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

class _WorkScheduleInnerView extends State<WorkScheduleInnerView>
    with SingleTickerProviderStateMixin {
  final double _topFrame = 0;
  final double _sideFrame = 0;

  late Animation<double> _animation;
  late AnimationController _controller;
  late double _curXPos;
  late double _curYPos;
  bool _animBackwards = false;
  late ScrollController _scrollController;
  bool _verticalDragging = false;
  WorkScheduleEntry? _currentEntry;

  _WorkScheduleInnerView();

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

  // double _roundToVFrame(double xval) {
  //   double xpos = (xval - _sideFrame - GlobalStyle.scheduleTimeBarWidth) -
  //       (xval - _sideFrame - GlobalStyle.scheduleTimeBarWidth) %
  //           (GlobalContext.scheduleWindowCell.width +
  //               GlobalStyle.scheduleGridStrokeWidth);

  //   return xpos;
  // }

  // double _roundToHFrame(double yval) {
  //   double yvalOffset = yval - _topFrame - GlobalStyle.scheduleDateBarHeight;
  //   double ypos = yvalOffset -
  //       yvalOffset %
  //           (GlobalStyle.scheduleCellHeightPx +
  //               GlobalStyle.scheduleGridStrokeWidth);

  //   return ypos;
  // }

  // bool _clampConditions(double xMousePos, double yMousePos) {
  //   return !GlobalContext.scheduleWindowInlineRect
  //       .contains(Offset(xMousePos, yMousePos));
  // }

  // void _autoScroll(double dy) {
  //   if (!_verticalDragging) return;

  //   double height = GlobalContext.scheduleWindowOutlineRect.height;
  //   if (dy > height + GlobalSettings.scheduleWindowAutoScrollOffset) {
  //     _scrollController.jumpTo(_scrollController.offset + 5);

  //     // this is more of an emergency solution than something usefull!
  //     // if (!_scrollController.position.atEdge) {
  //     //   Future<void>.delayed(Duration(milliseconds: 100))
  //     //       .then((value) => _autoScroll(dy + 5));
  //     // }
  //   } else if (dy < GlobalSettings.scheduleWindowAutoScrollOffset) {
  //     _scrollController.jumpTo(_scrollController.offset - 5);
  //   }
  // }

  // bool _resetSelection(double dy) {
  //   if (_resetConditions(dy)) {
  //     return true;
  //   }
  //   return false;
  // }

  // void _reset() {
  //   _controller.reset();
  //   GlobalContext.scheduleWindowSelectionBox = null;
  //   _curYPos = -1;
  //   _curXPos = -1;
  //   _animBackwards = false;
  // }

  // _SelectedBox _getSelectedTime() {
  //   double x = GlobalContext.scheduleWindowSelectionBox!.left;
  //   double y = GlobalContext.scheduleWindowSelectionBox!.top;
  //   double width = GlobalContext.scheduleWindowSelectionBox!.width;
  //   double height = GlobalContext.scheduleWindowSelectionBox!.height;

  //   double secondsFrom = y /
  //       (GlobalStyle.scheduleCellHeightPx +
  //           GlobalStyle.scheduleGridStrokeWidth) *
  //       GlobalSettings.scheduleBoxRangeS;

  //   double ch =
  //       GlobalStyle.scheduleCellHeightPx + GlobalStyle.scheduleGridStrokeWidth;
  //   double rHeight =
  //       ch * (height / ch).ceil() - GlobalStyle.scheduleGridStrokeWidth;

  //   double secondsTo = secondsFrom +
  //       (rHeight + GlobalStyle.scheduleGridStrokeWidth) /
  //           (GlobalStyle.scheduleCellHeightPx +
  //               GlobalStyle.scheduleGridStrokeWidth) *
  //           GlobalSettings.scheduleBoxRangeS;

  //   int yearOffset =
  //       (x / (width + GlobalStyle.scheduleGridStrokeWidth)).round();
  //   Date year = GlobalContext.fromDateWindow.addDays(yearOffset);

  //   return _SelectedBox(
  //       x + GlobalStyle.summaryCardMargin,
  //       y + GlobalStyle.summaryCardMargin,
  //       width,
  //       rHeight,
  //       secondsFrom,
  //       secondsTo,
  //       year.toInt());
  // }

  List<WorkScheduleEntry> _getEntries(BoxConstraints constraints) {
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;

    double sm = GlobalStyle.summaryCardMargin;
    int ws = from.absWindowSizeWith(to);
    double width =
        (constraints.maxWidth - GlobalStyle.scheduleTimeBarWidth - 2 * sm) / ws;

    List<WorkScheduleEntry> res = [];
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
          double x = dayOffset * width + sm;
          res.add(WorkScheduleEntry(x, y, width, height, e));
          // print("$dayOffset $x $y $width $height ${e.subjectId} ${e.date} $date");
        }
      }
    }

    return res;
  }

  WorkScheduleEntry? _getEntry(SelectionNotification notification) {
    if (GlobalContext.scheduleWindowSelectionBox == null) return null;
    if (GlobalContext.scheduleWindowSelectionBox!.height < 0) return null;

    var t = notification;
    // print(t.toString());
    // print(t["secondsFrom"]! / 60);
    return WorkScheduleEntry(t.x, t.y, t.width, t.height, null);
  }

  // bool _resetConditions(double dy) {
  //   bool reset = dy < 0 &&
  //       (GlobalContext.scheduleWindowSelectionBox == null ||
  //           GlobalContext.scheduleWindowSelectionBox!.height <
  //               GlobalStyle.scheduleCellHeightPx);

  //   return reset;
  // }

  // void _initSelection(double xpos, double ypos) {
  //   if (_curYPos != ypos) {
  //     _curYPos = ypos;
  //     _curXPos = xpos; //xMousePos;
  //     GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
  //         _curXPos,
  //         ypos,
  //         GlobalContext.scheduleWindowCell.width,
  //         GlobalStyle.scheduleCellHeightPx);

  //     _animBackwards = false;
  //     // _controller.reset();
  //     // _controller.forward();
  //   }
  // }

  // void _continueSelection(double xpos, double ypos, double dy) {
  //   if (_curYPos != ypos) {
  //     _curYPos = ypos;
  //     _curXPos = xpos; //xMousePos;
  //     GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
  //         _curXPos,
  //         GlobalContext.scheduleWindowSelectionBox!.top,
  //         GlobalContext.scheduleWindowCell.width,
  //         _curYPos +
  //             GlobalStyle.scheduleCellHeightPx -
  //             GlobalContext.scheduleWindowSelectionBox!.top);

  //     _animBackwards = dy < 0; // details.delta.dy < 0;
  //     _controller.reset();
  //     _animBackwards ? _controller.reverse(from: 1) : _controller.forward();
  //   } else if (_curXPos != xpos) {
  //     GlobalContext.scheduleWindowSelectionBox = GlobalContext
  //         .scheduleWindowSelectionBox!
  //         .translate(xpos - _curXPos, 0);
  //     _curXPos = xpos;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Debugger.workScheduleInnerView(
            " ========> rebuild work schedule inner view ${widget._pageDaysOffset} from ${GlobalContext.fromDateWindow.day} to ${GlobalContext.toDateWindow.day}");
        double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

        GlobalContext.scheduleWindowOutlineRect =
            Rect.fromLTRB(0, 0, constraints.maxWidth, constraints.maxHeight);

        GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
            0,
            GlobalStyle.scheduleDateBarHeight,
            constraints.maxWidth,
            GlobalStyle.scheduleCellHeightPx * numBoxes +
                //(numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth +
                GlobalStyle.scheduleDateBarHeight);

        _scrollController = ScrollController(
            initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
            keepScrollOffset: true);

        var innerView = Stack(children: [
          Container(
            margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
            width: constraints.maxWidth -
                GlobalStyle.scheduleTimeBarWidth -
                2 * GlobalStyle.summaryCardMargin,
            height: GlobalContext.scheduleWindowInlineRect.height,
            child: CustomPaint(painter: _GridPainter(context)),
          ),
          if (_currentEntry != null) _currentEntry!,
          for (var e in _getEntries(constraints)) e
        ]);

        // var view = GestureDetector(
        //     onVerticalDragUpdate: (details) {
        //       double localDy = details.localPosition.dy;
        //       double localDx = details.localPosition.dx;
        //       double ddy = details.delta.dy;
        //       setState(() {
        //         _verticalDragging = true;
        //         _autoScroll(localDy);

        //         if (_resetSelection(ddy)) return;

        //         double yMousePos = localDy + _scrollController.offset;
        //         double xMousePos = _roundToVFrame(localDx);

        //         if (_clampConditions(xMousePos, yMousePos)) return;

        //         double ypos = _roundToHFrame(yMousePos);
        //         if (GlobalContext.scheduleWindowSelectionBox == null) {
        //           _initSelection(xMousePos, ypos);
        //         } else {
        //           _continueSelection(xMousePos, ypos, ddy);
        //         }
        //       });
        //     },
        //     onVerticalDragEnd: (details) {
        //       setState(() {
        //         _verticalDragging = false;
        //         _currentEntry = _getEntry();
        //         // if (entry != null) _entries.add(entry);
        //         _reset();
        //       });
        //     },
        //     child:
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
                double xpos = 0;
                double ypos = 0;
                return Row(
                  children: [
                    WorkScheduleTimeBar(),
                    NotificationListener(
                      onNotification: (notification) {
                        if (notification is SelectionNotification) {
                          print("selection notification");
                          _currentEntry = _getEntry(notification);
                          setState(() {
                            _verticalDragging = false;
                          });
                          return true;
                        }
                        return false;
                      },
                      child: GestureDetector(
                        onTapDown: (details) {
                          setState(() {
                            _verticalDragging = true;
                            ypos = details.localPosition.dy;
                            xpos = details.localPosition.dx;
                          });
                        },
                        child: Stack(
                          children: [
                            if (_verticalDragging) innerView,
                            Container(
                                margin: EdgeInsets.all(
                                    GlobalStyle.summaryCardMargin),
                                child: WorkScheduleSelectionOverlay(
                                    _scrollController, xpos, ypos)),
                            if (!_verticalDragging) innerView,
                          ],
                        ),
                      ),
                    )
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
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();
  // Paint rectPainter = Paint();
  BuildContext _context;

  _GridPainter(this._context) {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = GlobalStyle.scheduleGridStrokeWidth;
    gridPainter.strokeCap = StrokeCap.round;

    // rectPainter.style = PaintingStyle.fill;
    // rectPainter.strokeWidth = 1;
    // rectPainter.color = GlobalStyle.scheduleSelectionColor(_context);
  }

  @override
  void paint(Canvas canvas, Size size) {
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

    // if (GlobalContext.scheduleWindowSelectionBox != null) {
    //   canvas.drawRect(GlobalContext.scheduleWindowSelectionBox!, rectPainter);
    // }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
