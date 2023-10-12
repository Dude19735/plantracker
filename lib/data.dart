import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_gen.dart';
import 'package:scheduler/data_columns.dart';
import 'package:scheduler/data_utils.dart';
import 'package:collection/collection.dart';
import 'dart:collection';
import 'package:flutter/rendering.dart';

class DataChangedNotification extends Notification {}

class DataChangedNotificationSubjectData extends DataChangedNotification {}

class SubjectData {
  final int subjectId;
  String subjectAcronym;
  String subject;
  int active;
  int activeFromDate;
  int activeToDate;

  SubjectData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        subjectAcronym = data[ColumnName.subjectAcronym],
        subject = data[ColumnName.subject],
        active = data[ColumnName.active],
        activeFromDate = data[ColumnName.activeFromDate],
        activeToDate = data[ColumnName.activeToDate];

  @override
  String toString() {
    return "${ColumnName.subjectId}: $subjectId\n${ColumnName.subject}: $subject${ColumnName.active}: $active\n${ColumnName.activeFromDate}: $activeFromDate\n${ColumnName.activeToDate}: $activeToDate\n";
  }
}

class DataChangedNotificationTimeTableData extends DataChangedNotification {}

class TimeTableData {
  final int subjectId;
  final int date;
  double planed;
  double recorded;
  final String subject;

  TimeTableData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        date = data[ColumnName.date],
        subject = data[ColumnName.subject],
        planed = data[ColumnName.planed],
        recorded = data[ColumnName.recorded];

  @override
  String toString() {
    return "${ColumnName.subjectId}: $subjectId\n${ColumnName.date}: $date\n${ColumnName.subject}: $subject\n${ColumnName.planed}: $planed\n${ColumnName.recorded}: $recorded\n";
  }
}

class DataChangedNotificationSchedulePlanData extends DataChangedNotification {}

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

typedef TSubjectData = Map<int, SubjectData>;
typedef TSummaryData = List<SummaryData>;
// map by SubjectId then by Date
typedef TTimeTableData = Map<int, Map<int, TimeTableData>>;
// map by Date
typedef TSchedulePlanData = Map<int, List<SchedulePlanData>>;

class Data<D> {
  late final D data;

  Data() {
    if (D == TSubjectData) {
      data = <int, SubjectData>{} as D;
    }
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
      }
    } else if (D == TSchedulePlanData) {
      List<SchedulePlanData> d =
          json.map((item) => SchedulePlanData(item)).toList();
      data = groupBy(d, (SchedulePlanData elem) => elem.date) as D;
    } else if (D == TSubjectData) {
      List<SubjectData> temp = json.map((item) => SubjectData(item)).toList();
      var temp2 = groupBy(temp, (SubjectData elem) => elem.subjectId);
      var temp3 = <int, SubjectData>{};
      for (var k in temp2.keys) {
        temp3[k] = temp2[k]![0];
      }
      data = temp3 as D;
    } else {
      throw Exception("Message type [$D] not defined in data parser");
    }
  }

  @override
  String toString() {
    return data.toString();
  }
}

class _GlobalDataItem {
  final void Function() doAfter;
  final DateTime from;
  final DateTime to;
  final ScrollDirection direction;
  _GlobalDataItem(this.doAfter, this.from, this.to, this.direction);
}

class GlobalData {
  Map<int, double> minSubjectTextHeight = {};
  late Data<TSummaryData> summaryData;
  late Data<TTimeTableData> timeTableData;
  late Data<TSchedulePlanData> schedulePlanData;
  late Data<TSubjectData> subjectData;
  Queue<MapEntry<int, _GlobalDataItem>> _queue = Queue();
  int _val = 0;
  DateTime _initTime = DateTime.now().toUtc();

  late DateTime _fromDate;
  late DateTime _toDate;

  GlobalData() {
    timeTableData = Data();
    schedulePlanData = Data();
    summaryData = Data();

    // current week
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;
    _load(from, to);

    var adj = DataUtils.getAdjacentTimePeriods(from, to, ScrollDirection.idle);
    _load(adj["prev_from"], adj["prev_to"]);
    _load(adj["next_from"], adj["next_to"]);

    _fromDate = adj["prev_from"];
    _toDate = adj["next_to"];

    summaryFT(from, to);
    _subjects(_fromDate, _toDate);
  }

