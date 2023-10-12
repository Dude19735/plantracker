import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/split_controller.dart';
import 'package:scheduler/time_table_box.dart';
import 'package:scheduler/joined_scroller.dart';

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

  int _getColDate(int dayOffset) {
    return DataUtils.dateTime2Int(
        DataUtils.addDays(GlobalContext.fromDateWindow, dayOffset));
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

    return TimeTableBox(x, y, width, height, subjectId, date, _edit);
  }

  Widget _getRow(int x, BuildContext context, BoxConstraints constraints,
      int numCells, double height, int subjectId, int pageOffset) {
    double cellWidth = (constraints.maxWidth) / numCells;
    var subject = GlobalContext.data.timeTableData.data[subjectId];
    int dayOffset = DataUtils.page2DayOffset(
        pageOffset, GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

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

  Widget _rowBuilder(
      List<SummaryData> data,
      int subjectIndex,
      BuildContext context,
      BoxConstraints constraints,
      int numCells,
      int pageOffset) {
    int subjectId = data[subjectIndex].subjectId;

    double height = DataUtils.getTextHeight(
        data[subjectIndex].subject,
        DefaultTextStyle.of(context).style,
        widget._metrics.tlWidth - GlobalStyle.timeTableSummaryPM());

    height += 2 * GlobalStyle.summaryEntryBarHeight;
    height += 2 * GlobalStyle.summaryCardPadding;
    return _getRow(subjectIndex, context, constraints, numCells, height,
        subjectId, pageOffset);
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
                " ========> rebuild time table $pageOffset  from ${GlobalContext.fromDateWindow.day} to ${GlobalContext.toDateWindow.day}");

            int sRow = GlobalContext.data.summaryData.data.length;
            int sCol = DataUtils.getWindowSize(
                GlobalContext.fromDateWindow, GlobalContext.toDateWindow);
            _edit = TimeTableCellStateEncapsulation(sRow, sCol);

            int numCells = DataUtils.getWindowSize(
                GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

            var data = GlobalContext.data.summaryData.data;

            var cPair = widget._joinedScroller
                .register(GlobalContext.timeTableWindowScrollOffset, _side);

            _controller = cPair.key;

            return DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.999999,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ListView(
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.zero,
                    controller: cPair.value,
                    children: [
                      for (int i = 0; i < data.length; i++)
                        _rowBuilder(
                            data, i, context, constraints, numCells, pageOffset)
                    ]);
              },
            );
          },
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.only(right: GlobalStyle.splitterVGrabberSize / 2),
      child: Row(
        children: [
          SizedBox(width: GlobalStyle.scheduleTimeBarWidth),
          Expanded(
            child: widget._splitController
                .widget(context, table, SplitControllerLocation.bottom),
          ),
        ],
      ),
    );
  }
}
