import 'dart:convert';
import 'package:flutter/material.dart';

class ColumnName {
  static const String date = "Date";
  static const String planed = "Planed";
  static const String recorded = "Recorded";
  static const String subject = "Subject";
  static const String subjectId = "SubjectId";
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

  static String testDataTimeTableView() {
    return """{
      "header": [
        "Subject", "Date", "Planed", "Recorded"],
      "data": [
        {
          "SubjectId": 1,
          "Date": 20230818,
          "Planed": 15.0,
          "Recorded": 17.5,
          "Subject": "Sub1"
        },
        {
          "SubjectId": 2,
          "Date": 20230818,
          "Planed": 14.0,
          "Recorded": 13.9,
          "Subject": "Sub2"
        },
        {
          "SubjectId": 3,
          "Date": 20230818,
          "Planed": 11.0,
          "Recorded": 12.0,
          "Subject": "Sub3"
        },
        {
          "SubjectId": 4,
          "Date": 20230818,
          "Planed": 11.0,
          "Recorded": 0.0,
          "Subject": "Sub4"
        },  
        {
          "SubjectId": 5,
          "Date": 20230818,
          "Planed": 0.0,
          "Recorded": 12.0,
          "Subject": "Sub5"
        },
        {
          "SubjectId": 6,
          "Date": 20230818,
          "Planed": 0.0,
          "Recorded": 0.0,
          "Subject": "Sub6"
        },
        {
          "SubjectId": 1,
          "Date": 20230819,
          "Planed": 15.0,
          "Recorded": 17.5,
          "Subject": "Sub1"
        },
        {
          "SubjectId": 2,
          "Date": 20230820,
          "Planed": 14.0,
          "Recorded": 13.9,
          "Subject": "Sub2"
        },
        {
          "SubjectId": 3,
          "Date": 20230819,
          "Planed": 11.0,
          "Recorded": 12.0,
          "Subject": "Sub3"
        },
        {
          "SubjectId": 4,
          "Date": 20230814,
          "Planed": 11.0,
          "Recorded": 0.0,
          "Subject": "Sub4"
        },  
        {
          "SubjectId": 5,
          "Date": 20230816,
          "Planed": 0.0,
          "Recorded": 12.0,
          "Subject": "Sub5"
        },
        {
          "SubjectId": 6,
          "Date": 20230815,
          "Planed": 11.0,
          "Recorded": 6.0,
          "Subject": "Sub6"
        }
      ]
    }""";
  }

  static String testDataSummaryView() {
    return """{
      "header": [
        "Subject", "Planed", "Recorded"],
      "data": [
        {
          "SubjectId": 1,
          "Planed": 15.0,
          "Recorded": 17.5,
          "Subject": "jslkjopivmlkaoiesoairejlökmvaoijseoijasoeihoivnkcoieklllöksamoivoie"
        },
        {
          "SubjectId": 2,
          "Planed": 14.0,
          "Recorded": 13.9,
          "Subject": "Sub2"
        },
        {
          "SubjectId": 3,
          "Planed": 11.0,
          "Recorded": 12.0,
          "Subject": "Sub3"
        },
        {
          "SubjectId": 4,
          "Planed": 11.0,
          "Recorded": 0.0,
          "Subject": "Sub4"
        },  
        {
          "SubjectId": 5,
          "Planed": 0.0,
          "Recorded": 12.0,
          "Subject": "Sub5"
        },
        {
          "SubjectId": 6,
          "Planed": 0.0,
          "Recorded": 0.0,
          "Subject": "Sub6"
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

  GlobalData(int date, int plusDays) {
    summaryData = Data<SummaryData>.fromJsonStr(Data.testDataSummaryView());
    timeTableData =
        Data<TimeTableData>.fromJsonStr(Data.testDataTimeTableView());

    for (var item in summaryData.data) {
      minSubjectTextHeight[item.subjectId] = 0;
    }
  }
}
