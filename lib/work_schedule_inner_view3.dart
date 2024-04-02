import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_schedule_date_bar.dart';
import 'package:scheduler/work_schedule_time_bar.dart';
import 'package:scheduler/work_schedule_grid.dart';
import 'package:scheduler/work_schedule_planed_entry.dart';
import 'package:scheduler/work_schedule_recorded_entry.dart';
import 'package:scheduler/work_schedule_subject_entry.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/date.dart';

class BeginDraggingNotification extends Notification {}

class EndDraggingNotification extends Notification {}

class WorkScheduleInnerView extends StatefulWidget {
  final BoxConstraints _constraints;
  final Date _fromDate;
  final Date _toDate;
  WorkScheduleInnerView(this._fromDate, this._toDate, this._constraints);

  @override
  State<WorkScheduleInnerView> createState() => _WorkScheduleInnerView();
}

class _WorkScheduleInnerView extends State<WorkScheduleInnerView> {
  late ScrollController _scrollController;
  final double _sm = 0; //GlobalStyle.summaryCardMargin;
  final double _sw = GlobalStyle.scheduleGridStrokeWidth;
  final double _pxPerSecond =
      (GlobalStyle.scheduleCellHeightPx + GlobalStyle.scheduleGridStrokeWidth) /
          GlobalSettings.scheduleBoxRangeS;

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
          container[i] == null ? Column() : Column(children: container[i]!),
          records[i] == null ? Column() : Column(children: records[i]!),
        ]),
      ));
      // res.add(
      //   Container(color: Colors.green, width: spacerWidth),
      // );
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

      if (record != null) {
        List<double> entries = [];
        List<int> subjectIds = [];
        List<ScheduleRecordedData> eData = [];

        for (var e in record) {
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
    _scrollController = ScrollController(
        initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
        keepScrollOffset: true);

    int ccsbx = widget._fromDate.absWindowSizeWith(widget._toDate);

    double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

    GlobalContext.scheduleDateBarOutlineRect = Rect.fromLTRB(
        GlobalStyle.summaryCardMargin,
        0,
        widget._constraints.maxWidth - GlobalStyle.summaryCardMargin,
        GlobalStyle.scheduleDateBarHeight);

    GlobalContext.scheduleWindowOutlineRect = Rect.fromLTRB(
        GlobalStyle.summaryCardMargin,
        GlobalStyle.summaryCardMargin,
        widget._constraints.maxWidth - GlobalStyle.summaryCardMargin,
        widget._constraints.maxHeight -
            GlobalStyle.scheduleDateBarHeight -
            GlobalStyle.summaryCardMargin);

    GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
        GlobalStyle.summaryCardMargin,
        GlobalStyle.summaryCardMargin,
        widget._constraints.maxWidth - GlobalStyle.summaryCardMargin,
        (GlobalStyle.scheduleCellHeightPx +
                    GlobalStyle.scheduleGridStrokeWidth) *
                numBoxes -
            GlobalStyle.summaryCardMargin);

    double boxWidth = GlobalContext.scheduleWindowInlineRect.width / ccsbx;

    var columns = _getColumns(
        ccsbx, boxWidth, GlobalContext.scheduleWindowInlineRect.height);

    var view = CustomScrollView(controller: _scrollController, slivers: [
      SliverAppBar(
          pinned: true,
          toolbarHeight: GlobalStyle.scheduleDateBarHeight,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.black,
          flexibleSpace: Container(
              color: Colors.blue,
              margin: EdgeInsets.only(
                  left: GlobalContext.scheduleDateBarOutlineRect.left,
                  top: GlobalContext.scheduleDateBarOutlineRect.top),
              child: WorkScheduleDateBar(widget._fromDate, widget._toDate))
          // flexibleSpace: WorkScheduleDateBar(widget._fromDate, widget._toDate),
          ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Container(
                color: Colors.red,
                margin: EdgeInsets.only(
                    left: GlobalContext.scheduleWindowInlineRect.left,
                    top: GlobalContext.scheduleWindowInlineRect.top,
                    right: widget._constraints.maxWidth -
                        GlobalContext.scheduleWindowInlineRect.right),
                height: GlobalContext.scheduleWindowInlineRect.height,
                child: Row(children: [
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
                        margin: EdgeInsets.zero,
                        child: Row(
                          children:
                              columns, // these are the loaded, colored entries of the schedule, NOT the background
                        ),
                      ),
                    ],
                  ))
                ]));
          },
          childCount: 1,
        ),
      ),
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

