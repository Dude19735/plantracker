import 'dart:convert';
import 'dart:math';
import 'package:scheduler/data_utils.dart';
import 'package:collection/collection.dart';

class ColumnName {
  static const String date = "Date";
  static const String fromTime = "FromTime";
  static const String toTime = "ToTime";
  static const String planed = "Planed";
  static const String recorded = "Recorded";
  static const String subject = "Subject";
  static const String subjectAcronym = "SubjectAcronym";
  static const String subjectId = "SubjectId";
  static const String workTypeId = "WorkTypeId";
  static const String workType = "WorkType";
  static const String seriesId = "SeriesId";
  static const String series = "Series";
  static const String seriesFromDate = "SeriesFromDate";
  static const String seriesToDate = "SeriesToDate";
  static const String noteId = "NoteId";
  static const String note = "Note";
}

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
    return "\n${ColumnName.date}: $date\n${ColumnName.subject}: $subject\n${ColumnName.planed}: $planed\n${ColumnName.recorded}: $recorded\n";
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
    return "\n${ColumnName.subjectId}: $subjectId\n${ColumnName.subjectAcronym}: $subjectAcronym\n${ColumnName.subject}: $subject\n${ColumnName.workTypeId}: $workTypeId\n${ColumnName.workType}: $workType\n${ColumnName.seriesId}: $seriesId\n${ColumnName.seriesFromDate}: $seriesFromDate\n${ColumnName.seriesToDate}: $seriesToDate\n${ColumnName.noteId}: $noteId\n${ColumnName.note}: $note\n${ColumnName.date}: $date\n${ColumnName.fromTime}: $fromTime\n${ColumnName.toTime}: $toTime";
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
    return "\n${ColumnName.subject}: $subject\n${ColumnName.planed}: $planed\n${ColumnName.recorded}: $recorded\n";
  }
}

class Data<D> {
  late final List<String> header;
  late final List<D> data;

  static String testDateScheduleViewPlan(DateTime fromDate, DateTime toDate) {
    int range = fromDate.difference(toDate).inDays.abs() + 1;
    Random rand = Random();
    rand.nextInt(range);

    return """{
      "header": [
        "${ColumnName.subjectId}",
        "${ColumnName.subjectAcronym}",
        "${ColumnName.subject}",
        "${ColumnName.workTypeId}",
        "${ColumnName.workType}",  
        "${ColumnName.seriesId}",    
        "${ColumnName.seriesFromDate}",
        "${ColumnName.seriesToDate}",
        "${ColumnName.noteId}",
        "${ColumnName.note}",      
        "${ColumnName.date}",        
        "${ColumnName.fromTime}",
        "${ColumnName.toTime}"
      ],        
      "data": [
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.subjectAcronym}": "Acr-1",
          "${ColumnName.subject}": "Subject-1",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 1,
          "${ColumnName.note}": "Note-S1-1",      
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},        
          "${ColumnName.fromTime}": ${3.0 * 60 * 60},
          "${ColumnName.toTime}": ${4.5 * 60 * 60}
        },
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.subjectAcronym}": "Acr-1",
          "${ColumnName.subject}": "Subject-1",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",
          "${ColumnName.seriesId}": -1,
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 2,
          "${ColumnName.note}": "Note-S1-2",
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},
          "${ColumnName.fromTime}": ${4.75 * 60 * 60},
          "${ColumnName.toTime}": ${6.0 * 60 * 60}
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.subjectAcronym}": "Acr-2",
          "${ColumnName.subject}": "Subject-2",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",
          "${ColumnName.seriesId}": -1,
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 3,
          "${ColumnName.note}": "Note-S2-1",
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},
          "${ColumnName.fromTime}": ${6.0 * 60 * 60},
          "${ColumnName.toTime}": ${7.25 * 60 * 60}
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.subjectAcronym}": "Acr-2",
          "${ColumnName.subject}": "Subject-2",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",
          "${ColumnName.seriesId}": -1,
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 4,
          "${ColumnName.note}": "Note-S2-2",
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},
          "${ColumnName.fromTime}": ${7.5 * 60 * 60},
          "${ColumnName.toTime}": ${8.25 * 60 * 60}
        },
        {
          "${ColumnName.subjectId}": 3,
          "${ColumnName.subjectAcronym}": "Acr-3",
          "${ColumnName.subject}": "Subject-3",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",
          "${ColumnName.seriesId}": -1,
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 5,
          "${ColumnName.note}": "Note-S3-1",
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},
          "${ColumnName.fromTime}": ${8.5 * 60 * 60},
          "${ColumnName.toTime}": ${9.75 * 60 * 60}
        },
        {
          "${ColumnName.subjectId}": 4,
          "${ColumnName.subjectAcronym}": "Acr-4",
          "${ColumnName.subject}": "Subject-4",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",
          "${ColumnName.seriesId}": -1,
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 6,
          "${ColumnName.note}": "Note-S4-1",
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},
          "${ColumnName.fromTime}": ${10.0 * 60 * 60},
          "${ColumnName.toTime}": ${12.0 * 60 * 60}
        },
        {
          "${ColumnName.subjectId}": 5,
          "${ColumnName.subjectAcronym}": "Acr-5",
          "${ColumnName.subject}": "Subject-5",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",
          "${ColumnName.seriesId}": -1,
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.seriesToDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.noteId}": 7,
          "${ColumnName.note}": "Note-S5-1",
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: rand.nextInt(range))))},
          "${ColumnName.fromTime}": ${13.0 * 60 * 60},
          "${ColumnName.toTime}": ${14.8 * 60 * 60}
        }
      ]
    }""";
  }

