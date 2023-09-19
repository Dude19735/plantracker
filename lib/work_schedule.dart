import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/work_toggler.dart';
import 'package:scheduler/wodk_schedule_inner_view.dart';

/// Flutter code sample for [IconButton].

class WorkSchedule extends StatefulWidget {
  final GlobalContext _globalContext;

  WorkSchedule(this._globalContext);

  @override
  State<WorkSchedule> createState() => _WorkSchedule();
}

class _WorkSchedule extends State<WorkSchedule>
    with SingleTickerProviderStateMixin {
  late DateTime _fromDate;
  late DateTime _toDate;

  DateTime _getLastMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getNextSunday(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday % 7));
  }

  String _getFormatedDateTime(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  Widget _getCalendarButton(DateTime date) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        onTap: () {
          Future<DateTime?> res = showDatePicker(
              context: context,
              initialDate: _fromDate,
              firstDate: GlobalSettings.earliestDate,
              lastDate: _toDate,
              locale: GlobalSettings.locals[CurrentConfig.currentLocale]);

          res.then((value) => {
                if (value != null)
                  {
                    setState(() {
                      _fromDate = value;
                    })
                  }
              });
        },
        child: Placeholder(),
      ),
      onHover: (details) {},
    );
  }

  @override
  void initState() {
    super.initState();

    _fromDate = _getLastMonday(DateTime.now());
    _toDate = _getNextSunday(DateTime.now());
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
                      Duration d = _toDate.difference(_fromDate);
                      _fromDate = _fromDate.subtract(d);
                      _toDate = _toDate.subtract(d);
                    });
                  },
                  icon: Icon(Icons.chevron_left)),
              Spacer(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = _fromDate.subtract(Duration(days: 1));
                    });
                  },
                  icon: Icon(Icons.remove)),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                    label: Text(_getFormatedDateTime(_fromDate)),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Future<DateTime?> res = showDatePicker(
                          context: context,
                          initialDate: _fromDate,
                          firstDate: GlobalSettings.earliestDate,
                          lastDate: _toDate,
                          locale: GlobalSettings
                              .locals[CurrentConfig.currentLocale]);

                      res.then((value) => {
                            if (value != null)
                              {
                                setState(() {
                                  _fromDate = value;
                                })
                              }
                          });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (_fromDate.compareTo(_toDate) < 0) {
                        _fromDate = _fromDate.add(Duration(days: 1));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: (_fromDate.compareTo(_toDate) < 0
                        ? Colors.black
                        : Colors.black12),
                  )),
              SizedBox(
                width: 100,
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (_toDate.compareTo(_fromDate) > 0) {
                        _toDate = _toDate.subtract(Duration(days: 1));
                      }
                    });
                  },
                  icon: Icon(
                    Icons.remove,
                    color: (_toDate.compareTo(_fromDate) > 0
                        ? Colors.black
                        : Colors.black12),
                  )),
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                    label: Text(_getFormatedDateTime(_toDate)),
                    style: ElevatedButton.styleFrom(elevation: 0),
                    onPressed: () {
                      Future<DateTime?> res = showDatePicker(
                          context: context,
                          initialDate: _toDate,
                          firstDate: _fromDate,
                          lastDate: GlobalSettings.latestDate,
                          locale: GlobalSettings
                              .locals[CurrentConfig.currentLocale]);

                      res.then((value) => {
                            if (value != null)
                              {
                                setState(() {
                                  _toDate = value;
                                })
                              }
                          });
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _toDate = _toDate.add(Duration(days: 1));
                    });
                  },
                  icon: Icon(Icons.add)),
              Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    Duration d = _toDate.difference(_fromDate);
                    _fromDate = _fromDate.add(d);
                    _toDate = _toDate.add(d);
                  });
                },
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(child: WorkScheduleInnerView(widget._globalContext))
      ],
    );
  }
}
