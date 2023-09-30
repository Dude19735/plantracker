import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_inner_view.dart';
import 'package:scheduler/split_controller.dart';

class DateChangedNotification extends Notification {
  final DateTime from;
  final DateTime to;
  DateChangedNotification(this.from, this.to);
}

class ScheduleMarkedNotification extends Notification {}

class WorkSchedule extends StatelessWidget {
  final SplitController _splitController;
  WorkSchedule(this._splitController);

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
            child: _splitController.widget(
                context, WorkScheduleInnerView(), SplitControllerLocation.top)),
      ],
    );

    return view;
  }
}
