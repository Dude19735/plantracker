import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'dart:math';

class SummaryEntry extends StatelessWidget {
  final GlobalContext _globalContext;

  final double _maxWidth;
  final double _maxTime;
  final int _index;

  // final GlobalKey _key = GlobalKey();

  SummaryEntry(this._globalContext, this._maxWidth, this._maxTime, this._index);

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
              widthFactor: Random().nextDouble(),
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
    Widget child = Padding(
      padding: const EdgeInsets.all(GlobalStyle.cardPadding),
      child: Wrap(children: [
        if (_globalContext.showSubjectsInSummary)
          Text(_globalContext.data.summaryData.data[_index].subject),
        _getBar(
            GlobalStyle.summaryEntryBarHeight,
            _getFraction(_maxTime,
                _globalContext.data.summaryData.data[_index].recorded),
            Colors.blue,
            "${_globalContext.data.summaryData.data[_index].recorded}"),
        _getBar(
            GlobalStyle.summaryEntryBarHeight,
            _getFraction(
                _maxTime, _globalContext.data.summaryData.data[_index].planed),
            Colors.orange,
            "${_globalContext.data.summaryData.data[_index].planed}"),
      ]),
    );
    return GlobalStyle.createShadowContainer(context, child);
  }
}

class Summary extends StatelessWidget {
  final GlobalContext _globalContext;
  final ScrollController _scrollController;

  Summary(this._globalContext, this._scrollController);

  @override
  Widget build(BuildContext context) {
    double maxTime = 0;
    for (var item in _globalContext.data.summaryData.data) {
      if (item.planed > maxTime) maxTime = item.planed;
      if (item.recorded > maxTime) maxTime = item.recorded;
    }

    return Card(
      elevation: 0,
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
                  Widget x = SummaryEntry(
                      _globalContext, constraints.maxWidth, maxTime, index);
                  return x;
                },
              );
            },
          );
        }),
      ),
    );
  }
}
