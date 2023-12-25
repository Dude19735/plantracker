import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_schedule_date_bar.dart';
import 'package:scheduler/work_schedule_time_bar.dart';
import 'package:scheduler/work_schedule_entry.dart';
import 'package:scheduler/date.dart';

class WorkScheduleInnerView extends StatefulWidget {
  // final int _pageDaysOffset;
  final BoxConstraints _constraints;
  final Date _fromDate;
  final Date _toDate;
  WorkScheduleInnerView(this._fromDate, this._toDate, this._constraints);

  @override
  State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
}

class _WorkScheduleInnerView extends State<WorkScheduleInnerView> {
  late ScrollController _scrollController;
  // late List<WorkScheduleEntry> _container;

  List<List<WorkScheduleEntry>> _getEntries(double width) {
    var from = widget._fromDate;
    var to = widget._toDate;

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
            entries.add([WorkScheduleEntry(0, y, width, height, e)]);
          } else {
            entries.last.add(WorkScheduleEntry(0, y, width, height, e));
          }
          oldDayOffset = dayOffset;
        }
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    // print("build boxes ${widget._fromDate} - ${widget._toDate}");
    _scrollController = ScrollController(
        initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
        keepScrollOffset: true);

    int ccsbx = widget._fromDate.absWindowSizeWith(widget._toDate);

    double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

    GlobalContext.scheduleWindowOutlineRect = Rect.fromLTRB(
        0,
        0,
        widget._constraints.maxWidth,
        widget._constraints.maxHeight -
            GlobalStyle.scheduleDateBarHeight +
            2 * GlobalStyle.summaryCardMargin);

    GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
        0,
        0,
        widget._constraints.maxWidth,
        (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth) *
            numBoxes);
    //(numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth +
    // GlobalStyle.scheduleDateBarHeight);

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
        flexibleSpace: WorkScheduleDateBar(widget._fromDate, widget._toDate),
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
                          GlobalContext.scheduleWindowInlineRect.width,
                          widget._fromDate,
                          widget._toDate),
                      WorkScheduleSelector(
                          _scrollController, widget._fromDate, widget._toDate),
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
      ),
      // )
    ]);

    return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            // print("get scroll notification  ${notification.metrics.pixels}");
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

class WorkScheduleSelector extends StatefulWidget {
  // final int _pageDaysOffset;
  // final BoxConstraints _constraints;
  final ScrollController _scrollController;
  final Date _fromDate;
  final Date _toDate;
  WorkScheduleSelector(this._scrollController, this._fromDate, this._toDate);

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
    double xpos = (xval - _sideFrame) -
        (xval - _sideFrame) %
            (GlobalContext.scheduleWindowCell.width +
                GlobalStyle.scheduleGridStrokeWidth) +
        GlobalStyle.summaryCardMargin;

