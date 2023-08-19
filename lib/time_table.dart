import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

class TimeTable extends StatelessWidget {
  final GlobalContext _globalContext;

  TimeTable(this._globalContext);

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) => _getSize());
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 0.999999,
        builder: (BuildContext context, ScrollController scrollController) {
          return ListView.builder(
            controller: scrollController,
            itemCount: _globalContext.data.summaryData.data.length,
            itemBuilder: (BuildContext context, int index) {
              int subjectId =
                  _globalContext.data.summaryData.data[index].subjectId;
              double height =
                  _globalContext.data.minSubjectTextHeight[subjectId]!;
              height += GlobalStyle.horizontalGrayLineHeight;
              height += 2 * GlobalStyle.summaryEntryBarHeight;
              return Container(
                  height: height,
                  color: (index % 2 == 0) ? Colors.yellow : Colors.tealAccent);
            },
          );
        },
      );
    });
  }
}
