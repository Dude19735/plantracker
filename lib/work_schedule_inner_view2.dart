import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_schedule_date_bar.dart';
import 'package:scheduler/work_schedule_time_bar.dart';
import 'package:scheduler/work_schedule_planed_entry.dart';
import 'package:scheduler/work_schedule_recorded_entry.dart';
import 'package:scheduler/work_schedule_subject_entry.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/date.dart';

class BeginDraggingNotification extends Notification {}

class EndDraggingNotification extends Notification {}

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
  final double _sm = GlobalStyle.summaryCardMargin;
  final double _sw = GlobalStyle.scheduleGridStrokeWidth;
  final double _pxPerSecond =
      (GlobalStyle.scheduleCellHeightPx + GlobalStyle.scheduleGridStrokeWidth) /
          GlobalSettings.scheduleBoxRangeS;
  // late List<WorkScheduleEntry> _container;

  Map<
          String,
          Function(
              double x, double y, double width, double height, Object? data)>
      _entryFactory = {
    (WorkSchedulePlanedEntry).toString(): (double x, double y, double width,
            double height, Object? data) =>
        WorkSchedulePlanedEntry(x, y, width, height, data as SchedulePlanData?),
    (WorkScheduleRecordedEntry).toString():
        (double x, double y, double width, double height, Object? data) =>
            WorkScheduleRecordedEntry(
                x, y, width, height, data as ScheduleRecordedData?)
  };

  MapEntry<double, double> _getFromTo(double fromTime, double toTime) {
    double fromPx = fromTime * _pxPerSecond + _sm - _sw;
    double toPx = toTime * _pxPerSecond + _sm;

    return MapEntry(fromPx, toPx);
  }

  List<Widget> _getColumns(int num, double width, double height) {
    double spacerWidth = 5;
    double entryWidth = width - spacerWidth;
    var container = _getEntries<WorkSchedulePlanedEntry>(
        0.65 * entryWidth, 0, GlobalContext.data.schedulePlanData.data);
    var subjects = _getSubjectBars(0.09 * entryWidth, 0.69 * entryWidth,
        GlobalContext.data.scheduleRecordedData.data);
    var records = _getEntries<WorkScheduleRecordedEntry>(0.21 * entryWidth,
        0.69 * entryWidth, GlobalContext.data.scheduleRecordedData.data);

    List<Widget> res = [];
    for (int i = 0; i < num; ++i) {
      res.add(Expanded(
        child: Stack(children: [
          // Container(
          //   height: height,
          // ),
          container[i] == null ? Column() : Column(children: container[i]!),
          // subjects[i] == null ? Column() : Column(children: subjects[i]!),
          records[i] == null ? Column() : Column(children: records[i]!),
        ]),
      ));
      res.add(
        Container(color: Colors.green, width: spacerWidth),
      );
    }

    return res;
  }

  Map<int, List<WorkScheduleSubjectEntry>> _getSubjectBars(
      double width, double xOffset, Map<int, List<ScheduleRecordedData>> data) {
    var from = widget._fromDate;
    var to = widget._toDate;

    Map<int, List<double>> recordLimits = {};
    Map<int, List<int>> recordLimitSubjects = {};
    List<List<ScheduleRecordedData>> entryData = [];
    for (var d = from; d.compareTo(to) <= 0; d = d.addDays(1)) {
      int key = d.toInt();
      var record = data[key];
      // MapEntry<double, double> lastPx = MapEntry(0.0, 0.0);
      if (record != null) {
        List<double> entries = [];
        List<int> subjectIds = [];
        List<ScheduleRecordedData> eData = [];
        // int oldSubjectId = record.first.subject.subjectId;
        // var date = Date.fromInt(record.first.date);
        // int dayOffset = from.absDiff(date);
        // var px = _getFromTo(record.first.fromTime, record.first.toTime);

        // Rect? next = Rect.fromLTWH(xOffset, px.key, width, 0);
        for (var e in record) {
          //   // px.value - px.key - lastHeight, record.first);
          //   date = Date.fromInt(e.date);
          //   dayOffset = from.absDiff(date);
          int subjectId = e.subject.subjectId;
          var px = _getFromTo(e.fromTime, e.toTime);

          if (subjectIds.isNotEmpty &&
              subjectIds.last == subjectId &&
              px.key - entries.last < 5) {
            entries.removeLast();
            entries.add(px.value);
          } else {
            if (subjectIds.isNotEmpty) {
              entryData.add(eData);
              eData = [];
            }
            subjectIds.add(subjectId);
            entries.add(px.key);
            entries.add(px.value);
          }
          eData.add(e);

          //   if (next == null) {
          //     next = Rect.fromLTWH(
          //         xOffset, px.key - lastHeight, width, px.value - px.key);
          //   } else {
          //     next = Rect.fromLTWH(next.left, next.top, next.width,
          //         next.height + (px.value - px.key));
          //   }
          //   if (subjectId != oldSubjectId ||
          //       px.key > lastPx.value + 60 * _pxPerSecond && lastPx.value > 0) {
          //     if (records.keys.contains(dayOffset)) {
          //       records[dayOffset]!.add(WorkScheduleSubjectEntry.fromRect(next));
          //     } else {
          //       records[dayOffset] = [WorkScheduleSubjectEntry.fromRect(next)];
          //     }
          //     lastHeight += next.height;
          //     next = null;
          //   }
          //   lastPx = px;
          //   oldSubjectId = subjectId;
          // print("hello world");
        }

        if (entries.isNotEmpty) {
          recordLimits[key] = entries;
        }
        if (subjectIds.isNotEmpty) {
          recordLimitSubjects[key] = subjectIds;
        }
        if (eData.isNotEmpty) {
          entryData.add(eData);
        }

        // print("hello world");

        // if (next != null) {
        //   if (records.keys.contains(dayOffset)) {
        //     records[dayOffset]!.add(WorkScheduleSubjectEntry.fromRect(next));
        //   } else {
        //     records[dayOffset] = [WorkScheduleSubjectEntry.fromRect(next)];
        //   }
        //   next = null;
        // }
      }
    }

    int eInd = 0;
    Map<int, List<WorkScheduleSubjectEntry>> records = {};
    for (var day in recordLimits.entries) {
      var date = Date.fromInt(day.key);
      int dayOffset = from.absDiff(date);
      if (!records.containsKey(day.key)) {
        records[dayOffset] = [];
      }

      double lastHeight = 0;
      var recList = day.value;
      for (int i = 1; i < recList.length; i += 2) {
        records[dayOffset]!.add(WorkScheduleSubjectEntry(
            xOffset,
            recList[i - 1] - lastHeight,
            width,
            recList[i] - recList[i - 1],
            entryData[eInd]));
        lastHeight += recList[i] - recList[i - 1];
        eInd++;
      }

      // var e = record.first;
      // var date = Date.fromInt(e.date);
      // int dayOffset = from.absDiff(date);
      // var px = _getFromTo(e.fromTime, e.toTime);
      // records[dayOffset] = [
      //   WorkScheduleSubjectEntry(xOffset, px.key, width, 200, e)
      // ];
      // int oldDayOffset = -1;
      // int oldSubjectId = record.first.subject.subjectId;
      // double fullHeight = 0;
      // for (var e in record) {
      //   var date = Date.fromInt(e.date);
      // int dayOffset = from.absDiff(date);
      // int subjectInd = e.subject.subjectId;
      //   var px = _getFromTo(e.fromTime, e.toTime);

      // if (oldSubjectId != subjectInd) {
      //   if (oldDayOffset != dayOffset) {
      //     records[dayOffset] = [
      //       WorkScheduleSubjectEntry(0, px.key, width, fullHeight, e)
      //     ];
      //   } else {
      //     records[dayOffset]!.add(WorkScheduleSubjectEntry(
      //         0, px.key - lastHeight, width, fullHeight, e));
      //   }
      //   fullHeight = 0;
      // } else {
      //   fullHeight += px.value - px.key;
      // }

      // double height = px.value - px.key;
      // if (dayOffset != oldDayOffset || subjectInd != oldSubject) {
      //   lastHeight = 0;
      //   fullHeight = height;
      //   records[dayOffset] = [
      //     WorkScheduleSubjectEntry(0, px.key, width, height, e)
      //   ];
      // } else {
      //   fullHeight += height;
      //   records[dayOffset]!.add(WorkScheduleSubjectEntry(
      //       0, px.key - lastHeight, width, height, e));
      // }
      // oldSubjectId = subjectInd;
      // oldDayOffset = dayOffset;
      // oldSubject = subjectInd;
      // lastHeight += height;
      // }
      // }
    }

    return records;
  }

  Map<int, List<T>> _getEntries<T>(
      double width, double xOffset, Map<int, List<ScheduleData>> data) {
    var from = widget._fromDate;
    var to = widget._toDate;

    Map<int, List<T>> records = {};
    double lastHeight = 0;
    for (var d = from; d.compareTo(to) <= 0; d = d.addDays(1)) {
      int key = d.toInt();

      var record = data[key];
      int oldDayOffset = -1;
      if (record != null) {
        for (var e in record) {
          var px = _getFromTo(e.fromTime, e.toTime);

          var date = Date.fromInt(e.date);
          double height = px.value - px.key;
          int dayOffset = from.absDiff(date);
          if (dayOffset != oldDayOffset) {
            lastHeight = 0;
            records[dayOffset] = [
              _entryFactory[T.toString()]!(xOffset, px.key, width, height, e)
                  as T
            ];
          } else {
            records[dayOffset]!.add(_entryFactory[T.toString()]!(
                xOffset, px.key - lastHeight, width, height, e) as T);
          }
          oldDayOffset = dayOffset;
          lastHeight += height;
        }
      }
    }

    return records;
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

    // double boxWidth = (GlobalContext.scheduleWindowInlineRect.width -
    //         GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
    //     ccsbx;

    double boxWidth = GlobalContext.scheduleWindowInlineRect.width / ccsbx;

    var columns = _getColumns(
        ccsbx, boxWidth, GlobalContext.scheduleWindowInlineRect.height);

    // int width = container.length;
    // List<Container> columns = [
    //   for (int i = 0; i < width; i++)
    //     Container(width: 50, height: 100, color: Color(i * 20))
    // ];

    // List<Expanded> entries = [];
    // for (int dInd = 0; dInd < ccsbx; dInd++) {
    //   entries.add(Expanded(
    //       child: container[dInd] == null
    //           ? Column()
    //           : Column(children: container[dInd]!)));

    // entries.add(Expanded(
    //   child:
    //       records[dInd] == null ? Column() : Column(children: records[dInd]!),
    // ));
    // }

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
            return Row(children: [
              WorkScheduleTimeBar(),
              Expanded(
                  child: Stack(
                children: [
                  WorkScheduleGrid(GlobalContext.scheduleWindowInlineRect.width,
                      widget._fromDate, widget._toDate),
                  WorkScheduleSelector(
                      _scrollController, widget._fromDate, widget._toDate),
                  Container(
                    margin: EdgeInsets.only(
                        left: GlobalStyle.summaryCardMargin,
                        right: GlobalStyle.summaryCardMargin),
                    child: Row(
                      children: columns,
                    ),
                  ),
                ],
              ))
            ]);
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
  bool _collision = false;

  late Animation<double> _animation;
  late AnimationController _controller;
  late double _curXPos;
  late double _curYPos;
  bool _animBackwards = false;
  bool _verticalDragging = false;
  WorkSchedulePlanedEntry? _currentEntry;

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

  int _getDayIndex(double xMousePos) {
    double day = xMousePos /
        (GlobalContext.scheduleWindowCell.width +
            GlobalStyle.scheduleGridStrokeWidth);
    // print(day);
    return day.floor();
  }

  bool _clampConditions(double xMousePos, double yMousePos) {
    _collision = true;
    bool b = !GlobalContext.scheduleWindowInlineRect
        .contains(Offset(xMousePos, yMousePos));
    if (b) return true;

    // print("${xMousePos} ${_getDayIndex(xMousePos)}");
    // var day = widget._container[_getDayIndex(xMousePos)];
    // if (day != null) {
    //   for (var c in day) {
    //     if (yMousePos >= c.y1() && yMousePos <= c.y2()) {
    //       return true;
    //     }
    //   }
    // }

    _collision = false;
    return false;
  }

  bool _autoScroll(double delta, double dy) {
    if (!_verticalDragging) return false;
    // double jumpHeight = GlobalContext.scheduleWindowOutlineRect.height / 2;

    // jump backwards ever? maybe no?...
    // if (dy < GlobalSettings.workScheduleAutoScrollHeightTop && delta < 0) {
    //   widget._scrollController
    //       .jumpTo(widget._scrollController.offset - jumpHeight);
    // }

    // accelerate forwards speed...
    double diff = GlobalContext.scheduleWindowOutlineRect.height - dy;
    if (diff < GlobalSettings.workScheduleAutoScrollHeightTop) {
      print("################################### truetruetrue");
      print("################################################");
    }
    if (diff < GlobalSettings.workScheduleAutoScrollHeightTop && delta > 0) {
      return true;
      // widget._scrollController
      //     .jumpTo(widget._scrollController.offset + 10);
      // return 10;
    }

    return false;
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

  WorkSchedulePlanedEntry? _getEntry() {
    if (GlobalContext.scheduleWindowSelectionBox == null) return null;
    if (GlobalContext.scheduleWindowSelectionBox!.height < 0) return null;

    var t = _getSelectedTime();
    // print(t.toString());
    // print(t["secondsFrom"]! / 60);
    return WorkSchedulePlanedEntry(t.x, t.y, t.width, t.height, null);
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
    // _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear)
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

          // print("vertical drag start");
          _verticalDragging = true;
          BeginDraggingNotification().dispatch(context);

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
        onTapUp: (details) {
          _verticalDragging = false;
          EndDraggingNotification().dispatch(context);

          // _currentEntry = _getEntry();
          // if (entry != null) _entries.add(entry);
          _reset();
        },
        onVerticalDragUpdate: (details) {
          // vertical scroll offset delta
          double ddy = details.delta.dy;
          if (_verticalDragging) {
            setState(() {
              // print("drag update");

              if (_resetSelection(ddy)) return;

              double localDy = details.localPosition.dy;
              double localDx = details.localPosition.dx;
              // print(widget._scrollController.offset);
              print(
                  "$_topFrame ${details.localPosition} ${details.globalPosition}");
              // print(
              //     "localDy: $localDy, ddy: $ddy, localDy - widget._scrollController.offset: ${localDy - widget._scrollController.offset}");
              if (_autoScroll(ddy, localDy - widget._scrollController.offset)) {
                widget._scrollController
                    .jumpTo(widget._scrollController.offset + 10);
                // localDy += 10;
                // print("autoscroll");
              }
              // print("localDy: $localDy, ddy: $ddy");
              // ddy -= jumpDy;
              // print("$localDy ${widget._scrollController.offset}");

              double yMousePos = localDy; // + widget._scrollController.offset;
              double xMousePos = _roundToVFrame(localDx);

              if (_clampConditions(xMousePos, yMousePos)) return;
              // print("$localDy");
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
              EndDraggingNotification().dispatch(context);

              // _currentEntry = _getEntry();
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
                  color:
                      GlobalStyle.scheduleSelectionColor(context, _collision),
                  height: GlobalContext.scheduleWindowSelectionBox!.height,
                  width: GlobalContext.scheduleWindowSelectionBox!.width,
                )),
          if (_currentEntry != null) _currentEntry!
        ]));

    // print(GlobalContext.scheduleWindowOutlineRect);
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

    // rectPainter.style = PaintingStyle.fill;
    // rectPainter.strokeWidth = 1;
    // rectPainter.color = GlobalStyle.scheduleSelectionColor(_context);
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
