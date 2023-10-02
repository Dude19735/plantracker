import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

class SummaryEntry extends StatelessWidget {
  final double _maxWidth;
  final double _maxTime;
  final int _index;

  SummaryEntry(this._maxWidth, this._maxTime, this._index);

  Widget _getBar(double height, double fraction, Color color, String text) {
    return SizedBox(
        width: _maxWidth,
        height: height,
        child: Stack(
          children: [
            AnimatedFractionallySizedBox(
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
              widthFactor: fraction,
              heightFactor: 1.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: color)),
              ),
            ),
            Text(text),
          ],
        ));
  }

  double _getFraction(double totalTime, double itemTime) {
    double b = 0.01;
    double m = (1.0 - b) / totalTime;
    return m * itemTime + b;
  }

  @override
  Widget build(BuildContext context) {
    var data = GlobalContext.data.summaryData.data;
    Widget child = Padding(
      padding: const EdgeInsets.all(GlobalStyle.summaryCardPadding),
      child: Wrap(children: [
        if (GlobalContext.showSubjectsInSummary) Text(data[_index].subject),
        _getBar(
            GlobalStyle.summaryEntryBarHeight,
            _getFraction(_maxTime, data[_index].recorded),
            Colors.blue,
            "${data[_index].recorded}"),
        _getBar(
            GlobalStyle.summaryEntryBarHeight,
            _getFraction(_maxTime, data[_index].planed),
            Colors.orange,
            "${data[_index].planed}"),
      ]),
    );
    return GlobalStyle.createShadowContainer(context, child,
        margin: EdgeInsets.all(GlobalStyle.summaryCardMargin));
  }
}

class Summary extends StatelessWidget {
  final ScrollController _scrollController;

  Summary(this._scrollController);

  @override
  Widget build(BuildContext context) {
    double maxTime = 0;
    var data = GlobalContext.data.summaryData.data;
    for (var item in data) {
      if (item.planed > maxTime) maxTime = item.planed;
      if (item.recorded > maxTime) maxTime = item.recorded;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.999999,
          builder: (BuildContext context, ScrollController scrollController) {
            return ListView.builder(
              clipBehavior: Clip.none,
              controller: _scrollController,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                Widget x = SummaryEntry(constraints.maxWidth, maxTime, index);
                return x;
              },
            );
          },
        );
      },
    );
  }
}