  void setSummaryTextHeight(TextStyle style, double summaryWidth) {
    for (var item in GlobalContext.data.summaryData.data) {
      double height =
          DataUtils.getTextHeight(item.subject, style, summaryWidth);
      GlobalContext.data.minSubjectTextHeight[item.subjectId] = height;
    }
  }

  void summaryFT(DateTime from, DateTime to) {
    int fromDate = DataUtils.dateTime2Int(from);
    int toDate = DataUtils.dateTime2Int(to);
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

      summaryData.data.add(SummaryData(pack));
    }

    summaryData.data.sort((a, b) => a.subject.compareTo(b.subject));

    for (var element in summaryData.data) {
      if (minSubjectTextHeight[element.subjectId] == null) {
        minSubjectTextHeight[element.subjectId] = 0;
      }
    }
  }

  void _subjects(DateTime fromDate, DateTime toDate) {
    subjectData = Data<TSubjectData>.fromJsonStr(
        DataGen.testDataSubjects(fromDate, toDate));
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
  }

  void _remove(DateTime day) {
    timeTableData.data.remove(DataUtils.dateTime2Int(day));
    schedulePlanData.data.remove(DataUtils.dateTime2Int(day));
  }

  void _delayedLoad(
      int val, DateTime from, DateTime to, ScrollDirection direction) {
    var adj = DataUtils.getAdjacentTimePeriods(from, to, direction);
    Debugger.data("Delayed load $val from $from to $to with $direction");
    var newFrom = adj["prev_from"];
    if (newFrom.compareTo(_fromDate) < 0) {
      // add new data on this side
      Debugger.data("prev load $newFrom to $_fromDate");
      _load(newFrom, DataUtils.subtractDays(_fromDate, 1));
      _fromDate = newFrom;
    } else if (newFrom.compareTo(_fromDate) > 0) {
      // remove unused data on this side
      // if we get to an idle state
      // avoid rapid database calls on wobbeling
      if (direction == ScrollDirection.idle) {
        for (DateTime d = _fromDate;
            d.compareTo(newFrom) < 0;
            d = DataUtils.addDays(d, 1)) {
          Debugger.data("prev remove $d");
          _remove(d);
        }
        _fromDate = newFrom;
      }
    }

    var newTo = adj["next_to"];
    if (newTo.compareTo(_toDate) < 0) {
      if (direction == ScrollDirection.idle) {
        // remove unused data on this side
        // if we get to an idle state
        // avoid rapid database calls on wobbeling
        for (DateTime d = DataUtils.addDays(newTo, 1);
            d.compareTo(_toDate) <= 0;
            d = DataUtils.addDays(d, 1)) {
          Debugger.data("next remove $d");
          _remove(d);
        }
        _toDate = newTo;
      }
    } else if (newTo.compareTo(_toDate) > 0) {
      // add new data on this side
      Debugger.data("next load $_toDate to $newTo");
      _load(DataUtils.addDays(_toDate, 1), newTo);
      _toDate = newTo;
    }

    summaryFT(from, to);
    _subjects(_fromDate, _toDate);
    Debugger.data("""###################################################
      fromDate: $_fromDate, toDate: $_toDate
      ###################################################""");
  }

  void loadFT(int waitMS, ScrollDirection direction, DateTime from, DateTime to,
      void Function() doAfter) {
    _val = _token(from, to);
    _queue.add(MapEntry(_val, _GlobalDataItem(doAfter, from, to, direction)));
    Debugger.data("--------> add to queue $_val $from $to");

    Future<void>.delayed(Duration(milliseconds: waitMS)).then((value) {
      Debugger.data(_queue.toString());
      var x = _queue.removeLast();
      if (_val == x.key) {
        Debugger.data("Load data $_val after $waitMS MS ${x.value.direction}");
        _delayedLoad(_val, x.value.from, x.value.to, x.value.direction);
        x.value.doAfter();
      } else {
        Debugger.data("skip loading");
      }
    });
  }

  int _token(DateTime from, DateTime to) {
    return Object.hash(
        DateTime.now().toUtc().difference(_initTime).inMicroseconds,
        DataUtils.dateTime2Int(from),
        DataUtils.dateTime2Int(to));
  }
}
