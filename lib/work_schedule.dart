import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/work_schedule_inner_view3.dart';
import 'package:scheduler/split_controller.dart';
import 'package:scheduler/date.dart';

class DateChangedNotification extends Notification {
  final Date from;
  final Date to;
  DateChangedNotification(this.from, this.to);
}

class ScheduleMarkedNotification extends Notification {}

class WorkSchedule extends StatefulWidget {
  final SplitController _splitController;
  final SplitMetrics _metrics;

  WorkSchedule(this._metrics, this._splitController);

  @override
  State<WorkSchedule> createState() => _WorkSchedule();
}

class _WorkSchedule extends State<WorkSchedule> {
  bool _verticalDragging = false;
  _WorkSchedule();

  Widget innerViewBuilder(int pageOffset) {
    int dayOffset = pageOffset;
    Date fromDate = GlobalContext.fromDateWindow;
    Date toDate = GlobalContext.toDateWindow;
    if (dayOffset < 0) {
      var prev = DataUtils.getPreviousPage(fromDate, toDate);
      fromDate = prev["from"]!;
      toDate = prev["to"]!;
    } else if (dayOffset > 0) {
      var prev = DataUtils.getNextPage(fromDate, toDate);
      fromDate = prev["from"]!;
      toDate = prev["to"]!;
    }

    // print("dayOffset bbb: $dayOffset");
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // _entries = _getEntries(constraints);
      return Stack(children: [
        WorkScheduleInnerView(fromDate, toDate, constraints),
        // if (_verticalDragging)
        //   Transform(
        //       transform: Matrix4.translationValues(
        //           0,
        //           GlobalStyle.scheduleDateBarHeight -
        //               GlobalStyle.summaryCardMargin,
        //           0),
        //       child: Container(
        //           margin: EdgeInsets.only(
        //               left: GlobalStyle.summaryCardMargin / 2.0,
        //               right: GlobalStyle.summaryCardMargin / 2.0),
        //           width: double.infinity,
        //           height: GlobalSettings.workScheduleAutoScrollHeightTop,
        //           decoration: BoxDecoration(
        //               gradient: LinearGradient(
        //             begin: Alignment.topCenter,
        //             end: Alignment.bottomCenter,
        //             colors: [
        //               Colors.grey.withAlpha(0),
        //               Colors.grey.withAlpha(128),
        //             ],
        //           )))),
        if (_verticalDragging)
          Transform(
            transform: Matrix4.translationValues(
                0,
                constraints.maxHeight -
                    GlobalSettings.workScheduleAutoScrollHeightBottom,
                0),
            child: Container(
                width: double.infinity,
                height: GlobalSettings.workScheduleAutoScrollHeightBottom,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.withAlpha(128),
                    Colors.grey.withAlpha(0),
                  ],
                ))),
          ),
        if (_verticalDragging)
          Transform(
            transform: Matrix4.translationValues(
                0,
                -(GlobalSettings.workScheduleAutoScrollHeightTop -
                    GlobalStyle.scheduleDateBarHeight),
                0),
            child: Container(
                width: double.infinity,
                height: GlobalSettings.workScheduleAutoScrollHeightTop,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.grey.withAlpha(128),
                    Colors.grey.withAlpha(0),
                  ],
                ))),
          )
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    Debugger.workSchedule(" ========> rebuild work schedule");
    var view = Column(
      children: [
        AbsorbPointer(
          absorbing: _verticalDragging,
          child: Container(
            color: GlobalStyle.scheduleDateSelectorColor(context),
            width: double.infinity,
            height: GlobalStyle.scheduleDateSelectorHeight,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      StartChangeSplitControllerPageNotification(
                              ScrollDirection.reverse)
                          .dispatch(context);
                    },
                    icon: Icon(Icons.chevron_left)),
                VerticalDivider(),
                Spacer(),
                IconButton(
                    onPressed: () {
                      DateChangedNotification(
                              GlobalContext.fromDateWindow.subtractDays(1),
                              GlobalContext.toDateWindow)
                          .dispatch(context);
                    },
                    icon: Icon(Icons.remove)),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                      label:
                          Text(GlobalContext.fromDateWindow.toFormatedString()),
                      style: ElevatedButton.styleFrom(elevation: 0),
                      onPressed: () {
                        Future<DateTime?> res = showDatePicker(
                            context: context,
                            initialDate:
                                GlobalContext.fromDateWindow.toDateTime(),
                            firstDate: GlobalSettings.earliestDate,
                            lastDate: GlobalContext.toDateWindow.toDateTime(),
                            locale: GlobalSettings
                                .locals[GlobalContext.currentLocale]);

                        res.then((value) {
                          if (value != null) {
                            DateChangedNotification(Date.fromDateTime(value),
                                    GlobalContext.toDateWindow)
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
                                GlobalContext.fromDateWindow.addDays(1),
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
                VerticalDivider(),
                IconButton(
                  onPressed: () {
                    Future<DateTimeRange?> res = showDateRangePicker(
                        context: context,
                        initialDateRange: DateTimeRange(
                            start: GlobalContext.fromDateWindow.toDateTime(),
                            end: GlobalContext.toDateWindow.toDateTime()),
                        firstDate: GlobalContext.fromDateWindow.toDateTime(),
                        lastDate: GlobalSettings.latestDate,
                        locale:
                            GlobalSettings.locals[GlobalContext.currentLocale]);

                    res.then((value) {
                      if (value != null) {
                        DateChangedNotification(Date.fromDateTime(value.start),
                                Date.fromDateTime(value.end))
                            .dispatch(context);
                      }
                    });
                  },
                  icon: Icon(Icons.date_range),
                ),
                VerticalDivider(),
                IconButton(
                    onPressed: () {
                      if (GlobalContext.toDateWindow
                              .compareTo(GlobalContext.fromDateWindow) >
                          0) {
                        DateChangedNotification(
                                GlobalContext.fromDateWindow,
                                GlobalContext.toDateWindow =
                                    GlobalContext.toDateWindow.subtractDays(1))
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
                      label:
                          Text(GlobalContext.toDateWindow.toFormatedString()),
                      style: ElevatedButton.styleFrom(elevation: 0),
                      onPressed: () {
                        Future<DateTime?> res = showDatePicker(
                            context: context,
                            initialDate:
                                GlobalContext.toDateWindow.toDateTime(),
                            firstDate:
                                GlobalContext.fromDateWindow.toDateTime(),
                            lastDate: GlobalSettings.latestDate,
                            locale: GlobalSettings
                                .locals[GlobalContext.currentLocale]);

                        res.then((value) {
                          if (value != null) {
                            DateChangedNotification(
                                    GlobalContext.fromDateWindow,
                                    Date.fromDateTime(value))
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
                              GlobalContext.toDateWindow =
                                  GlobalContext.toDateWindow.addDays(1))
                          .dispatch(context);
                    },
                    icon: Icon(Icons.add)),
                Spacer(),
                VerticalDivider(),
                IconButton(
                  onPressed: () {
                    StartChangeSplitControllerPageNotification(
                            ScrollDirection.forward)
                        .dispatch(context);
                  },
                  icon: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: widget._splitController.widget(
                context, innerViewBuilder, SplitControllerLocation.top)),
      ],
    );
    return NotificationListener(
        onNotification: (notification) {
          if (notification is BeginDraggingNotification) {
            // print("begin dragging");
            setState(() {
              _verticalDragging = true;
            });
          } else if (notification is EndDraggingNotification) {
            // print("end dragging");
            setState(() {
              _verticalDragging = false;
            });
          }
          return false;
        },
        child:
            // Stack(children: [
            Padding(
          padding: const EdgeInsets.only(
              right: GlobalStyle.splitterVGrabberSize / 2),
          child: view,
        )
        //   ,
        //   Container(
        //     color: Colors.red.withAlpha(128),
        //     width: double.infinity,
        //     height: GlobalStyle.scheduleDateBarHeight +
        //         GlobalStyle.scheduleDateSelectorHeight,
        //   ),
        //   if (_verticalDragging)
        //     Transform(
        //       transform: Matrix4.translationValues(
        //           0,
        //           GlobalStyle.scheduleDateBarHeight +
        //               GlobalStyle.scheduleDateSelectorHeight,
        //           0),
        //       child: Container(
        //         color: Colors.grey.withAlpha(128),
        //         width: double.infinity,
        //         height: GlobalSettings.workScheduleAutoScrollHeightTop,
        //       ),
        //     )
        // ]
        // ),
        );
  }
}
