import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/split_controller.dart';
import 'dart:math';

class TimeTable extends StatelessWidget {
  final ScrollController _scrollController;
  final SplitController _splitController;

  TimeTable(this._scrollController, this._splitController);

  Widget _getContainer(BuildContext context, BoxConstraints constraints,
      int numCells, height, int rowIndex, int colIndex, bool fullFrame) {
    int elevate = Random().nextDouble() > 0.8 ? 1 : 0;
    return SizedBox(
        height: height,
        width: constraints.maxWidth / numCells,
        child: Container(
          margin: EdgeInsets.all(GlobalStyle.cardMargin),
          decoration: BoxDecoration(
              color: elevate == 1 ? Colors.red : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(GlobalStyle.globalBorderRadius)),
        ));
  }

  Widget _getRow(BuildContext context, BoxConstraints constraints, int numCells,
      double height, int index) {
    height = height + GlobalStyle.cardPadding + GlobalStyle.cardMargin;
    return Stack(children: [
      SizedBox(
          height: height,
          width: constraints.maxWidth,
          child: GlobalStyle.createShadowContainer(context, null)),
      Row(children: [
        for (int i = 0; i < numCells - 1; i++)
          _getContainer(
              context, constraints, numCells, height, i, index, false),
        _getContainer(
            context, constraints, numCells, height, numCells - 1, index, true)
      ]),
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

    Widget table = NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          return true;
        }
        return false;
      },
      child: Container(
        margin: EdgeInsets.all(GlobalStyle.globalCardMargin),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(GlobalStyle.globalCardPadding),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.999999,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ListView.builder(
                  clipBehavior: Clip.none,
                  controller: _scrollController,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    int subjectId = data[index].subjectId;
                    double height = GlobalContext.showSubjectsInSummary
                        ? GlobalContext.data.minSubjectTextHeight[subjectId]!
                        : 0;
                    height += 2 * GlobalStyle.summaryEntryBarHeight;
                    height += GlobalStyle.cardMargin + GlobalStyle.cardPadding;
                    return _getRow(
                        context, constraints, numCells, height, index);
                  },
                );
              },
            );
          }),
        ),
      ),
    );

    return _splitController.widget(
        context, table, SplitControllerLocation.bottom);
  }
}
