import 'package:flutter/material.dart';
import 'package:scheduler/data.dart';

class GlobalStyle {
  static const double horizontalGrayLineHeight = 3;
  static const double summaryEntryBarHeight = 20;

  // grabber
  static const double horizontalInitRatio = 0.25;
  static const double horizontalGrabberSize = 10;
  static const double verticalInitRatio = 0.75;
  static const double verticalGrabberSize = 10;
  static const Color grabberColor = Colors.green;

  // summary and time table card settings
  static const double cardMargin = 5.0;
  static const double cardPadding = 5.0;

  // background cards padding and color
  static const double globalCardPadding = 8.0;
  static const Color globalCardColor = Colors.black12;
  static const double globalBorderRadius = 0.0;

  static Widget createShadowContainer(BuildContext context, Widget? child) {
    return Container(
        margin: EdgeInsets.all(GlobalStyle.cardMargin),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              left: BorderSide.none,
              right: BorderSide.none,
              top: BorderSide.none,
              bottom: BorderSide.none),
          borderRadius: BorderRadius.circular(
              GlobalStyle.globalBorderRadius), //border corner radius
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .shadow
                  .withOpacity(0.1), //color of shadow
              spreadRadius: 3, //spread radius
              blurRadius: 4, // blur radius
              offset: Offset(0, 0), // changes position of shadow
              //first paramerter of offset is left-right
              //second parameter is top to down
            ),
            //you can set more BoxShadow() here
          ],
        ),
        child: child);
  }
}

class GlobalContext {
  bool showSubjectsInSummary = true;
  GlobalData data = GlobalData(dateToInt(DateTime.now()), 0, 7);

  static int dateToInt(DateTime date) {
    int res = date.year * 10000 + date.month * 100 + date.day;
    return res;
  }

  static double getTextHeight(
      String text, BuildContext context, double maxWidth) {
    var style = DefaultTextStyle.of(context).style;
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth);
    final numLines = tp.computeLineMetrics().length;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    )..layout();

    // print("$numLines, ${numLines * textPainter.height}: $text");
    return numLines * textPainter.height;
  }
}
