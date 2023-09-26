import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_inner_view.dart';
import 'package:scheduler/split_controller.dart';
import 'dart:math';

class DateChangedNotification2 extends Notification {
  final DateTime from;
  final DateTime to;
  DateChangedNotification2(this.from, this.to);
}

class ScheduleMarkedNotification extends Notification {}

class WorkSchedule extends StatefulWidget {
  final SplitController _splitController;
  final ScrollController _innerViewScrollController = ScrollController();

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
            GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
                _curXPos,
                GlobalContext.scheduleWindowSelectionBox!.top,
                GlobalContext.scheduleWindowCell.width,
                _curYPos +
                    _animation.value * GlobalStyle.scheduleBoxHeightPx +
                    (_animBackwards ? GlobalStyle.scheduleBoxHeightPx : 0));
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
    return Column(
      children: [
        Container(
          color: Colors.amber,
          width: double.infinity,
          height: GlobalStyle.appBarHeight,
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
                    DateChangedNotification2(
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
                          DateChangedNotification2(
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
                      DateChangedNotification2(
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
                      DateChangedNotification2(
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
                          DateChangedNotification2(
                                  GlobalContext.fromDateWindow, value)
                              .dispatch(context);
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    DateChangedNotification2(
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
              if (details.localPosition.dy >
                  GlobalContext.scheduleWindowOutlineRect.height -
                      GlobalSettings.scheduleWindowAutoScrollOffset) {
                widget._innerViewScrollController
                    .jumpTo(widget._innerViewScrollController.offset + 5);
              } else if (details.localPosition.dy <
                  GlobalSettings.scheduleWindowAutoScrollOffset) {
                widget._innerViewScrollController
                    .jumpTo(widget._innerViewScrollController.offset - 5);
              }

              setState(() {
                if (details.delta.dy < 0 &&
                    (GlobalContext.scheduleWindowSelectionBox == null ||
                        GlobalContext.scheduleWindowSelectionBox!.height <
                            GlobalStyle.scheduleBoxHeightPx)) {
                  resetSelection();
                  return;
                }

                double frame =
                    GlobalStyle.globalCardPadding + GlobalStyle.cardMargin;
                double offset =
                    widget._innerViewScrollController.offset - frame;

                if (details.localPosition.dy + offset < 0 ||
                    details.localPosition.dy + offset >
                        GlobalContext.scheduleWindowInlineRect.height -
                            2 * frame) {
                  // clamp selection on top and bottom
                  return;
                }

                // stick to the left side of the current row
                _curXPos = details.localPosition.dx -
                    details.localPosition.dx %
                        (GlobalContext.scheduleWindowCell.width +
                            GlobalStyle.scheduleGridStrokeWidth);

                if (GlobalContext.scheduleWindowSelectionBox == null) {
                  double ypos = details.localPosition.dy + offset;
                  // stick to beginning of cells
                  ypos = ypos -
                      ypos %
                          (GlobalStyle.scheduleBoxHeightPx +
                              GlobalStyle.scheduleGridStrokeWidth);

                  if (_initSelection && _curYPos != ypos) {
                    _curYPos = ypos;
                    GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
                        _curXPos,
                        ypos,
                        GlobalContext.scheduleWindowCell.width,
                        1);

                    _curYPos =
                        0.0; // set this to 0.0 because subsequently it will get GlobalContext.scheduleWindowSelectionBox!.top subtracted
                    _animBackwards = false;
                    _controller.reset();
                    _controller.forward();
                  } else if (_initSelection == false) {
                    _initSelection = true;
                    _curYPos = ypos;
                  }
                } else {
                  double ypos = details.localPosition.dy -
                      GlobalContext.scheduleWindowSelectionBox!.top +
                      offset;

                  // stick to beginning of cells
                  ypos = ypos -
                      ypos %
                          (GlobalStyle.scheduleBoxHeightPx +
                              GlobalStyle.scheduleGridStrokeWidth);

                  if (_curYPos != ypos) {
                    _controller.reset();
                    _curYPos = ypos;
                    GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
                        _curXPos,
                        GlobalContext.scheduleWindowSelectionBox!.top,
                        GlobalContext.scheduleWindowCell.width,
                        ypos);

                    if (details.delta.dy < 0) {
                      _animBackwards = true;
                      _controller.reverse(from: 1);
                    } else {
                      _animBackwards = false;
                      _controller.forward();
                    }
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
                WorkScheduleInnerView(widget._innerViewScrollController),
                SplitControllerLocation.top),
          ),
        ),
      ],
    );
  }
}
