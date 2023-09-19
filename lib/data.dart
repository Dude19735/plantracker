import 'dart:convert';
import 'package:scheduler/data_utils.dart';

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
  final int fromTime;
  final int toTime;

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

  static String testDateScheduleViewPlan(DateTime startDate) {
    DateTime monday = DataUtils.getLastMonday(startDate);

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
        "${ColumnName.toTime}"],        
      "data": [
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.subjectAcronym}": "Acr-1",
          "${ColumnName.subject}": "Subject-1",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.seriesToDate}: ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.noteId}": 1,
          "${ColumnName.note}": "Note-S1-1",      
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday)},        
          "${ColumnName.fromTime}": ${3 * 60 * 60},
          "${ColumnName.toTime}": ${4.5 * 60 * 60}
        },
          "${ColumnName.subjectId}": 1,
          "${ColumnName.subjectAcronym}": "Acr-1",
          "${ColumnName.subject}": "Subject-1",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.seriesToDate}: ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.noteId}": 2,
          "${ColumnName.note}": "Note-S1-2",      
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 2)))},        
          "${ColumnName.fromTime}": ${4.5 * 60 * 60},
          "${ColumnName.toTime}": ${6 * 60 * 60}
        },
          "${ColumnName.subjectId}": 2,
          "${ColumnName.subjectAcronym}": "Acr-2",
          "${ColumnName.subject}": "Subject-2",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.seriesToDate}: ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.noteId}": 3,
          "${ColumnName.note}": "Note-S2-1",      
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 0)))},        
          "${ColumnName.fromTime}": ${5 * 60 * 60},
          "${ColumnName.toTime}": ${7 * 60 * 60}
        },
          "${ColumnName.subjectId}": 2,
          "${ColumnName.subjectAcronym}": "Acr-2",
          "${ColumnName.subject}": "Subject-2",
          "${ColumnName.workTypeId}": 1,
          "${ColumnName.workType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.seriesToDate}: ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.noteId}": 4,
          "${ColumnName.note}": "Note-S2-2",      
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 4)))},        
          "${ColumnName.fromTime}": ${5 * 60 * 60},
          "${ColumnName.toTime}": ${7 * 60 * 60}
        },
      ]
    }""";
  }

  static String testDataTimeTableView(DateTime startDate) {
    DateTime monday = DataUtils.getLastMonday(startDate);
    return """{
      "header": [
        "${ColumnName.subjectId}", "${ColumnName.date}", "${ColumnName.planed}", "${ColumnName.recorded}", "${ColumnName.subject}"],
      "data": [
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.planed}": 15.0,
          "${ColumnName.recorded}": 17.5,
          "${ColumnName.subject}": "Sub1"
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.planed}": 14.0,
          "${ColumnName.recorded}": 13.9,
          "${ColumnName.subject}": "Sub2"
        },
        {
          "${ColumnName.subjectId}": 3,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday)},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub3"
        },
        {
          "${ColumnName.subjectId}": 4,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 1)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub4"
        },  
        {
          "${ColumnName.subjectId}": 5,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 1)))},
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub5"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 1)))},
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub6"
        },
        {
          "${ColumnName.subjectId}": 1,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 2)))},
          "${ColumnName.planed}": 15.0,
          "${ColumnName.recorded}": 17.5,
          "${ColumnName.subject}": "Sub1"
        },
        {
          "${ColumnName.subjectId}": 2,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 2)))},
          "${ColumnName.planed}": 14.0,
          "${ColumnName.recorded}": 13.9,
          "${ColumnName.subject}": "Sub2"
        },
        {
          "${ColumnName.subjectId}": 3,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 3)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub3"
        },
        {
          "${ColumnName.subjectId}": 4,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 4)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 0.0,
          "${ColumnName.subject}": "Sub4"
        },  
        {
          "${ColumnName.subjectId}": 5,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 5)))},
          "${ColumnName.planed}": 0.0,
          "${ColumnName.recorded}": 12.0,
          "${ColumnName.subject}": "Sub5"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 6)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 6.0,
          "${ColumnName.subject}": "Sub6"
        },
        {
          "${ColumnName.subjectId}": 6,
          "${ColumnName.date}": ${DataUtils.dateTime2Int(monday.add(Duration(days: 7)))},
          "${ColumnName.planed}": 11.0,
          "${ColumnName.recorded}": 6.0,
          "${ColumnName.subject}": "Sub6"
        }
      ]
    }""";
  }

  static String testDataSummaryView() {
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
    } else {
      throw Exception("Message type $D not defined");
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

class GlobalData {
  Map<int, double> minSubjectTextHeight = {};
  late Data<SummaryData> summaryData;
  late Data<TimeTableData> timeTableData;
  late Data<SchedulePlanData> schedulePlanData;

  int date;
  int minusDays;
  int plusDays;

  int _compareDate(int thisDate, int otherDate) {
    if (thisDate < otherDate) {
      return -1;
    } else if (thisDate > otherDate) {
      return 1;
    } else {
      return 0;
    }
  }

  GlobalData(this.date, this.minusDays, this.plusDays) {
    summaryData = Data<SummaryData>.fromJsonStr(Data.testDataSummaryView());
    timeTableData = Data<TimeTableData>.fromJsonStr(
        Data.testDataTimeTableView(DateTime.now()));

    summaryData.data.sort((a, b) => a.subject.compareTo(b.subject));
    timeTableData.data.sort((a, b) => a.subject.compareTo(b.subject));
    timeTableData.data.sort((a, b) => _compareDate(a.date, b.date));

    for (var item in summaryData.data) {
      minSubjectTextHeight[item.subjectId] = 0;
    }
  }
}
