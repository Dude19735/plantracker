class DataUtils {
  static DateTime getLastMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getNextSunday(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday % 7));
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
