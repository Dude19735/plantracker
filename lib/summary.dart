import 'package:flutter/material.dart';
import 'package:scheduler/data.dart';

class Summary extends StatelessWidget {
  final Data<SummaryData> data;

  Summary(this.data);

  Widget _getBar(BoxConstraints constraints, double height, double fraction,
      Color color, String text) {
    return SizedBox(
        width: constraints.maxWidth,
        height: height,
        child: AnimatedFractionallySizedBox(
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
            child: Text(text),
          ),
        ));
  }

  double _getFraction(double totalTime, double itemTime) {
    return 1.0 / totalTime * itemTime;
  }

  @override
  Widget build(BuildContext context) {
    double maxTime = 0;
    for (var item in data.data) {
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
            controller: scrollController,
            itemCount: data.data.length,
            itemBuilder: (BuildContext context, int index) {
              // return ListTile(title: Text('Item $index'));
              return Wrap(runSpacing: 3, children: [
                _getBar(
                    constraints,
                    20,
                    _getFraction(maxTime, data.data[index].recorded),
                    Colors.blue,
                    "${data.data[index].recorded}"),
                _getBar(
                    constraints,
                    20,
                    _getFraction(maxTime, data.data[index].planed),
                    Colors.orange,
                    "${data.data[index].recorded}"),
                Container(color: Colors.grey, height: 3)
              ]);
            },
          );
        },
      );
    });
  }
}
