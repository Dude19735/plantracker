import 'dart:convert';

class ColumnName {
  static const String planed = "Planed";
  static const String recorded = "Recorded";
  static const String subject = "Subject";
}

class SummaryData {
  final double planed;
  final double recorded;
  final String subject;

  SummaryData(Map<String, dynamic> data)
      : subject = data[ColumnName.subject],
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

  static String testDataSummaryView() {
    return """{
      "header": [
        "Subject", "Planed", "Recorded"],
      "data": [
        {
          "Planed": 15.0,
          "Recorded": 17.5,
          "Subject": "Sub1"
        },
        {
          "Planed": 14.0,
          "Recorded": 13.9,
          "Subject": "Sub2"
        },
        {
          "Planed": 11.0,
          "Recorded": 12.0,
          "Subject": "Sub3"
        },
        {
          "Planed": 11.0,
          "Recorded": 0.0,
          "Subject": "Sub4"
        },  
        {
          "Planed": 0.0,
          "Recorded": 12.0,
          "Subject": "Sub5"
        },
        {
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
