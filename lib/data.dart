import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_gen.dart';
import 'package:scheduler/data_columns.dart';
import 'package:scheduler/data_utils.dart';
import 'package:collection/collection.dart';
import 'dart:collection';
import 'package:flutter/rendering.dart';
import 'package:scheduler/date.dart';

class DataChangedNotification extends Notification {}

class DataChangedNotificationSubjectData extends DataChangedNotification {}

class SubjectData {
  final int subjectId;
  String subjectAcronym;
  String subjectName;
  Color subjectColor;
  int active;
  int activeFromDate;
  int activeToDate;

  SubjectData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        subjectAcronym = data[ColumnName.subjectAcronym],
        subjectName = data[ColumnName.subjectName],
        subjectColor = DataUtils.str2Color(data[ColumnName.subjectColor]),
        active = data[ColumnName.active],
        activeFromDate = data[ColumnName.activeFromDate],
        activeToDate = data[ColumnName.activeToDate];

  @override
  String toString() {
    return "${ColumnName.subjectId}: $subjectId\n${ColumnName.subjectName}: $subjectName${ColumnName.active}: $active\n${ColumnName.activeFromDate}: $activeFromDate\n${ColumnName.activeToDate}: $activeToDate\n";
  }
}

class DataChangedNotificationTimeTableData extends DataChangedNotification {}

class TimeTableData {
  final SubjectData subject;
  final int date;
  double planed;
  double recorded;

  TimeTableData(Map<String, dynamic> data, Data<TSubjectData> subjectData)
      : subject = subjectData.data[data[ColumnName.subjectId]]!,
        date = data[ColumnName.date],
        planed = data[ColumnName.planedTime],
        recorded = data[ColumnName.recordedTime];

  @override
  String toString() {
    return "${ColumnName.subjectId}: ${subject.subjectId}\n${ColumnName.date}: $date\n${ColumnName.subjectName}: ${subject.subjectName}\n${ColumnName.planedTime}: $planed\n${ColumnName.recordedTime}: $recorded\n";
  }
}

class DataChangedNotificationSchedulePlanData extends DataChangedNotification {}

class ScheduleData {
  final SubjectData subject;
  final int date;
  final double fromTime;
  final double toTime;

  ScheduleData(this.subject, this.date, this.fromTime, this.toTime);

  @override
  String toString() {
    return "${ColumnName.date}: $date\n${ColumnName.fromTime}: $fromTime\n${ColumnName.toTime}: $toTime\n";
  }
}

class ScheduleRecordedData extends ScheduleData {
  final int workUnitId;
  final int? workUnitGroupId;
  final WorkUnitType workUnitType;

  ScheduleRecordedData(
      Map<String, dynamic> data, Data<TSubjectData> subjectData)
      : workUnitId = data[ColumnName.workUnitId],
        workUnitGroupId = data[ColumnName.workUnitGroupId],
        workUnitType = WorkUnitType.values[data[ColumnName.workUnitType]],
        super(
            subjectData.data[data[ColumnName.subjectId]]!,
            data[ColumnName.date],
            data[ColumnName.fromTime],
            data[ColumnName.toTime]);

  @override
  String toString() {
    return "${ColumnName.workUnitId}: $workUnitId\n${ColumnName.subjectId}: ${subject.subjectId}\n${ColumnName.workUnitGroupId}: $workUnitGroupId\n${ColumnName.workUnitType}: $workUnitType\n${ColumnName.date}: $date\n${ColumnName.fromTime}: $fromTime\n${ColumnName.toTime}: $toTime\n";
  }
}

class SchedulePlanData extends ScheduleData {
  final int workTypeId;
  final String workType;
  final int seriesId;
  final int seriesFromDate;
  final int seriesToDate;
  final int noteId;
  final String note;

  SchedulePlanData(Map<String, dynamic> data, Data<TSubjectData> subjectData)
      : workTypeId = data[ColumnName.planUnitTypeId],
        workType = data[ColumnName.planUnitType],
        seriesId = data[ColumnName.seriesId],
        seriesFromDate = data[ColumnName.seriesFromDate],
        seriesToDate = data[ColumnName.seriesToDate],
        noteId = data[ColumnName.noteId],
        note = data[ColumnName.note],
        super(
            subjectData.data[data[ColumnName.subjectId]]!,
            data[ColumnName.date],
            data[ColumnName.fromTime],
            data[ColumnName.toTime]);

