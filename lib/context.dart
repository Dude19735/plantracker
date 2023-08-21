import 'package:flutter/material.dart';
import 'package:scheduler/data.dart';

class GlobalStyle {
  static double horizontalGrayLineHeight = 3;
  static double summaryEntryBarHeight = 20;
}

class GlobalContext {
  bool showSubjectsInSummary = true;
  GlobalData data = GlobalData(DateTime.now(), 0, 0);

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