  static String testDataTimeTableView(DateTime fromDate, DateTime toDate) {
    int range = fromDate.difference(toDate).inDays.abs() + 1;
    Random rand = Random();
    rand.nextInt(range);

    int s1 = rand.nextInt(range);
    int s2 = rand.nextInt(range);
    int s3 = rand.nextInt(range);
    int s4 = rand.nextInt(range);
    int s5 = rand.nextInt(range);
    int s6 = rand.nextInt(range);

    return """{
      "header": [
        "${ColumnName.subjectId}",
        "${ColumnName.date}",
        "${ColumnName.planed}",
        "${ColumnName.recorded}",
        "${ColumnName.subject}"
      ],
      "data": [
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: s1)))},
          "${ColumnName.planed}": 15.0,
          "${ColumnName.recorded}": 17.5,
          "${ColumnName.subject}": "Sub1"
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: s2)))},
          "${ColumnName.planed}": 14.0,
          "${ColumnName.recorded}": 13.9,
          "${ColumnName.subject}": "Sub2"
        },
        {
          "${ColumnName.subjectId}": 3,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: s3)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub3"
        },
        {
          "${ColumnName.subjectId}": 4,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: s4)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub4"
        },  
        {
          "${ColumnName.subjectId}": 5,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: s5)))},
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub5"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: s6)))},
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub6"
        },
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s1 + 2) % 7)))},
          "${ColumnName.planed}": 15.0,
          "${ColumnName.recorded}": 17.5,
          "${ColumnName.subject}": "Sub1"
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s2 + 3) % 7)))},
          "${ColumnName.planed}": 14.0,
          "${ColumnName.recorded}": 13.9,
          "${ColumnName.subject}": "Sub2"
        },
        {
          "${ColumnName.subjectId}": 3,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s3 + 1) % 7)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub3"
        },
        {
          "${ColumnName.subjectId}": 4,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s4 + 4) % 7)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub4"
        },  
        {
          "${ColumnName.subjectId}": 5,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s5 + 2) % 7)))},
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub5"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s6 + 1) % 7)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 6.0,
          "${ColumnName.subject}": "Sub6"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(fromDate.add(Duration(days: (s6 + 3) % 7)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 6.0,
          "${ColumnName.subject}": "Sub6"
        }
      ]
    }""";
  }

  static String testDataSummaryView(DateTime fromDate, DateTime toDate) {
    return """{
      "header": [
        "${ColumnName.subjectId}", "${ColumnName.planed}", "${ColumnName.recorded}", "${ColumnName.subject}"],
      "data": [
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.planed}": 15.0,
          "${ColumnName.recorded}": 17.5,
          "${ColumnName.subject}": "jslkjopivmlkaoiesoairejlökmvaoijseoijasoeihoivnkcoieklllöksamoivoie"
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.planed}": 14.0,
          "${ColumnName.recorded}": 13.9,
          "${ColumnName.subject}": "Sub2"
        },
        {
          "${ColumnName.subjectId}": 3,
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub3"
        },
        {
          "${ColumnName.subjectId}": 4,
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub4"
        },  
        {
          "${ColumnName.subjectId}": 5,
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub5"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub6"
        }
      ]
    }""";
  }

