import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_inner_view.dart';
import 'package:scheduler/work_schedule_date_bar.dart';
import 'package:scheduler/split_controller.dart';
import 'dart:math';

class DateChangedNotification extends Notification {
  final DateTime from;
  final DateTime to;
  DateChangedNotification(this.from, this.to);
}

class ScheduleMarkedNotification extends Notification {}

class WorkSchedule extends StatefulWidget {
  final SplitController _splitController;

  WorkSchedule(this._splitController);

  @override
  State<StatefulWidget> createState() => _WorkSchedule();
}

class _WorkSchedule extends State<WorkSchedule>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  late double _curXPos;
  late double _curYPos;
  bool _animBackwards = false;
  bool _initSelection = false;
  double _topFrame = 0;
  double _sideFrame = GlobalStyle.splitterCellMargin;

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
    bool clamp = yMousePos < 0 ||
        yMousePos > GlobalContext.scheduleWindowInlineRect.height ||
        xMousePos < 0 ||
        xMousePos >
            GlobalContext.scheduleWindowInlineRect.width - 2 * _sideFrame;

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
            GlobalStyle.scheduleDateBarHeight -
            GlobalSettings.scheduleWindowAutoScrollOffset) {
      GlobalContext.scheduleWindowScrollOffset += 5;
    } else if (ypos < GlobalSettings.scheduleWindowAutoScrollOffset) {
      GlobalContext.scheduleWindowScrollOffset -= 5;
    }
  }

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

  void resetSelection() {
    _controller.reset();
    GlobalContext.scheduleWindowSelectionBox = null;
    _curYPos = -1;
    _curXPos = -1;
    _animBackwards = false;
    _initSelection = false;
  }

  @override
  Widget build(BuildContext context) {
    var view = Column(
      children: [
        Container(
          color: Colors.amber,
          width: double.infinity,
          height: GlobalStyle.scheduleDateSelectorHeight,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    ChangePageNotification(true).dispatch(context);
                  },
                  icon: Icon(Icons.chevron_left)),
              Spacer(),
              IconButton(
                  onPressed: () {
                    DateChangedNotification(
                            GlobalContext.fromDateWindow
                                .subtract(Duration(days: 1)),
                            GlobalContext.toDateWindow)
                        .dispatch(context);
                  },
                  icon: Icon(Icons.remove)),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                    label: Text(DataUtils.getFormatedDateTime(
                        GlobalContext.fromDateWindow)),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Future<DateTime?> res = showDatePicker(
                          context: context,
                          initialDate: GlobalContext.fromDateWindow,
                          firstDate: GlobalSettings.earliestDate,
                          lastDate: GlobalContext.toDateWindow,
                          locale: GlobalSettings
                              .locals[GlobalContext.currentLocale]);

                      res.then((value) {
                        if (value != null) {
                          DateChangedNotification(
                                  value, GlobalContext.toDateWindow)
                              .dispatch(context);
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    if (GlobalContext.fromDateWindow
                            .compareTo(GlobalContext.toDateWindow) <
                        0) {
                      DateChangedNotification(
                              GlobalContext.fromDateWindow
                                  .add(Duration(days: 1)),
                              GlobalContext.toDateWindow)
                          .dispatch(context);
                    }
                  },
                  icon: Icon(
                    Icons.add,
                    color: (GlobalContext.fromDateWindow
                                .compareTo(GlobalContext.toDateWindow) <
                            0
                        ? Colors.black
                        : Colors.black12),
                  )),
              SizedBox(
                width: 100,
              ),
              IconButton(
                  onPressed: () {
                    if (GlobalContext.toDateWindow
                            .compareTo(GlobalContext.fromDateWindow) >
                        0) {
                      DateChangedNotification(
                              GlobalContext.fromDateWindow,
                              GlobalContext.toDateWindow = GlobalContext
                                  .toDateWindow
                                  .subtract(Duration(days: 1)))
                          .dispatch(context);
                    }
                  },
                  icon: Icon(
                    Icons.remove,
                    color: (GlobalContext.toDateWindow
                                .compareTo(GlobalContext.fromDateWindow) >
                            0
                        ? Colors.black
                        : Colors.black12),
                  )),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                    label: Text(DataUtils.getFormatedDateTime(
                        GlobalContext.toDateWindow)),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Future<DateTime?> res = showDatePicker(
                          context: context,
                          initialDate: GlobalContext.toDateWindow,
                          firstDate: GlobalContext.fromDateWindow,
                          lastDate: GlobalSettings.latestDate,
                          locale: GlobalSettings
                              .locals[GlobalContext.currentLocale]);

                      res.then((value) {
                        if (value != null) {
                          DateChangedNotification(
                                  GlobalContext.fromDateWindow, value)
                              .dispatch(context);
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    DateChangedNotification(
                            GlobalContext.fromDateWindow,
                            GlobalContext.toDateWindow = GlobalContext
                                .toDateWindow
                                .add(Duration(days: 1)))
                        .dispatch(context);
                  },
                  icon: Icon(Icons.add)),
              Spacer(),
              IconButton(
                onPressed: () {
                  ChangePageNotification(false).dispatch(context);
                },
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _syncVertScrollPos(details.localPosition.dy);

                  if (_resetConditions(details.delta.dy)) {
                    resetSelection();
                    return;
                  }

                  double offset = GlobalContext.scheduleWindowScrollOffset;
                  //widget._innerViewScrollController.offset;
                  GlobalContext.scheduleWindowScrollOffset = offset;
                  double yMousePos = details.localPosition.dy + offset;
                  double xMousePos = _roundToVFrame(details.localPosition.dx);

                  if (_clampConditions(xMousePos, yMousePos)) {
                    return;
                  }

                  double ypos = _roundToHFrame(yMousePos);

                  if (GlobalContext.scheduleWindowSelectionBox == null) {
                    // stick to beginning of cells

                    if (_curYPos != ypos) {
                      print("start $_curYPos $ypos");
                      _curYPos = ypos;
                      _curXPos = xMousePos;
                      GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
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
                      GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
                          _curXPos,
                          GlobalContext.scheduleWindowSelectionBox!.top,
                          GlobalContext.scheduleWindowCell.width,
                          _curYPos +
                              GlobalStyle.scheduleCellHeightPx -
                              GlobalContext.scheduleWindowSelectionBox!.top);

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
              onPanEnd: (details) {
                setState(() {
                  resetSelection();
                });
              },
              child: widget._splitController.widget(
                  context,
                  WorkScheduleInnerView(),
                  // Stack(children: [
                  //   Column(children: [
                  //     SizedBox(height: GlobalStyle.scheduleDateBarHeight),
                  //     Expanded(
                  //         child: WorkScheduleInnerView(
                  //             widget._innerViewScrollController))
                  //   ]),
                  //   Material(
                  //       clipBehavior: Clip.none,
                  //       elevation: 10,
                  //       child: WorkScheduleDateBar()),
                  // ]),
                  SplitControllerLocation.top)),
        ),
      ],
    );

    // _innerViewScrollController.jumpTo(GlobalContext.scheduleWindowScrollOffset);
    return view;
  }
}
