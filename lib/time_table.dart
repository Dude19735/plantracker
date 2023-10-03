import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/split_controller.dart';
import 'dart:math';

class TimeTable extends StatelessWidget {
  final ScrollController _scrollController;
  final SplitController _splitController;

  TimeTable(this._scrollController, this._splitController) : super() {
    print("create table view");
  }

  Widget _getFullContainer(BuildContext context, TimeTableData subject) {
    return Container(
        color: Colors.transparent,
        child: Text(
          subject.toString(),
          overflow: TextOverflow.visible,
        ));
  }

  int _getColDate(int dayOffset) {
    var d = GlobalContext.fromDateWindow.add(Duration(days: dayOffset));
    print("fromDate $d");
    return DataUtils.dateTime2Int(d);
  }

  SizedBox _getRowBox(double width, double height, BuildContext context,
      Map<int, TimeTableData>? subject, int dayOffset) {
    int date = _getColDate(dayOffset);
    bool fill = subject != null && subject[date] != null;
    return SizedBox(
      width: width,
      child: GlobalStyle.createShadowContainer(
          context, fill ? _getFullContainer(context, subject[date]!) : null,
          height: height,
          margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
          shadow: fill ? true : false,
          border: fill ? false : true,
          color: GlobalStyle.timeTableCellColor(context),
          shadowColor: fill
              ? GlobalStyle.timeTableCellShadeColorFull(context)
              : GlobalStyle.timeTableCellShadeColorEmpty(context)),
    );
  }

  Widget _getRow(BuildContext context, BoxConstraints constraints, int numCells,
      double height, int subjectId, int pageOffset) {
    double cellWidth = (constraints.maxWidth) / numCells;
    var subject = GlobalContext.data.timeTableData.data[subjectId];
    int dayOffset = pageOffset *
        GlobalContext.fromDateWindow
            .difference(GlobalContext.toDateWindow)
            .inDays
            .abs();
    print("dayOffset $dayOffset $numCells");
    return Stack(children: [
      Row(
        children: [
          for (int i = 0; i < numCells; i++)
            _getRowBox(cellWidth, height, context, subject, i + dayOffset)
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    int numCells = GlobalContext.fromDateWindow
            .difference(GlobalContext.toDateWindow)
            .inDays
            .abs() +
        1;
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
                  controller: _scrollController,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int subjecIndex) {
                    int subjectId = data[subjecIndex].subjectId;
                    double height = GlobalContext.showSubjectsInSummary
                        ? GlobalContext.data.minSubjectTextHeight[subjectId]!
                        : 0;
                    height += 2 * GlobalStyle.summaryEntryBarHeight;
                    height += 2 * GlobalStyle.summaryCardPadding;
                    return _getRow(context, constraints, numCells, height,
                        subjectId, pageOffset);
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
      child: _splitController.widget(
          context, table, SplitControllerLocation.bottom),
    );
  }
}