  @override
  String toString() {
    return "${ColumnName.subjectId}: ${subject.subjectId}\n${ColumnName.subjectAcronym}: ${subject.subjectAcronym}\n${ColumnName.subjectName}: ${subject.subjectName}\n${ColumnName.planUnitTypeId}: $workTypeId\n${ColumnName.planUnitType}: $workType\n${ColumnName.seriesId}: $seriesId\n${ColumnName.seriesFromDate}: $seriesFromDate\n${ColumnName.seriesToDate}: $seriesToDate\n${ColumnName.noteId}: $noteId\n${ColumnName.note}: $note\n${ColumnName.date}: $date\n${ColumnName.fromTime}: $fromTime\n${ColumnName.toTime}: $toTime\n";
  }
}

class SummaryData {
  final int subjectId;
  final double planed;
  final double recorded;
  final String subject;

  SummaryData(Map<String, dynamic> data)
      : subjectId = data[ColumnName.subjectId],
        subject = data[ColumnName.subjectName],
        planed = data[ColumnName.planedTime],
        recorded = data[ColumnName.recordedTime];

  @override
  String toString() {
    return "${ColumnName.subjectName}: $subject\n${ColumnName.planedTime}: $planed\n${ColumnName.recordedTime}: $recorded\n";
  }
}

typedef TSubjectData = Map<int, SubjectData>;
typedef TSummaryData = List<SummaryData>;
// map by SubjectId then by Date
typedef TTimeTableData = Map<int, Map<int, TimeTableData>>;
// map by Date
typedef TSchedulePlanData = Map<int, List<SchedulePlanData>>;
typedef TScheduleRecordedData = Map<int, List<ScheduleRecordedData>>;

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
    } else if (D == TScheduleRecordedData) {
      // ignore: prefer_collection_literals
      data = <int, List<ScheduleRecordedData>>{} as D;
    } else {
      throw Exception("Message type [$D] not defined in data parser");
    }
  }

  Data.fromJsonStr(String jsonStr, Data<TSubjectData>? subjectData) {
    List<dynamic> json = jsonDecode(jsonStr);
    if (D == TSummaryData) {
      // data = TSummaryData.empty() as D;

      data = json.map((item) => SummaryData(item)).toList() as D;
    } else if (D == TTimeTableData) {
      data = <int, Map<int, TimeTableData>>{} as D;

      List<TimeTableData> d =
          json.map((item) => TimeTableData(item, subjectData!)).toList();
      var temp = groupBy(d, (TimeTableData elem) => elem.subject.subjectId);
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
          json.map((item) => SchedulePlanData(item, subjectData!)).toList();
      data = groupBy(d, (SchedulePlanData elem) => elem.date) as D;
      // data = json.map((item) => SchedulePlanData(item)).toList() as D;
    } else if (D == TScheduleRecordedData) {
      List<ScheduleRecordedData> d =
          json.map((item) => ScheduleRecordedData(item, subjectData!)).toList();
      data = groupBy(d, (ScheduleRecordedData elem) => elem.date) as D;
      // data = json.map((item) => SchedulePlanData(item)).toList() as D;
    } else if (D == TSubjectData) {
      List<SubjectData> temp = json.map((item) => SubjectData(item)).toList();
      var temp2 = groupBy(temp, (SubjectData elem) => elem.subjectId);
      var temp3 = <int, SubjectData>{};
      for (var k in temp2.keys) {
        temp3[k] = temp2[k]![0];
      }
      data = temp3 as D;
    } else {
      throw Exception(
          "Message type [$D] not defined in data parser\n(This is my own exception inside Data.fromJsonStr(String jsonStr) constructor ;-))");
    }
  }

  @override
  String toString() {
    return data.toString();
  }
}

class _GlobalDataItem {
  final void Function() doAfter;
  final Date from;
  final Date to;
  final ScrollDirection direction;
  _GlobalDataItem(this.doAfter, this.from, this.to, this.direction);
}

class GlobalData {
  Map<int, double> minSubjectTextHeight = {};
  late Data<TSubjectData> subjectData;
  late Data<TSummaryData> summaryData;
  late Data<TTimeTableData> timeTableData;
  late Data<TSchedulePlanData> schedulePlanData;
  late Data<TScheduleRecordedData> scheduleRecordedData;
  Queue<MapEntry<int, _GlobalDataItem>> _queue = Queue();
  int _val = 0;
  Date _initTime = Date.today();

  late Date _fromDate;
  late Date _toDate;

  GlobalData() {
    timeTableData = Data();
    schedulePlanData = Data();
    scheduleRecordedData = Data();
    summaryData = Data();

    // current week
    var from = GlobalContext.fromDateWindow;
    var to = GlobalContext.toDateWindow;

    var adj = DataUtils.getAdjacentTimePeriods(from, to, ScrollDirection.idle);
    _fromDate = adj["prev_from"];
    _toDate = adj["next_to"];
    _subjects(_fromDate, _toDate);
    _load(from, to, subjectData);
    _load(adj["prev_from"], adj["prev_to"], subjectData);
    _load(adj["next_from"], adj["next_to"], subjectData);

    summaryFT(from, to);
  }

