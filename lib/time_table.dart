import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/split_controller.dart';
import 'package:scheduler/time_table_box.dart';
import 'package:scheduler/data_columns.dart';

class TimeTable extends StatefulWidget {
  final ScrollController _scrollController;
  final SplitController _splitController;

  // recreate every time we redraw the whole thing...
  late final TimeTableCellStateEncapsulation _edit;

  TimeTable(this._scrollController, this._splitController) {
    int sRow = GlobalContext.data.summaryData.data.length;
    int sCol = DataUtils.getWindowSize(
        GlobalContext.fromDateWindow, GlobalContext.toDateWindow);
    _edit = TimeTableCellStateEncapsulation(sRow, sCol);
  }

  @override
  State<TimeTable> createState() => _TimeTable();
}

class _TimeTable extends State<TimeTable> {
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

    return TimeTableBox(x, y, width, height, subjectId, date, widget._edit);
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
