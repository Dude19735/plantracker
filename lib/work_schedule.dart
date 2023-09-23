import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/work_schedule_inner_view.dart';
import 'package:scheduler/split_controller.dart';

class DateChangedNotification extends Notification {}

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
                    // widget._splitController.previousPage(curve: Curves.linear);
                    PageChangeNotification(0, true, flipPage: true)
                        .dispatch(context);
                  },
                  icon: Icon(Icons.chevron_left)),
              Spacer(),
              IconButton(
                  onPressed: () {
                    // setState(() {
                    CurrentConfig.fromDateWindow = CurrentConfig.fromDateWindow
                        .subtract(Duration(days: 1));
                    // });
                    DateChangedNotification().dispatch(context);
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
                          CurrentConfig.fromDateWindow = value;
                          DateChangedNotification().dispatch(context);
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
                      CurrentConfig.fromDateWindow =
                          CurrentConfig.fromDateWindow.add(Duration(days: 1));
                      DateChangedNotification().dispatch(context);
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
                      CurrentConfig.toDateWindow = CurrentConfig.toDateWindow
                          .subtract(Duration(days: 1));
                      DateChangedNotification().dispatch(context);
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
                          CurrentConfig.toDateWindow = value;
                          DateChangedNotification().dispatch(context);
                          // })
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    // setState(() {
                    CurrentConfig.toDateWindow =
                        CurrentConfig.toDateWindow.add(Duration(days: 1));
                    DateChangedNotification().dispatch(context);
                    // });
                  },
                  icon: Icon(Icons.add)),
              Spacer(),
              IconButton(
                onPressed: () {
                  // widget._splitController.nextPage(curve: Curves.linear);
                  PageChangeNotification(0, false, flipPage: true)
                      .dispatch(context);
                },
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
            child: widget._splitController.widget(
                context, _innerViewList[1], SplitControllerLocation.top))
      ],
    );
  }
}
