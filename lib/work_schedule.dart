import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_inner_view.dart';
import 'package:scheduler/split_controller.dart';

class DateChangedNotification2 extends Notification {
  final DateTime from;
  final DateTime to;
  DateChangedNotification2(this.from, this.to);
}

class WorkSchedule extends StatelessWidget {
  final GlobalContext _globalContext;
  final SplitController _splitController;

  WorkSchedule(this._globalContext, this._splitController);

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
                            CurrentConfig.fromDateWindow
                                .subtract(Duration(days: 1)),
                            CurrentConfig.toDateWindow)
                        .dispatch(context);
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

                      res.then((value) {
                        if (value != null) {
                          DateChangedNotification2(
                                  value, CurrentConfig.toDateWindow)
                              .dispatch(context);
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    if (CurrentConfig.fromDateWindow
                            .compareTo(CurrentConfig.toDateWindow) <
                        0) {
                      DateChangedNotification2(
                              CurrentConfig.fromDateWindow
                                  .add(Duration(days: 1)),
                              CurrentConfig.toDateWindow)
                          .dispatch(context);
                    }
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
                    if (CurrentConfig.toDateWindow
                            .compareTo(CurrentConfig.fromDateWindow) >
                        0) {
                      DateChangedNotification2(
                              CurrentConfig.fromDateWindow,
                              CurrentConfig.toDateWindow = CurrentConfig
                                  .toDateWindow
                                  .subtract(Duration(days: 1)))
                          .dispatch(context);
                    }
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

                      res.then((value) {
                        if (value != null) {
                          DateChangedNotification2(
                                  CurrentConfig.fromDateWindow, value)
                              .dispatch(context);
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    DateChangedNotification2(
                            CurrentConfig.fromDateWindow,
                            CurrentConfig.toDateWindow = CurrentConfig
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
                context,
                WorkScheduleInnerView(_globalContext),
                SplitControllerLocation.top))
      ],
    );
  }
}
