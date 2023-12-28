import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scheduler/date.dart';

class DataUtils {
  static Color str2Color(String colorStr) {
    var cl = colorStr.split(',');
    int r = int.parse(cl[0].trim());
    int g = int.parse(cl[1].trim());
    int b = int.parse(cl[2].trim());
    int a = int.parse(cl[3].trim());
    assert(r < 256 &&
        r >= 0 &&
        g < 256 &&
        r >= 0 &&
        g < 256 &&
        g >= 0 &&
        a < 256 &&
        a >= 0);
    Color res = Colors.black;
    return res.withRed(r).withGreen(g).withBlue(b).withAlpha(a);
  }

  static double getWorkRatio(double recorded, double planed) {
    double workRatio = 0;
    if (planed != 0) {
      workRatio = clampDouble(recorded / planed, 0, 1.0);
    } else if (recorded > 0) {
      workRatio = 1.0;
    }

    return workRatio;
  }

  static String mapOfListsToStr(Map<int, List<Map<String, dynamic>>> data) {
    String res = """[""";
    for (var elemKey in data.keys) {
      var elemList = data[elemKey];
      if (elemList != null) {
        for (var e in elemList) {
          res += "{";
          for (var k in e.keys) {
            res += """"$k":""";
            if (e[k] is String) {
              res += """"${e[k]}",""";
            } else {
              res += "${e[k].toString()},";
            }
          }
          res = res.substring(0, res.length - 1);
          res += "},";
        }
      }
    }
    res = res.substring(0, res.length - 1);
    res += "]";
    return res;
  }

  static double getTextHeight(String text, TextStyle style, double maxWidth) {
    // var style = GlobalStyle.summaryTextStyle;
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth);
    final numLines = tp.computeLineMetrics().length;

    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaleFactor: 1.0 // MediaQuery.of(context).textScaleFactor,
        )
      ..layout();

    // print("$numLines, ${numLines * textPainter.height}: $text, $maxWidth");
    return numLines * textPainter.height;
  }

  static int getTextLines(String text, TextStyle style, double maxWidth) {
    // var style = GlobalStyle.summaryTextStyle;
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth);
    final numLines = tp.computeLineMetrics().length;

    return numLines;
  }

  static int page2DayOffset(int pageOffset, Date from, Date to) {
    return pageOffset * from.absWindowSizeWith(to);
  }

  static Map<String, Date> getNextPage(Date from, Date to) {
    var d = from.absWindowSizeWith(to);
    return {"from": to.addDays(1), "to": to.addDays(d)};
  }

  static Map<String, Date> getPreviousPage(Date from, Date to) {
    var d = from.absWindowSizeWith(to);
    return {"from": from.subtractDays(d), "to": from.subtractDays(1)};
  }

  static Map getAdjacentTimePeriods(
      Date from, Date to, ScrollDirection direction) {
    int dateWindowSize = from.absWindowSizeWith(to);

    // swipe right is 'reverse' but the date goes forwards
    // swipe left is 'forward' but the date goes backwards
    int prev = direction == ScrollDirection.forward
        ? 2 * dateWindowSize
        : dateWindowSize;
    int next = direction == ScrollDirection.reverse
        ? 2 * dateWindowSize
        : dateWindowSize;
    return {
      "prev_from": from.subtractDays(prev),
      "prev_to": from.subtractDays(1),
      "next_from": to.addDays(1),
      "next_to": to.addDays(next)
    };
  }
}
