import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_gen.dart';
import 'package:scheduler/data_columns.dart';
import 'package:scheduler/data_utils.dart';
import 'package:collection/collection.dart';

class TimeTableData {
  final int subjectId;
  final int date;
  final double planed;
  final double recorded;
  final String subject;

  TimeTableData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        date = data[ColumnName.date],
        subject = data[ColumnName.subject],
        planed = data[ColumnName.planed],
        recorded = data[ColumnName.recorded];

  @override
  String toString() {
    return "${ColumnName.date}: $date\n${ColumnName.subject}: $subject\n${ColumnName.planed}: $planed\n${ColumnName.recorded}: $recorded\n";
  }
}

class SchedulePlanData {
  final int subjectId;
  final String subjectAcronym;
  final String subject;
  final int workTypeId;
  final String workType;
  final int seriesId;
  final int seriesFromDate;
  final int seriesToDate;
  final int noteId;
  final String note;
  final int date;
  final double fromTime;
  final double toTime;

  SchedulePlanData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        subjectAcronym = data[ColumnName.subjectAcronym],
        subject = data[ColumnName.subject],
        workTypeId = data[ColumnName.workTypeId],
        workType = data[ColumnName.workType],
        seriesId = data[ColumnName.seriesId],
        seriesFromDate = data[ColumnName.seriesFromDate],
        seriesToDate = data[ColumnName.seriesToDate],
        noteId = data[ColumnName.noteId],
        note = data[ColumnName.note],
        date = data[ColumnName.date],
        fromTime = data[ColumnName.fromTime],
        toTime = data[ColumnName.toTime];

  @override
  String toString() {
    return "${ColumnName.subjectId}: $subjectId\n${ColumnName.subjectAcronym}: $subjectAcronym\n${ColumnName.subject}: $subject\n${ColumnName.workTypeId}: $workTypeId\n${ColumnName.workType}: $workType\n${ColumnName.seriesId}: $seriesId\n${ColumnName.seriesFromDate}: $seriesFromDate\n${ColumnName.seriesToDate}: $seriesToDate\n${ColumnName.noteId}: $noteId\n${ColumnName.note}: $note\n${ColumnName.date}: $date\n${ColumnName.fromTime}: $fromTime\n${ColumnName.toTime}: $toTime\n";
  }
}

class SummaryData {
  final int subjectId;
  final double planed;
  final double recorded;
  final String subject;

  SummaryData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        subject = data[ColumnName.subject],
        planed = data[ColumnName.planed],
        recorded = data[ColumnName.recorded];

  @override
  String toString() {
    return "${ColumnName.subject}: $subject\n${ColumnName.planed}: $planed\n${ColumnName.recorded}: $recorded\n";
  }
}

typedef TSummaryData = List<SummaryData>;
// map by SubjectId then by Date
typedef TTimeTableData = Map<int, Map<int, TimeTableData>>;
// map by Date
typedef TSchedulePlanData = Map<int, List<SchedulePlanData>>;

class Data<D> {
  late final D data;
  // late final Map<int, Rect> rects;

  // Data.init() {
  // if (D == TSummaryData) {
  //   data = TSummaryData.empty() as D;
  // } else if (D == TTimeTableData) {
  //   // ignore: prefer_collection_literals
  //   data = TTimeTableData() as D;
  // } else if (D == TSchedulePlanData) {
  //   // ignore: prefer_collection_literals
  //   data = TSchedulePlanData() as D;
  // } else {
  //   throw Exception("Message type [$D] not defined in data parser");
  // }
  // }

  Data() {
    if (D == TSummaryData) {
      data = TSummaryData.empty(growable: true) as D;
    } else if (D == TTimeTableData) {
      // ignore: prefer_collection_literals
      data = <int, Map<int, TimeTableData>>{} as D;
    } else if (D == TSchedulePlanData) {
      // ignore: prefer_collection_literals
      data = <int, List<SchedulePlanData>>{} as D;
    } else {
      throw Exception("Message type [$D] not defined in data parser");
    }
  }

