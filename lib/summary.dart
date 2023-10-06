import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/joined_scroller.dart';

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
                      color: color, borderRadius: BorderRadius.circular(3))),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: Text(text),
            ),
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
            GlobalStyle.summaryRecordedTimeBarColor(context, data[_index]),
            "${data[_index].recorded}"),
        _getBar(
            GlobalStyle.summaryEntryBarHeight,
            _getFraction(_maxTime, data[_index].planed),
            GlobalStyle.summaryPlanedTimeBarColor(context),
            "${data[_index].planed}"),
      ]),
    );
    return GlobalStyle.createShadowContainer(context, child,
        margin: EdgeInsets.all(GlobalStyle.summaryCardMargin));
  }
}

class Summary extends StatelessWidget {
  final JoinedScrollerIdentifier _identifier = JoinedScrollerIdentifier.left;
  final JoinedScroller _joinedScroller;

  Summary(this._joinedScroller) {}

  @override
  Widget build(BuildContext context) {
    double maxTime = 0;
    var data = GlobalContext.data.summaryData.data;
    for (var item in data) {
      if (item.planed > maxTime) maxTime = item.planed;
      if (item.recorded > maxTime) maxTime = item.recorded;
    }

    var controller = ScrollController();
    _joinedScroller.register(JoinedScrollerIdentifier.left, controller);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollNotification) {
              _joinedScroller.jumpTo(
                  JoinedScrollerIdentifier.right, notification.metrics.pixels);
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.999999,
            builder: (BuildContext context, ScrollController scrollController) {
              return ListView(
                  clipBehavior: Clip.none,
                  controller: controller,
                  // itemCount: data.length,
                  // itemBuilder: (BuildContext context, int index) {
                  children: [
                    for (int i = 0; i < data.length; ++i)
                      SummaryEntry(constraints.maxWidth, maxTime, i)
                  ]);
            },
          ),
        );
      },
    );
  }
}
