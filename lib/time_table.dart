import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scheduler/context.dart';
import 'dart:math';

class TimeTable extends StatelessWidget {
  final GlobalContext _globalContext;
  final ScrollController _scrollController;

  TimeTable(this._globalContext, this._scrollController);

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
          child: GlobalStyle.createShadowContainer(context, null)
          // Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Container(
          //         height: 1.0,
          //         decoration: BoxDecoration(
          //           shape: BoxShape.rectangle,
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.grey.withOpacity(0.7),
          //               spreadRadius: 0,
          //               blurRadius: 0.5,
          //               offset: Offset(constraints.maxWidth / numCells / 2, 0),
          //             ),
          //           ],
          //         )))
          ),
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
    int numCells =
        1 + _globalContext.data.plusDays + _globalContext.data.minusDays;
    print(numCells);
    return Container(
      // elevation: 0,
      margin: EdgeInsets.all(GlobalStyle.globalCardMargin),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(GlobalStyle.globalCardPadding),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.999999,
            builder: (BuildContext context, ScrollController scrollController) {
              return ListView.builder(
                clipBehavior: Clip.none,
                controller: _scrollController,
                itemCount: _globalContext.data.summaryData.data.length,
                itemBuilder: (BuildContext context, int index) {
                  int subjectId =
                      _globalContext.data.summaryData.data[index].subjectId;
                  double height = _globalContext.showSubjectsInSummary
                      ? _globalContext.data.minSubjectTextHeight[subjectId]!
                      : 0;
                  // height += GlobalStyle.horizontalGrayLineHeight;
                  height += 2 * GlobalStyle.summaryEntryBarHeight;
                  height += GlobalStyle.cardMargin + GlobalStyle.cardPadding;
                  return _getRow(context, constraints, numCells, height, index);
                  // return Container(
                  //     height: height,
                  //     color: (index % 2 == 0) ? Colors.yellow : Colors.tealAccent);
                },
              );
            },
          );
        }),
      ),
    );
  }
}