  Data.fromJsonStr(String jsonStr) {
    // if (D == TSummaryData) {
    // } else if (D == TTimeTableData) {
    //   // ignore: prefer_collection_literals
    // } else if (D == TSchedulePlanData) {
    //   // ignore: prefer_collection_literals
    // } else {
    //   throw Exception("Message type [$D] not defined in data parser");
    // }

    List<dynamic> json = jsonDecode(jsonStr);
    if (D == TSummaryData) {
      // data = TSummaryData.empty() as D;

      data = json.map((item) => SummaryData(item)).toList() as D;
    } else if (D == TTimeTableData) {
      data = <int, Map<int, TimeTableData>>{} as D;

      List<TimeTableData> d = json.map((item) => TimeTableData(item)).toList();
      var temp = groupBy(d, (TimeTableData elem) => elem.subjectId);
      for (var subjectId in temp.keys) {
        var t = groupBy(temp[subjectId] as List<TimeTableData>,
            (TimeTableData elem) => elem.date);

        for (var elemK in t.keys) {
          var elem = t[elemK]!;
          if ((data as Map)[subjectId] == null) {
            (data as Map)[subjectId] = {elemK: elem[0]};
          } else {
            (data as Map)[subjectId][elemK] = elem[0];
          }
        }
        // (data as Map)[subjectId]
      }
    } else if (D == TSchedulePlanData) {
      // data = <int, List<SchedulePlanData>>{} as D;

      List<SchedulePlanData> d =
          json.map((item) => SchedulePlanData(item)).toList();
      data = groupBy(d, (SchedulePlanData elem) => elem.date) as D;
    } else {
      throw Exception("Message type [$D] not defined in data parser");
    }
    // data = (json['data'] as List)
    //     .map((item) => (item as Map<String, dynamic>)
    //         .map((key, value) => MapEntry(key, value.toString())))
    //     .toList();
  }

  @override
  String toString() {
    return data.toString();
  }
}

class GlobalData {
  Map<int, double> minSubjectTextHeight = {};
  late Data<TSummaryData> summaryData;
  late Data<TTimeTableData> timeTableData;
  late Data<TSchedulePlanData> schedulePlanData;

  late DateTime _fromDate;
  late DateTime _toDate;

  GlobalData() {
    timeTableData = Data();
    schedulePlanData = Data();
    summaryData = Data();

    int dateWindowSize = GlobalContext.fromDateWindow
        .difference(GlobalContext.toDateWindow)
        .inDays
        .abs();

    // print(GlobalContext.fromDateWindow);
    // print(GlobalContext.toDateWindow);
    _load(GlobalContext.fromDateWindow, GlobalContext.toDateWindow);
    // timeTableData.data.forEach((key, value) {
    //   print(value.keys);
    // });
    // print("==============================");
    _load(GlobalContext.fromDateWindow.subtract(Duration(days: dateWindowSize)),
        GlobalContext.toDateWindow.subtract(Duration(days: 1)));
    // timeTableData.data.forEach((key, value) {
    //   print(value.keys);
    // });
    // print("==============================");
    _load(GlobalContext.fromDateWindow.add(Duration(days: dateWindowSize + 1)),
        GlobalContext.toDateWindow.add(Duration(days: 2 * dateWindowSize)));
    // timeTableData.data.forEach((key, value) {
    //   print(value.keys);
    // });
    // print("==============================");

    _fromDate =
        GlobalContext.fromDateWindow.subtract(Duration(days: dateWindowSize));
    _toDate = GlobalContext.toDateWindow.add(Duration(days: dateWindowSize));

    _summary();
  }

  // DateTime fromDate() => _fromDate;
  // DateTime toDate() => _toDate;
  // int dateRange() => _toDate.difference(_fromDate).inDays.abs();

