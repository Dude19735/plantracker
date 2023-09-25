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

// class WorkSchedule extends StatefulWidget {
//   final GlobalContext _globalContext;
//   final SplitController _splitController;
//   late final List<WorkScheduleInnerView> _innerViewList;

//   WorkSchedule(this._globalContext, this._splitController) {
//     _innerViewList = [];
//     _innerViewList.insertAll(0, [
//       WorkScheduleInnerView(_globalContext),
//       WorkScheduleInnerView(_globalContext),
//       WorkScheduleInnerView(_globalContext)
//     ]);
//   }

//   // void refreshInnerViews() {
//   //   _innerViewList.clear();
//   // }

//   @override
//   State<WorkSchedule> createState() => _WorkSchedule();
// }

class WorkSchedule extends StatelessWidget
// with SingleTickerProviderStateMixin
{
  final GlobalContext _globalContext;
  final SplitController _splitController;
  // late final List<WorkScheduleInnerView> _innerViewList;

  WorkSchedule(this._globalContext, this._splitController) {
    print("init work schedule");
    // CurrentConfig.fromDateWindow = DataUtils.getLastMonday(DateTime.now());
    // CurrentConfig.toDateWindow = DataUtils.getNextSunday(DateTime.now());

    // _innerViewList = [];
    // _innerViewList.insertAll(0, [
    //   WorkScheduleInnerView(_globalContext),
    //   WorkScheduleInnerView(_globalContext),
    //   WorkScheduleInnerView(_globalContext)
    // ]);
  }

  // @override
  // void initState() {
  //   super.initState();

  //   CurrentConfig.fromDateWindow = DataUtils.getLastMonday(DateTime.now());
  //   CurrentConfig.toDateWindow = DataUtils.getNextSunday(DateTime.now());
  // }

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
                    // widget._splitController.previousPage(curve: Curves.linear);
                    ChangePageNotification(true).dispatch(context);
                  },
                  icon: Icon(Icons.chevron_left)),
              Spacer(),
              IconButton(
                  onPressed: () {
                    // setState(() {
                    // CurrentConfig.fromDateWindow = CurrentConfig.fromDateWindow
                    //     .subtract(Duration(days: 1));
                    // });
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
                          // CurrentConfig.fromDateWindow = value,
                          // DateChangedNotification().dispatch(context),
                          // setState(() {
                          // CurrentConfig.fromDateWindow = value;
                          DateChangedNotification2(
                                  value, CurrentConfig.toDateWindow)
                              .dispatch(context);
                          // })
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    // setState(() {
                    if (CurrentConfig.fromDateWindow
                            .compareTo(CurrentConfig.toDateWindow) <
                        0) {
                      // CurrentConfig.fromDateWindow =
                      //     CurrentConfig.fromDateWindow.add(Duration(days: 1));
                      DateChangedNotification2(
                              CurrentConfig.fromDateWindow
                                  .add(Duration(days: 1)),
                              CurrentConfig.toDateWindow)
                          .dispatch(context);
                    }
                    // });
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
                    // setState(() {
                    if (CurrentConfig.toDateWindow
                            .compareTo(CurrentConfig.fromDateWindow) >
                        0) {
                      // CurrentConfig.toDateWindow = CurrentConfig.toDateWindow
                      //     .subtract(Duration(days: 1));
                      DateChangedNotification2(
                              CurrentConfig.fromDateWindow,
                              CurrentConfig.toDateWindow = CurrentConfig
                                  .toDateWindow
                                  .subtract(Duration(days: 1)))
                          .dispatch(context);
                    }
                    // });
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
                          // setState(() {
                          // CurrentConfig.toDateWindow = value;
                          DateChangedNotification2(
                                  CurrentConfig.fromDateWindow, value)
                              .dispatch(context);
                          // })
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    // setState(() {
                    // CurrentConfig.toDateWindow =
                    //     CurrentConfig.toDateWindow.add(Duration(days: 1));
                    DateChangedNotification2(
                            CurrentConfig.fromDateWindow,
                            CurrentConfig.toDateWindow = CurrentConfig
                                .toDateWindow
                                .add(Duration(days: 1)))
                        .dispatch(context);
                    // });
                  },
                  icon: Icon(Icons.add)),
              Spacer(),
              IconButton(
                onPressed: () {
                  // widget._splitController.nextPage(curve: Curves.linear);
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
