import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:scheduler/split.dart';
import 'package:scheduler/date.dart';

class DataUtils {
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

  // static Date now() {
  //   Date cur = Date.now();
  //   return Date(cur.year, cur.month, cur.day);
  // }

  // static DateStyle getDateStyle(double width, TextStyle textStyle) {
  //   DateStyle res = DateStyle.full;

  //   int lines = DataUtils.getTextLines("  99.99.9999  ", textStyle, width);
  //   if (lines > 1) {
  //     res = DateStyle.noYear;
  //     lines = DataUtils.getTextLines("  99.99  ", textStyle, width);
  //     if (lines > 1) {
  //       res = DateStyle.newLine;
  //       lines = DataUtils.getTextLines("  99  ", textStyle, width);
  //       if (lines > 1) {
  //         res = DateStyle.weekly;
  //       }
  //     }
  //   }
  //   return res;
  // }

  // static WeekStyle getWeekStyle(double width, TextStyle textStyle) {
  //   var lines = DataUtils.getTextHeight(
  //       "  99.99.9999 - 99.99.9999  ", textStyle, width);
  //   WeekStyle res = WeekStyle.full;
  //   if (lines > 1) {
  //     res = WeekStyle.newLine;
  //   }
  //   return res;
  // }

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

  // static int getWindowSize(Date from, Date to) {
  //   return from.difference(to).inDays.abs() + 1;
  // }

  // static Date addDays(Date from, int days) {
  //   var diff = from.timeZoneOffset.inHours;
  //   return from
  //       .toUtc()
  //       .add(Duration(days: days))
  //       .add(Duration(hours: diff))
  //       .toLocal();
  // }

  // static Date subtractDays(Date from, int days) {
  //   var diff = from.timeZoneOffset.inHours;
  //   return from
  //       .toUtc()
  //       .subtract(Duration(days: days))
  //       .add(Duration(hours: diff))
  //       .toLocal();
  // }

  // static int dateDifferenceInDays(Date date1, Date date2) {
  //   return date1.toUtc().difference(date2.toUtc()).inDays;
  // }

  static Map<String, Date> getNextPage(Date from, Date to) {
    var d = from.absWindowSizeWith(to);
    return {"from": to.addDays(1), "to": to.addDays(d)};
  }

  static Map<String, Date> getPreviousPage(Date from, Date to) {
    var d = from.absWindowSizeWith(to);
    return {
      "from": from.subtractDays(d),
      "to": from.subtractDays(1)
    };
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

  // static Date getLastMonday(Date date) {
  //   return DataUtils.subtractDays(date, date.weekday);
  // }

  // static Date getNextSunday(Date date) {
  //   return DataUtils.addDays(date, 7 - date.weekday % 7);
  // }

  // static String getFormatedDate(Date date) {
  //   return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  // }

  // static int Date2Int(Date date) {
  //   if (date.year < 1000 || date.year > 9999) {
  //     throw Exception(
  //         "Out-of-bounds: [$date] Years must be in [1000, 9999] range!");
  //   }
  //   return (date.year * 10000 + date.month * 100 + date.day).round();
  // }

  // static int Date2IntShort(Date date) {
  //   // for this function we assume that this program will not be used
  //   // beyond the year 2099 XD
  //   if (date.year < 2000 || date.year > 2099) {
  //     throw Exception(
  //         "Out-of-bounds: [$date] Years must be in [1000, 9999] range!");
  //   }
  //   return ((date.year - 2000) * 10000 + date.month * 100 + date.day).round();
  // }

  // static Date int2Date(int date) {
  //   int year = date ~/ 10000;
  //   int month = (date - year * 10000) ~/ 100;
  //   int day = (date - year * 10000 - month * 100).round();

  //   if (year < 1000 || year > 9999) {
  //     throw Exception(
  //         "Out-of-bounds: [$date] Years must be in [1000, 9999] range!");
  //   }
  //   if (month < 1 || month > 12) {
  //     throw Exception("Out-of-bounds: [$date] Month must be in [1, 12] range!");
  //   }
  //   if (day < 1) {
  //     throw Exception("Out-of-bounds: [$date] Days must be greater than 1!");
  //   }

  //   if (month == 2) {
  //     int d = ((year % 4 == 0 || (!(year % 100 == 0) && year % 400 == 0))
  //         ? 29
  //         : 28);
  //     if (day > d) {
  //       throw Exception(
  //           "Out-of-bounds: [$date] Days must be in [1, $d] range!");
  //     }
  //   }

  //   var days31 = {
  //     Date.january,
  //     Date.march,
  //     Date.may,
  //     Date.july,
  //     Date.august,
  //     Date.october,
  //     Date.december
  //   };
  //   var days30 = {
  //     Date.april,
  //     Date.june,
  //     Date.september,
  //     Date.november
  //   };
  //   if (day > 30 && days30.contains(month)) {
  //     throw Exception("Out-of-bounds: [$date] Years must be in [1, 30] range!");
  //   } else if (day > 31 && days31.contains(month)) {
  //     throw Exception("Out-of-bounds: [$date] Years must be in [1, 31] range!");
  //   }

  //   return Date(year, month, day);
  // }
}