  void _summary() {
    // summaryData = Data<TSummaryData>.fromJsonStr(DataGen.testDataSummaryView(
    //     GlobalContext.fromDateWindow, GlobalContext.toDateWindow));

    int fromDate = DataUtils.dateTime2Int(GlobalContext.fromDateWindow);
    int toDate = DataUtils.dateTime2Int(GlobalContext.toDateWindow);

    summaryData.data.clear();
    for (var subjectId in timeTableData.data.keys) {
      double planed = 0;
      double recorded = 0;
      String subjectName = "";
      var subject = timeTableData.data[subjectId]!;
      for (var date in subject.keys) {
        if (subjectName == "") {
          subjectName = subject[date]!.subject;
        }
        if (date < fromDate || date > toDate) continue;
        planed += subject[date]!.planed;
        recorded += subject[date]!.recorded;
      }
      var pack = {
        ColumnName.subjectId: subjectId,
        ColumnName.planed: planed,
        ColumnName.recorded: recorded,
        ColumnName.subject: subjectName
      };
      // print(pack);
      summaryData.data.add(SummaryData(pack));
    }

    summaryData.data.sort((a, b) => a.subject.compareTo(b.subject));

    for (var element in summaryData.data) {
      minSubjectTextHeight[element.subjectId] = 0;
    }
  }

  void _load(DateTime fromDate, DateTime toDate) {
    var ttimeTableData = Data<TTimeTableData>.fromJsonStr(
        DataGen.testDataTimeTableView(fromDate, toDate));
    for (var subjectId in ttimeTableData.data.keys) {
      if (timeTableData.data[subjectId] != null) {
        timeTableData.data[subjectId]!.addAll(ttimeTableData.data[subjectId]!);
      } else {
        timeTableData.data[subjectId] = ttimeTableData.data[subjectId]!;
      }
    }

    var tschedulePlanData = Data<TSchedulePlanData>.fromJsonStr(
        DataGen.testDateScheduleViewPlan(fromDate, toDate));
    schedulePlanData.data.addAll(tschedulePlanData.data);

    // requirement
    // timeTableData.data.forEach((key, value) {
    //   value.sort((a, b) => a.subject.compareTo(b.subject));
    // });
    // schedulePlanData.data.forEach((key, value) {
    //   value.sort((a, b) => a.subject.compareTo(b.subject));
    // });
  }

  void _remove(DateTime day) {
    timeTableData.data.remove(DataUtils.dateTime2Int(day));
    schedulePlanData.data.remove(DataUtils.dateTime2Int(day));
  }

  void load() {
    int dateWindowSize = GlobalContext.toDateWindow
        .difference(GlobalContext.fromDateWindow)
        .inDays
        .abs();
    DateTime fromDate =
        GlobalContext.fromDateWindow.subtract(Duration(days: dateWindowSize));
    DateTime toDate =
        GlobalContext.toDateWindow.add(Duration(days: dateWindowSize));

    if (fromDate.compareTo(_fromDate) < 0) {
      // add new data on this side
      _load(fromDate, _fromDate.subtract(Duration(days: 1)));
    } else if (fromDate.compareTo(_fromDate) > 0) {
      // remove unused data on this side
      for (DateTime d = _fromDate;
          d.compareTo(fromDate) < 0;
          d = d.add(Duration(days: 1))) {
        _remove(d);
      }
    }

    if (toDate.compareTo(_toDate) < 0) {
      // remove unused data on this side
      for (DateTime d = toDate;
          d.compareTo(_toDate) < 0;
          d = d.add(Duration(days: 1))) {
        _remove(d);
      }
    } else if (toDate.compareTo(_toDate) > 0) {
      // add new data on this side
      _load(_toDate.add(Duration(days: 1)), toDate);
    }

    _fromDate = fromDate;
    _toDate = toDate;
  }
}
