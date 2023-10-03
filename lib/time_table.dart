import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/split_controller.dart';
import 'package:scheduler/time_table_box.dart';
import 'package:scheduler/data_columns.dart';
import 'package:scheduler/work_schedule.dart';

class TimeTable extends StatefulWidget {
  final ScrollController _scrollController;
  final SplitController _splitController;
  final List<List<TimeTableCellState>> _edit =
      List<List<TimeTableCellState>>.generate(
          GlobalContext.data.summaryData.data.length,
          (i) => List<TimeTableCellState>.generate(
              DataUtils.getWindowSize(
                  GlobalContext.fromDateWindow, GlobalContext.toDateWindow),
              (index) => TimeTableCellState.inactive,
              growable: false),
          growable: false);

  TimeTable(this._scrollController, this._splitController);

  @override
  State<TimeTable> createState() => _TimeTable();
}

class _TimeTable extends State<TimeTable> {
  int _lastPressedX = -1;
  int _lastPressedY = -1;

  int _getColDate(int dayOffset) {
    return DataUtils.dateTime2Int(
        GlobalContext.fromDateWindow.add(Duration(days: dayOffset)));
  }

  Widget _getRowBox(
      int x,
      int y,
      double width,
      double height,
      BuildContext context,
      int subjectId,
      Map<int, TimeTableData>? subject,
      int dayOffset) {
    int date = _getColDate(dayOffset);

    TimeTableData s = subject != null && subject[date] != null
        ? subject[date]!
        : TimeTableData({
            ColumnName.subjectId: subjectId,
            ColumnName.date: date,
            ColumnName.planed: 0.0,
            ColumnName.recorded: 0.0,
            ColumnName.subject: DataValues.subjectNames[subjectId]
          });
    return TimeTableBox(x, y, width, height, s, widget._edit);
  }

  Widget _getRow(int x, BuildContext context, BoxConstraints constraints,
      int numCells, double height, int subjectId, int pageOffset) {
    double cellWidth = (constraints.maxWidth) / numCells;
    var subject = GlobalContext.data.timeTableData.data[subjectId];
    int dayOffset = pageOffset *
        DataUtils.getWindowSize(
            GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    return Stack(children: [
      Row(
        children: [
          for (int i = 0; i < numCells; i++)
            _getRowBox(x, i, cellWidth, height, context, subjectId, subject,
                i + dayOffset)
        ],
      )
    ]);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int numCells = DataUtils.getWindowSize(
        GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    var data = GlobalContext.data.summaryData.data;
    Widget table(int pageOffset) {
      return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            return true;
          } else if (notification is BoxApproveNotification) {
            setState(() {
              print(notification.data.toString());
              var subj = GlobalContext
                  .data.timeTableData.data[notification.data.subjectId];
              // check of we have a subject
              if (subj != null) {
                // insert this particular date for the subject
                subj[notification.data.date] = notification.data;
              } else {
                GlobalContext
                    .data.timeTableData.data[notification.data.subjectId] = {
                  notification.data.date: notification.data
                };
              }

              DateChangedNotification(
                      GlobalContext.fromDateWindow, GlobalContext.toDateWindow)
                  .dispatch(context);

              widget._edit[notification.x][notification.y] =
                  TimeTableCellState.inactive;
              _lastPressedX = -1;
              _lastPressedY = -1;
            });
          } else if (notification is BoxCancelNotification) {
            setState(() {
              widget._edit[notification.x][notification.y] =
                  TimeTableCellState.inactive;
              _lastPressedX = -1;
              _lastPressedY = -1;
            });
          } else if (notification is BoxPressedNotification) {
            setState(() {
              if (_lastPressedX != -1) {
                widget._edit[_lastPressedX][_lastPressedY] =
                    TimeTableCellState.inactive;
              }

              widget._edit[notification.x][notification.y] =
                  TimeTableCellState.pressed;
              _lastPressedX = notification.x;
              _lastPressedY = notification.y;
            });
          } else if (notification is BoxEnterNotification &&
              widget._edit[notification.x][notification.y] !=
                  TimeTableCellState.pressed) {
            setState(() {
              widget._edit[notification.x][notification.y] =
                  TimeTableCellState.hover;
            });
          } else if (notification is BoxLeaveNotification &&
              widget._edit[notification.x][notification.y] !=
                  TimeTableCellState.pressed) {
            setState(() {
              widget._edit[notification.x][notification.y] =
                  TimeTableCellState.inactive;
            });
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.999999,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ListView.builder(
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  controller: widget._scrollController,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int subjectIndex) {
                    int subjectId = data[subjectIndex].subjectId;
                    double height = GlobalContext.showSubjectsInSummary
                        ? GlobalContext.data.minSubjectTextHeight[subjectId]!
                        : 0;
                    height += 2 * GlobalStyle.summaryEntryBarHeight;
                    height += 2 * GlobalStyle.summaryCardPadding;
                    return _getRow(subjectIndex, context, constraints, numCells,
                        height, subjectId, pageOffset);
                  },
                );
              },
            );
          },
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.only(right: GlobalStyle.splitterVGrabberSize / 2),
      child: widget._splitController
          .widget(context, table, SplitControllerLocation.bottom),
    );
  }
}