class WorkScheduleSelector extends StatefulWidget {
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
  double _localDy = 0;
  bool _animBackwards = false;
  bool _verticalDragging = false;
  WorkSchedulePlanedEntry? _currentEntry;

  double _roundToVFrame(double xval) {
    double xpos = (xval - _sideFrame) -
        (xval - _sideFrame) %
            (GlobalContext.scheduleWindowCell.width +
                GlobalStyle.scheduleGridStrokeWidth); // +
    // GlobalStyle.summaryCardMargin;

    return xpos;
  }

  double _roundToHFrame(double yval) {
    double yvalOffset = yval - _topFrame + _localDy;
    double ypos = yvalOffset -
        yvalOffset %
            (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth); // +
    // GlobalStyle.summaryCardMargin;

    return ypos;
  }

  int _getDayIndex(double xMousePos) {
    double day = xMousePos /
        (GlobalContext.scheduleWindowCell.width +
            GlobalStyle.scheduleGridStrokeWidth);
    return day.floor();
  }

  bool _clampConditions(double xMousePos, double yMousePos) {
    _collision = true;
    bool b = !GlobalContext.scheduleWindowInlineRect
        .contains(Offset(xMousePos, yMousePos));
    if (b) return true;

    _collision = false;
    return false;
  }

  double _autoScroll(double delta, double dy) {
    if (!_verticalDragging) return 0;

    // accelerate forwards speed...
    double diff = GlobalContext.scheduleWindowOutlineRect.height - dy;
    if (diff < GlobalSettings.workScheduleAutoScrollHeightTop && delta > 0) {
      double newOffset =
          pow(GlobalSettings.workScheduleAutoScrollHeightBottom - diff, 2.0) /
              GlobalSettings.workScheduleAutoScrollHeightBottom;
      return 0;
    }

    return 0;
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
    _localDy = 0;
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
    _curYPos = ypos;
    _curXPos = xpos; //xMousePos;
    GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
        _curXPos,
        ypos,
        GlobalContext.scheduleWindowCell.width,
        GlobalStyle.scheduleCellHeightPx);

    _animBackwards = false;
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

          _verticalDragging = true;
          BeginDraggingNotification().dispatch(context);

          double localDy = details.localPosition.dy;
          double localDx = details.localPosition.dx;
          setState(() {
            double yMousePos = localDy;
            double xMousePos = _roundToVFrame(localDx);
            if (_clampConditions(xMousePos, yMousePos)) return;

            double ypos = _roundToHFrame(yMousePos);
            _initSelection(xMousePos, ypos);
          });
        },
        onTapUp: (details) {
          _verticalDragging = false;
          EndDraggingNotification().dispatch(context);

          _reset();
        },
        onVerticalDragUpdate: (details) {
          // vertical scroll offset delta
          double ddy = details.delta.dy;
          if (_verticalDragging) {
            setState(() {
              if (_resetSelection(ddy)) return;

              double localDy = details.localPosition.dy;
              double localDx = details.localPosition.dx;
              double offset = _autoScroll(
                  ddy, localDy + _localDy - widget._scrollController.offset);

              if (offset > 0) {
                if (widget._scrollController.offset + offset >
                    GlobalContext.scheduleWindowInlineRect.height) {
                  _localDy += (widget._scrollController.offset +
                      offset -
                      GlobalContext.scheduleWindowInlineRect.height);
                  widget._scrollController
                      .jumpTo(GlobalContext.scheduleWindowInlineRect.height);
                } else {
                  _localDy += offset;
                  widget._scrollController
                      .jumpTo(widget._scrollController.offset + offset);
                }
              }

              double yMousePos = localDy;
              double xMousePos = _roundToVFrame(localDx);

              if (_clampConditions(xMousePos, yMousePos)) return;

              double ypos = _roundToHFrame(yMousePos);
              _continueSelection(xMousePos, ypos, ddy);
            });
          } else {
            widget._scrollController
                .jumpTo(widget._scrollController.offset - ddy);
          }
        },
        onVerticalDragEnd: (details) {
          if (_verticalDragging) {
            setState(() {
              _verticalDragging = false;
              EndDraggingNotification().dispatch(context);

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

    return view;
  }
}
