import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_inner_view.dart';
import 'package:scheduler/split_controller.dart';

/// Flutter code sample for [IconButton].

class WorkSchedule extends StatefulWidget {
  final GlobalContext _globalContext;
  final SplitController _splitController;

  WorkSchedule(this._globalContext, this._splitController);

  @override
  State<WorkSchedule> createState() => _WorkSchedule();
}

class _WorkSchedule extends State<WorkSchedule>
    with SingleTickerProviderStateMixin {
  late final List<WorkScheduleInnerView> _innerViewList;
  late WorkScheduleInnerView _innerView;

  // Widget _getCalendarButton(DateTime date) {
  //   return MouseRegion(
  //     cursor: SystemMouseCursors.grab,
  //     child: GestureDetector(
  //       onTap: () {
  //         Future<DateTime?> res = showDatePicker(
  //             context: context,
  //             initialDate: _fromDate,
  //             firstDate: GlobalSettings.earliestDate,
  //             lastDate: _toDate,
  //             locale: GlobalSettings.locals[CurrentConfig.currentLocale]);

  //         res.then((value) => {
  //               if (value != null)
  //                 {
  //                   setState(() {
  //                     _fromDate = value;
  //                   })
  //                 }
  //             });
  //       },
  //       child: Placeholder(),
  //     ),
  //     onHover: (details) {},
  //   );
  // }

  @override
  void initState() {
    super.initState();

    CurrentConfig.fromDateWindow = DataUtils.getLastMonday(DateTime.now());
    CurrentConfig.toDateWindow = DataUtils.getNextSunday(DateTime.now());

    _innerViewList = [];
    _innerViewList.insertAll(0, [
      WorkScheduleInnerView(widget._globalContext),
      WorkScheduleInnerView(widget._globalContext),
      WorkScheduleInnerView(widget._globalContext)
    ]);

    _innerView = WorkScheduleInnerView(widget._globalContext);

    // _tabController = TabController(length: 3, vsync: this, initialIndex: 1);

    // _workScheduleInnerView = TabBarView(
    //   controller: _tabController,
    //   children: _innerViewList,
    // );
    // WorkScheduleInnerView.of(context)
    // _controller.addListener(_onTap);
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
                    setState(() {
                      Duration d = CurrentConfig.toDateWindow
                              .difference(CurrentConfig.fromDateWindow) +
                          Duration(days: 1);
                      CurrentConfig.fromDateWindow =
                          CurrentConfig.fromDateWindow.subtract(d);
                      CurrentConfig.toDateWindow =
                          CurrentConfig.toDateWindow.subtract(d);

                      widget._splitController.previousPage(
                          duration: Duration(
                              milliseconds:
                                  GlobalSettings.pageChangeDurationMS),
                          curve: Curves.linear);
                    });
                  },
                  icon: Icon(Icons.chevron_left)),
              Spacer(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      CurrentConfig.fromDateWindow = CurrentConfig
                          .fromDateWindow
                          .subtract(Duration(days: 1));
                    });
                  },
                  icon: Icon(Icons.remove)),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                    label: Text(DataUtils.getFormatedDateTime(
                        CurrentConfig.fromDateWindow)),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Future<DateTime?> res = showDatePicker(
                          context: context,
                          initialDate: CurrentConfig.fromDateWindow,
                          firstDate: GlobalSettings.earliestDate,
                          lastDate: CurrentConfig.toDateWindow,
                          locale: GlobalSettings
                              .locals[CurrentConfig.currentLocale]);

                      res.then((value) => {
                            if (value != null)
                              {
                                setState(() {
                                  CurrentConfig.fromDateWindow = value;
                                })
                              }
                          });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (CurrentConfig.fromDateWindow
                              .compareTo(CurrentConfig.toDateWindow) <
                          0) {
                        CurrentConfig.fromDateWindow =
                            CurrentConfig.fromDateWindow.add(Duration(days: 1));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: (CurrentConfig.fromDateWindow
                                .compareTo(CurrentConfig.toDateWindow) <
                            0
                        ? Colors.black
                        : Colors.black12),
                  )),
              SizedBox(
                width: 100,
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (CurrentConfig.toDateWindow
                              .compareTo(CurrentConfig.fromDateWindow) >
                          0) {
                        CurrentConfig.toDateWindow = CurrentConfig.toDateWindow
                            .subtract(Duration(days: 1));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.remove,
                    color: (CurrentConfig.toDateWindow
                                .compareTo(CurrentConfig.fromDateWindow) >
                            0
                        ? Colors.black
                        : Colors.black12),
                  )),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                    label: Text(DataUtils.getFormatedDateTime(
                        CurrentConfig.toDateWindow)),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Future<DateTime?> res = showDatePicker(
                          context: context,
                          initialDate: CurrentConfig.toDateWindow,
                          firstDate: CurrentConfig.fromDateWindow,
                          lastDate: GlobalSettings.latestDate,
                          locale: GlobalSettings
                              .locals[CurrentConfig.currentLocale]);

                      res.then((value) => {
                            if (value != null)
                              {
                                setState(() {
                                  CurrentConfig.toDateWindow = value;
                                })
                              }
                          });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      CurrentConfig.toDateWindow =
                          CurrentConfig.toDateWindow.add(Duration(days: 1));
                    });
                  },
                  icon: Icon(Icons.add)),
              Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    Duration d = CurrentConfig.toDateWindow
                            .difference(CurrentConfig.fromDateWindow) +
                        Duration(days: 1);
                    CurrentConfig.fromDateWindow =
                        CurrentConfig.fromDateWindow.add(d);
                    CurrentConfig.toDateWindow =
                        CurrentConfig.toDateWindow.add(d);
                    widget._splitController.nextPage(
                        duration: Duration(
                            milliseconds: GlobalSettings.pageChangeDurationMS),
                        curve: Curves.linear);
                  });
                },
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
            child: PageView.builder(
          controller: widget._splitController.topPageController,
          onPageChanged: (value) {
            print("page changed $value");
          },
          itemBuilder: (context, index) {
            return _innerViewList[1];
          },
        ))
      ],
    );
  }
}
