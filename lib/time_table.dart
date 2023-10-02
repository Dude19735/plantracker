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
          decoration: BoxDecoration(
              color: elevate == 1 ? Colors.red : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(GlobalStyle.summaryCardBorderRadius)),
        ));
  }

  Widget _getRow(BuildContext context, BoxConstraints constraints, int numCells,
      double height, int index) {
    double cellWidth = (constraints.maxWidth) / numCells;
    // height = height + GlobalStyle.summaryCardPadding + GlobalStyle.cardMargin;
    return Stack(children: [
      // GlobalStyle.createShadowContainer(context, null,
      //     height: height,
      //     width: constraints.maxWidth,
      //     margin: EdgeInsets.all(GlobalStyle.summaryCardMargin)),

      Row(
        children: [
          for (int i = 0; i < numCells; i++)
            SizedBox(
              width: cellWidth,
              child: GlobalStyle.createShadowContainer(context, null,
                  height: height,
                  margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
                  shadow: false,
                  border: true),
            ),
        ],
      )

      // Row(children: [
      //   for (int i = 0; i < numCells - 1; i++)
      //     _getContainer(
      //         context, constraints, numCells, height, i, index, false),
      //   _getContainer(
      //       context, constraints, numCells, height, numCells - 1, index, true)
      // ]),
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.999999,
            builder: (BuildContext context, ScrollController scrollController) {
              return ListView.builder(
                clipBehavior: Clip.none,
                padding: EdgeInsets.zero,
                controller: _scrollController,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  int subjectId = data[index].subjectId;
                  double height = GlobalContext.showSubjectsInSummary
                      ? GlobalContext.data.minSubjectTextHeight[subjectId]!
                      : 0;
                  height += 2 * GlobalStyle.summaryEntryBarHeight;
                  height += 2 * GlobalStyle.summaryCardPadding;
                  return _getRow(context, constraints, numCells, height, index);
                },
              );
            },
          );
        },
      ),
    );

    return Padding(
      padding:
          const EdgeInsets.only(right: GlobalStyle.splitterVGrabberSize / 2),
      child: _splitController.widget(
          context, table, SplitControllerLocation.bottom),
    );
  }
}
