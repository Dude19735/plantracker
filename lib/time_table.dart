import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/split_controller.dart';
import 'package:scheduler/time_table_box.dart';
import 'package:scheduler/joined_scroller.dart';
import 'package:scheduler/date.dart';

class TimeTable extends StatefulWidget {
  final SplitController _splitController;
  final JoinedScroller _joinedScroller;
  final SplitMetrics _metrics;

  TimeTable(this._metrics, this._joinedScroller, this._splitController) {
    Debugger.timeTable(
        ">>>>>>>>>>>>>>>>>>> Create time table widget <<<<<<<<<<<<<<<<<<<<");
  }

  @override
  State<TimeTable> createState() => _TimeTable();
}

class _TimeTable extends State<TimeTable> {
  TControllerHash _controller = 0;
  final JoinedScrollerSide _side = JoinedScrollerSide.right;
  final JoinedScrollerSide _otherSide = JoinedScrollerSide.left;
  late TimeTableCellStateEncapsulation _edit;

  // int _getColDate(int dayOffset) {
  //   return GlobalContext.fromDateWindow.addDays(dayOffset).toInt();
  // }

  Widget _getRowBox(
      int x,
      int y,
      double width,
      double height,
      BuildContext context,
      int subjectId,
      Map<int, TimeTableData>? subject,
      Date date) {
    // int date = _getColDate(dayOffset);
    int iDate = date.toInt();

    return TimeTableBox(x, y, width, height, subjectId, iDate, _edit);
  }

  Widget _getRow(int x, BuildContext context, BoxConstraints constraints,
      int numCells, double height, int subjectId, Date fromDate, Date toDate) {
    double cellWidth =
        (constraints.maxWidth - GlobalStyle.scheduleTimeBarWidth) / numCells;
    var subject = GlobalContext.data.timeTableData.data[subjectId];
    // int dayOffset = DataUtils.page2DayOffset(
    //     pageOffset, GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    return Stack(children: [
      Row(
        children: [
          for (int i = 0; i < numCells; i++)
            _getRowBox(x, i, cellWidth, height, context, subjectId, subject,
                fromDate.addDays(i))
        ],
      )
    ]);
  }

  Widget _rowBuilder(
      List<SummaryData> data,
      int subjectIndex,
      BuildContext context,
      BoxConstraints constraints,
      int numCells,
      Date fromDate,
      Date toDate) {
    int subjectId = data[subjectIndex].subjectId;

    double height = DataUtils.getTextHeight(
        data[subjectIndex].subject,
        DefaultTextStyle.of(context).style,
        widget._metrics.tlWidth - GlobalStyle.timeTableSummaryPM());

    height += 2 * GlobalStyle.summaryEntryBarHeight;
    height += 2 * GlobalStyle.summaryCardPadding;
    return _getRow(subjectIndex, context, constraints, numCells, height,
        subjectId, fromDate, toDate);
  }

  @override
  void dispose() {
    super.dispose();
    widget._joinedScroller.remove(_controller, _side);
  }

  @override
  void initState() {
    super.initState();
    Debugger.timeTable(" #####>> init time table");
  }

  @override
  Widget build(BuildContext context) {
    Widget table(int pageOffset) {
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

      return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            double px = notification.metrics.pixels;
            GlobalContext.timeTableWindowScrollOffset = px;

            widget._joinedScroller.jumpTo(_otherSide, px);

            return true;
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            Debugger.timeTable(
                " ========> rebuild time table $pageOffset  from ${fromDate.day} to ${toDate.day}");

            int sRow = GlobalContext.data.summaryData.data.length;
            int sCol = fromDate.absWindowSizeWith(toDate);
            _edit = TimeTableCellStateEncapsulation(sRow, sCol);

            int numCells = fromDate.absWindowSizeWith(toDate);

            var data = GlobalContext.data.summaryData.data;

            var cPair = widget._joinedScroller
                .register(GlobalContext.timeTableWindowScrollOffset, _side);

            _controller = cPair.key;

            return DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.999999,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Row(
                  children: [
                    SizedBox(width: GlobalStyle.scheduleTimeBarWidth),
                    Expanded(
                      child: ListView(
                          clipBehavior: Clip.none,
                          padding: EdgeInsets.zero,
                          controller: cPair.value,
                          children: [
                            for (int i = 0; i < data.length; i++)
                              _rowBuilder(data, i, context, constraints,
                                  numCells, fromDate, toDate)
                          ]),
                    ),
                  ],
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