  Data.fromJsonStr(String jsonStr) {
    Map<String, dynamic> json = jsonDecode(jsonStr);
    header = (json['header'] as List).map((item) => item as String).toList();
    if (D == SummaryData) {
      data = (json['data'] as List).map((item) => SummaryData(item)).toList()
          as List<D>;
    } else if (D == TimeTableData) {
      data = (json['data'] as List).map((item) => TimeTableData(item)).toList()
          as List<D>;
    } else if (D == SchedulePlanData) {
      data = (json['data'] as List)
          .map((item) => SchedulePlanData(item))
          .toList() as List<D>;
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
    return "${header.toString()} \n ${data.toString()}";
  }
}

enum GlobalDataFrame { previous, current, next, temp }

class GlobalData {
  Map<int, double> minSubjectTextHeight = {};
  late Map<GlobalDataFrame, Data<SummaryData>> summaryData;
  late Map<GlobalDataFrame, Data<TimeTableData>> timeTableData;
  late Map<GlobalDataFrame, Data<SchedulePlanData>> schedulePlanData;

  DateTime _fromDate;
  DateTime _toDate;

  GlobalData(this._fromDate, this._toDate) {
    int diff = _fromDate.difference(_toDate).inDays.abs();
    Duration d = Duration(days: diff + 1);

    summaryData = {
      GlobalDataFrame.previous: Data<SummaryData>.fromJsonStr(
          Data.testDataSummaryView(_fromDate.subtract(d), _toDate.subtract(d))),
      GlobalDataFrame.current: Data<SummaryData>.fromJsonStr(
          Data.testDataSummaryView(_fromDate, _toDate)),
      GlobalDataFrame.next: Data<SummaryData>.fromJsonStr(
          Data.testDataSummaryView(_fromDate.add(d), _toDate.add(d)))
    };

    timeTableData = {
      GlobalDataFrame.previous: Data<TimeTableData>.fromJsonStr(
          Data.testDataTimeTableView(
              _fromDate.subtract(d), _toDate.subtract(d))),
      GlobalDataFrame.current: Data<TimeTableData>.fromJsonStr(
          Data.testDataTimeTableView(_fromDate, _toDate)),
      GlobalDataFrame.next: Data<TimeTableData>.fromJsonStr(
          Data.testDataTimeTableView(_fromDate.add(d), _toDate.add(d)))
    };

    schedulePlanData = {
      GlobalDataFrame.previous: Data<SchedulePlanData>.fromJsonStr(
          Data.testDateScheduleViewPlan(
              _fromDate.subtract(d), _toDate.subtract(d))),
      GlobalDataFrame.current: Data<SchedulePlanData>.fromJsonStr(
          Data.testDateScheduleViewPlan(_fromDate, _toDate)),
      GlobalDataFrame.next: Data<SchedulePlanData>.fromJsonStr(
          Data.testDateScheduleViewPlan(_fromDate.add(d), _toDate.add(d)))
    };

    // requirement
    summaryData.forEach((key, value) {
      value.data.sort((a, b) => a.subject.compareTo(b.subject));
    });
    timeTableData.forEach((key, value) {
      value.data.sort((a, b) => a.subject.compareTo(b.subject));
    });
    timeTableData.forEach((key, value) {
      value.data.sort((a, b) => a.date.compareTo(b.date));
    });
    schedulePlanData.forEach((key, value) {
      value.data.sort((a, b) => a.date.compareTo(b.date));
    });

    summaryData.forEach((key, value) {
      value.data.forEach((element) {
        minSubjectTextHeight[element.subjectId] = 0;
      });
    });
  }

  DateTime fromDate() => _fromDate;
  DateTime toDate() => _toDate;
  int dateRange() => _toDate.difference(_fromDate).inDays.abs();

  void _load(DateTime fromDate, DateTime toDate) {}
}