    return xpos;
  }

  double _roundToHFrame(double yval) {
    double yvalOffset = yval - _topFrame;
    double ypos = yvalOffset -
        yvalOffset %
            (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth) +
        GlobalStyle.summaryCardMargin;

    return ypos;
  }

  bool _clampConditions(double xMousePos, double yMousePos) {
    return !GlobalContext.scheduleWindowInlineRect
        .contains(Offset(xMousePos, yMousePos));
  }

  void _autoScroll(double dy) {
    if (!_verticalDragging) return;

    double diff = GlobalContext.scheduleWindowOutlineRect.height - dy;
    if (diff < GlobalStyle.scheduleCellHeightPx) {
      widget._scrollController.jumpTo(
          widget._scrollController.offset + GlobalStyle.scheduleCellHeightPx);
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
    Date year = widget._fromDate.addDays(yearOffset);

    return _SelectedBox(
        x, y, width, rHeight, secondsFrom, secondsTo, year.toInt());
  }

  WorkScheduleEntry? _getEntry() {
    if (GlobalContext.scheduleWindowSelectionBox == null) return null;
    if (GlobalContext.scheduleWindowSelectionBox!.height < 0) return null;

    var t = _getSelectedTime();
    // print(t.toString());
    // print(t["secondsFrom"]! / 60);
    return WorkScheduleEntry(t.x, t.y, t.width, t.height, null);
  }

  bool _resetConditions(double dy) {
    bool reset = dy < 0 &&
        (GlobalContext.scheduleWindowSelectionBox == null ||
            GlobalContext.scheduleWindowSelectionBox!.height <
                GlobalStyle.scheduleCellHeightPx);

    return reset;
  }

  void _initSelection(double xpos, double ypos) {
    // if (_curYPos != ypos) {
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
    // }
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
        behavior: HitTestBehavior.opaque,
        // onDoubleTapDown: (details) => print("Double Tap Down"),
        onTapDown: (details) {
          GlobalContext.scheduleWindowSelectionBox = null;
          _currentEntry = null;

          _verticalDragging = true;
          double localDy = details.localPosition.dy;
          double localDx = details.localPosition.dx;
          setState(() {
            // print("drag update");

            double yMousePos = localDy; // + widget._scrollController.offset;
            double xMousePos = _roundToVFrame(localDx);

            if (_clampConditions(xMousePos, yMousePos)) return;

            double ypos = _roundToHFrame(yMousePos);
            _initSelection(xMousePos, ypos);
          });
        },
        onVerticalDragUpdate: (details) {
          double localDy = details.localPosition.dy;
          double localDx = details.localPosition.dx;
          double ddy = details.delta.dy;
          if (_verticalDragging) {
            setState(() {
              // print("drag update");

              _autoScroll(localDy - widget._scrollController.offset);

              if (_resetSelection(ddy)) return;

              double yMousePos = localDy; // + widget._scrollController.offset;
              double xMousePos = _roundToVFrame(localDx);

              if (_clampConditions(xMousePos, yMousePos)) return;

              double ypos = _roundToHFrame(yMousePos);
              _continueSelection(xMousePos, ypos, ddy);
            });
          } else {
            // print(widget._scrollController.offset);

            widget._scrollController
                .jumpTo(widget._scrollController.offset - ddy);
          }
        },
        onVerticalDragEnd: (details) {
          if (_verticalDragging) {
            setState(() {
              // print("drag end");
              _verticalDragging = false;
              _currentEntry = _getEntry();
              // if (entry != null) _entries.add(entry);
              _reset();
            });
          }
        },
        child: Stack(children: [
          Container(
              margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
              width: GlobalContext.scheduleWindowInlineRect.width,
              height: GlobalContext.scheduleWindowInlineRect.height,
              color: Colors.transparent),
          if (GlobalContext.scheduleWindowSelectionBox != null &&
              GlobalContext.scheduleWindowSelectionBox!.height > 0)
            Transform(
                transform: Matrix4.translationValues(
                    GlobalContext.scheduleWindowSelectionBox!.left,
                    GlobalContext.scheduleWindowSelectionBox!.top,
                    0),
                child: Container(
                  color: GlobalStyle.scheduleSelectionColor(context),
                  height: GlobalContext.scheduleWindowSelectionBox!.height,
                  width: GlobalContext.scheduleWindowSelectionBox!.width,
                )),
          if (_currentEntry != null) _currentEntry!
        ]));

    return view;
  }
}

// #########################################################################################3

class WorkScheduleGrid extends StatelessWidget {
  final double _maxWidth;
  final Date _fromDate;
  final Date _toDate;

  WorkScheduleGrid(this._maxWidth, this._fromDate, this._toDate);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
      width: _maxWidth -
          GlobalStyle.scheduleTimeBarWidth -
          2 * GlobalStyle.summaryCardMargin,
      height: GlobalContext.scheduleWindowInlineRect.height,
      child: CustomPaint(painter: _GridPainter(context, _fromDate, _toDate)),
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();
  Paint rectPainter = Paint();
  final Date _fromDate;
  final Date _toDate;
  BuildContext _context;

  _GridPainter(this._context, this._fromDate, this._toDate) {
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
    // print("paint canvas");
    int ccsbx = _fromDate.absWindowSizeWith(_toDate);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class SelectorPainter extends StatelessWidget {
  final double _maxWidth;
  final Date _fromDate;
  final Date _toDate;

  SelectorPainter(this._maxWidth, this._fromDate, this._toDate);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
      width: _maxWidth -
          GlobalStyle.scheduleTimeBarWidth -
          2 * GlobalStyle.summaryCardMargin,
      height: GlobalContext.scheduleWindowInlineRect.height,
      child: CustomPaint(painter: _GridPainter(context, _fromDate, _toDate)),
    );
  }
}
