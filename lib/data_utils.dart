import 'dart:ui';
import 'package:flutter/rendering.dart';

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

  static DateTime now() {
    DateTime cur = DateTime.now();
    return DateTime(cur.year, cur.month, cur.day);
  }

  static String dateTime2Str(DateTime day) {
    // TODO: do some locale stuff here
    return "${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year.toString().padLeft(4, '0')}";
  }

  static int page2DayOffset(int pageOffset, DateTime from, DateTime to) {
    return pageOffset * DataUtils.getWindowSize(from, to);
  }

  static int getWindowSize(DateTime from, DateTime to) {
    return from.difference(to).inDays.abs() + 1;
  }

  static DateTime addDays(DateTime from, int days) {
    var diff = from.timeZoneOffset.inHours;
    return from.toUtc().add(Duration(days: days)).add(Duration(hours: diff));
  }

  static DateTime subtractDays(DateTime from, int days) {
    var diff = from.timeZoneOffset.inHours;
    return from
        .toUtc()
        .subtract(Duration(days: days))
        .add(Duration(hours: diff));
  }

  static Map<String, DateTime> getNextPage(DateTime from, DateTime to) {
    var d = getWindowSize(from, to);
    return {"from": DataUtils.addDays(to, 1), "to": DataUtils.addDays(to, d)};
  }

  static Map<String, DateTime> getPreviousPage(DateTime from, DateTime to) {
    var d = getWindowSize(from, to);
    return {
      "from": DataUtils.subtractDays(from, d),
      "to": DataUtils.subtractDays(from, 1)
    };
  }

  static Map getAdjacentTimePeriods(
      DateTime from, DateTime to, ScrollDirection direction) {
    int dateWindowSize = DataUtils.getWindowSize(from, to);

    // swipe right is 'reverse' but the date goes forwards
    // swipe left is 'forward' but the date goes backwards
    int prev = direction == ScrollDirection.forward
        ? 2 * dateWindowSize
        : dateWindowSize;
    int next = direction == ScrollDirection.reverse
        ? 2 * dateWindowSize
        : dateWindowSize;
    return {
      "prev_from": DataUtils.subtractDays(from, prev),
      "prev_to": DataUtils.subtractDays(from, 1),
      "next_from": DataUtils.addDays(to, 1),
      "next_to": DataUtils.addDays(to, next)
    };
  }

  static DateTime getLastMonday(DateTime date) {
    return DataUtils.subtractDays(date, date.weekday - 1);
  }

  static DateTime getNextSunday(DateTime date) {
    return DataUtils.addDays(date, 7 - date.weekday % 7);
  }

  static String getFormatedDateTime(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  static int dateTime2Int(DateTime date) {
    if (date.year < 1000 || date.year > 9999) {
      throw Exception(
          "Out-of-bounds: [$date] Years must be in [1000, 9999] range!");
    }
    return (date.year * 10000 + date.month * 100 + date.day).round();
  }

  static int dateTime2IntShort(DateTime date) {
    // for this function we assume that this program will not be used
    // beyond the year 2099 XD
    if (date.year < 2000 || date.year > 2099) {
      throw Exception(
          "Out-of-bounds: [$date] Years must be in [1000, 9999] range!");
    }
    return ((date.year - 2000) * 10000 + date.month * 100 + date.day).round();
  }

  static DateTime int2DateTime(int date) {
    int year = date ~/ 10000;
    int month = (date - year * 10000) ~/ 100;
    int day = (date - year * 10000 - month * 100).round();

    if (year < 1000 || year > 9999) {
      throw Exception(
          "Out-of-bounds: [$date] Years must be in [1000, 9999] range!");
    }
    if (month < 1 || month > 12) {
      throw Exception("Out-of-bounds: [$date] Month must be in [1, 12] range!");
    }
    if (day < 1) {
      throw Exception("Out-of-bounds: [$date] Days must be greater than 1!");
    }

    if (month == 2) {
      int d = ((year % 4 == 0 || (!(year % 100 == 0) && year % 400 == 0))
          ? 29
          : 28);
      if (day > d) {
        throw Exception(
            "Out-of-bounds: [$date] Days must be in [1, $d] range!");
      }
    }

    var days31 = {
      DateTime.january,
      DateTime.march,
      DateTime.may,
      DateTime.july,
      DateTime.august,
      DateTime.october,
      DateTime.december
    };
    var days30 = {
      DateTime.april,
      DateTime.june,
      DateTime.september,
      DateTime.november
    };
    if (day > 30 && days30.contains(month)) {
      throw Exception("Out-of-bounds: [$date] Years must be in [1, 30] range!");
    } else if (day > 31 && days31.contains(month)) {
      throw Exception("Out-of-bounds: [$date] Years must be in [1, 31] range!");
    }

    return DateTime(year, month, day);
  }
}
