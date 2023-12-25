import 'package:flutter/rendering.dart';
import 'package:scheduler/data_utils.dart';

enum DateStyle { full, noYear, newLine, weekly, weekly2, monthly }

enum WeekStyle { full, newLine, partial }

class Date {
  late int _year;
  late int _month;
  late int _day;

  static const List<int> _dpm = [
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];
  static const List<int> _dpmLpY = [
    31,
    29,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  static DateStyle getDateStyle(double width, TextStyle textStyle) {
    DateStyle res = DateStyle.full;

    int lines = DataUtils.getTextLines("  99.99.9999  ", textStyle, width);
    if (lines > 1) {
      res = DateStyle.noYear;
      lines = DataUtils.getTextLines("  99.99  ", textStyle, width);
      if (lines > 1) {
        res = DateStyle.newLine;
        lines = DataUtils.getTextLines("  99  ", textStyle, width);
        if (lines > 1) {
          res = DateStyle.weekly;
        }
      }
    }
    return res;
  }

  static WeekStyle getWeekStyle(double width, TextStyle textStyle) {
    var lines = DataUtils.getTextHeight(
        "  99.99.9999 - 99.99.9999  ", textStyle, width);
    WeekStyle res = WeekStyle.full;
    if (lines > 1) {
      res = WeekStyle.newLine;
    }
    return res;
  }

  Date(this._year, this._month, this._day) {
    _assert();
  }

  static String week2Str(Date fromDay, Date toDay,
      {WeekStyle style = WeekStyle.full}) {
    // TODO: do some locale stuff here
    String res;
    String df = fromDay.day().toString().padLeft(2, "0");
    String mf = fromDay.month().toString().padLeft(2, "0");
    String yf = fromDay.year().toString().padLeft(4, "0");
    String dt = toDay.day().toString().padLeft(2, "0");
    String mt = toDay.month().toString().padLeft(2, "0");
    String yt = toDay.year().toString().padLeft(4, "0");

    if (style == WeekStyle.full) {
      res = "$df.$mf.$yf - $dt.$mt.$yt";
    } else if (style == WeekStyle.partial) {
      res = "- $dt.$mt.\n$yt";
    } else {
      res = "$df.$mf.$yf -\n$dt.$mt.$yt";
    }

    return res;
  }

  @override
  String toString() {
    return Date.Date2Str(this);
  }

  static String Date2Str(Date day, {DateStyle style = DateStyle.full}) {
    // TODO: do some locale stuff here
    assert(style == DateStyle.full ||
        style == DateStyle.noYear ||
        style == DateStyle.newLine);

    String res;
    if (style == DateStyle.full) {
      res =
          "${day.day().toString().padLeft(2, '0')}.${day.month().toString().padLeft(2, '0')}.${day.year().toString().padLeft(4, '0')}";
    } else if (style == DateStyle.noYear) {
      res =
          "${day.day().toString().padLeft(2, '0')}.${day.month().toString().padLeft(2, '0')}";
    } else {
      res =
          "${day.day().toString().padLeft(2, '0')}\n${day.month().toString().padLeft(2, '0')}";
    }
    return res;
  }

  Date.today() {
    DateTime now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _day = now.day;
  }

  Date.fromDateTime(DateTime date) {
    _year = date.year;
    _month = date.month;
    _day = date.day;
  }

  Date.lastMonday() {
    DateTime now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _day = now.day;
    selfSubtractDays(now.weekday - 1);
  }

  // Date.nextSunday() {
  //   DateTime now = DateTime.now();
  //   _year = now.year;
  //   _month = now.month;
  //   _day = now.day;
  //   selfAddDays(7 - now.weekday % 7);
  //   print("next sunday");
  //   print(toFormatedString());
  // }

  Date.fromInt(int date) {
    _year = date ~/ 10000;
    _month = (date - _year * 10000) ~/ 100;
    _day = (date - _year * 10000 - _month * 100).round();

    _assert();
  }

  int day() => _day;
  int month() => _month;
  int year() => _year;
  bool isLeap() => _isLeap();
  int weekday() => DateTime(_year, _month, _day).weekday;

  DateTime toDateTime() {
    return DateTime(_year, _month, _day);
  }

  int compareTo(Date date) {
    if (date.year() == _year && date.month() == _month && date.day() == _day)
      return 0;
    if (date.year() < _year) return 1;
    if (date.year() == _year && date.month() < _month) return 1;
    if (date.year() == _year && date.month() == _month && date.day() < _day)
      return 1;
    return -1;
  }

  String toFormatedString() {
    return "${_day.toString().padLeft(2, '0')}.${_month.toString().padLeft(2, '0')}.$_year";
  }

  int absWindowSizeWith(Date date) {
    // this works because our dates don't have minutes and seconds
    return toDateTime().difference(date.toDateTime()).inDays.abs() + 1;
  }

  int absDiff(Date date) {
    // this works because our dates don't have minutes and seconds
    return toDateTime().difference(date.toDateTime()).inDays.abs();
  }

  int toInt() {
    return (_year * 10000 + _month * 100 + _day).round();
  }

  int toShortInt() {
    if (_year < 2000 || _year > 2099) {
      throw Exception(
          "Out-of-bounds: [$_year] Years must be in [1000, 9999] range!");
    }
    return ((_year - 2000) * 10000 + _month * 100 + _day).round();
  }

  void _addOneDay(List<int> dpm) {
    _day++;
    if (_day > dpm[_month - 1]) {
      _day = 1;
      _month++;
    }
    if (_month > 12) {
      _year++;
      _month = 1;
    }
  }

  void _subOneDay(List<int> dpm) {
    _day--;
    if (_day < 1) {
      _month--;
    }
    if (_month < 1) {
      _year--;
      _month = 12;
    }
    if (_day < 1) {
      _day = dpm[_month - 1];
    }
  }

  void selfSubtractDays(int days) {
    while (days > 0) {
      _subOneDay(_isLeap() ? _dpmLpY : _dpm);
      days--;
    }
  }

  Date subtractDays(int days) {
    var temp = Date(_year, _month, _day);

    while (days > 0) {
      temp._subOneDay(temp._isLeap() ? _dpmLpY : _dpm);
      days--;
    }
    return temp;
  }

  void selfAddDays(int days) {
    while (days > 0) {
      _addOneDay(_isLeap() ? _dpmLpY : _dpm);
      days--;
    }
  }

  Date addDays(int days) {
    var temp = Date(_year, _month, _day);

    while (days > 0) {
      temp._addOneDay(temp._isLeap() ? _dpmLpY : _dpm);
      days--;
    }
    return temp;
  }

  bool _isLeap() {
    return _year % 4 == 0 || (!(_year % 100 == 0) && _year % 400 == 0);
  }

  _assert() {
    if (_year < 1000 || _year > 9999) {
      throw Exception(
          "Out-of-bounds: [$_year] Years must be in [1000, 9999] range!");
    }

    if (_month < 1 || _month > 12) {
      throw Exception(
          "Out-of-bounds: [$_month] Month must be in [1, 12] range!");
    }

    if (_month != 2) {
      if (_isLeap()) {
        if (_day < 1 || _day > _dpmLpY[_month - 1]) {
          throw Exception(
              "Out-of-bounds: [$_day] Days must be in [1,${_dpmLpY[_month - 1]}] for a leap year!");
        }
      } else {
        if (_day < 1 || _day > _dpm[_month - 1]) {
          throw Exception(
              "Out-of-bounds: [$_day] Days must be greater in [1,${_dpmLpY[_month - 1]}] for a regular year!");
        }
      }
    } else {
      int d = _isLeap() ? 29 : 28;
      if (_day > d) {
        throw Exception(
            "Out-of-bounds: [$_day] Days must be in [1, $d] range for a February in a ${d == 28 ? "regular" : "leap"} year!");
      }
    }
  }
}