  void setSummaryTextHeight(TextStyle style, double summaryWidth) {
    for (var item in GlobalContext.data.summaryData.data) {
      double height =
          DataUtils.getTextHeight(item.subject, style, summaryWidth);
      GlobalContext.data.minSubjectTextHeight[item.subjectId] = height;
    }
  }

  void summaryFT(Date from, Date to) {
    int fromDate = from.toInt();
    int toDate = to.toInt();
    summaryData.data.clear();
    for (var subjectId in timeTableData.data.keys) {
      double planed = 0;
      double recorded = 0;
      String subjectName = "";
      var subject = timeTableData.data[subjectId]!;
      for (var date in subject.keys) {
        if (subjectName == "") {
          subjectName = subject[date]!.subject.subjectName;
        }
        if (date < fromDate || date > toDate) continue;
        planed += subject[date]!.planed;
        recorded += subject[date]!.recorded;
      }
      var pack = {
        ColumnName.subjectId: subjectId,
        ColumnName.planedTime: planed,
        ColumnName.recordedTime: recorded,
        ColumnName.subjectName: subjectName
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

  void _subjects(Date fromDate, Date toDate) {
    subjectData = Data<TSubjectData>.fromJsonStr(
        DataGen.testDataSubjects(fromDate, toDate), null);
    // print("hello");
  }

  void _load(Date fromDate, Date toDate, Data<TSubjectData> subjectData) {
    var ttimeTableData = Data<TTimeTableData>.fromJsonStr(
        DataGen.testDataTimeTableView(fromDate, toDate), subjectData);

    for (var subjectId in ttimeTableData.data.keys) {
      if (timeTableData.data[subjectId] != null) {
        timeTableData.data[subjectId]!.addAll(ttimeTableData.data[subjectId]!);
      } else {
        timeTableData.data[subjectId] = ttimeTableData.data[subjectId]!;
      }
    }

    var tschedulePlanData = Data<TSchedulePlanData>.fromJsonStr(
        DataGen.testDateScheduleViewPlan(fromDate, toDate), subjectData);
    schedulePlanData.data.addAll(tschedulePlanData.data);

    var tscheduleRecordedData = Data<TScheduleRecordedData>.fromJsonStr(
        DataGen.testWorkRecord(fromDate, toDate), subjectData);
    scheduleRecordedData.data.addAll(tscheduleRecordedData.data);
  }

  void _remove(Date day) {
    timeTableData.data.remove(day.toInt());
    schedulePlanData.data.remove(day.toInt());
  }

  void _delayedLoad(int val, Date from, Date to, ScrollDirection direction) {
    var adj = DataUtils.getAdjacentTimePeriods(from, to, direction);
    Debugger.data("Delayed load $val from $from to $to with $direction");

    _subjects(_fromDate, _toDate);

    var newFrom = adj["prev_from"];
    if (newFrom.compareTo(_fromDate) < 0) {
      // add new data on this side
      Debugger.data("prev load $newFrom to $_fromDate");
      _load(newFrom, _fromDate.subtractDays(1), subjectData);
      _fromDate = newFrom;
    } else if (newFrom.compareTo(_fromDate) > 0) {
      // remove unused data on this side
      // if we get to an idle state
      // avoid rapid database calls on wobbeling
      if (direction == ScrollDirection.idle) {
        for (Date d = _fromDate; d.compareTo(newFrom) < 0; d = d.addDays(1)) {
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
        for (Date d = newTo.addDays(1);
            d.compareTo(_toDate) <= 0;
            d = d.addDays(1)) {
          Debugger.data("next remove $d");
          _remove(d);
        }
        _toDate = newTo;
      }
    } else if (newTo.compareTo(_toDate) > 0) {
      // add new data on this side
      Debugger.data("next load $_toDate to $newTo");
      _load(_toDate.addDays(1), newTo, subjectData);
      _toDate = newTo;
    }

    summaryFT(from, to);
    Debugger.data("""###################################################
      fromDate: $_fromDate, toDate: $_toDate
      ###################################################""");
  }

  void loadFT(int waitMS, ScrollDirection direction, Date from, Date to,
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

  int _token(Date from, Date to) {
    return Object.hash(
        DateTime.now()
            .toUtc()
            .difference(
                DateTime(_initTime.year(), _initTime.month(), _initTime.day()))
            .inMicroseconds,
        from.toInt(),
        to.toInt());
  }
}
