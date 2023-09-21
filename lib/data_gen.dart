import 'dart:math';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/data_columns.dart';

class DataGen {
  static String testDateScheduleViewPlan(DateTime fromDate, DateTime toDate) {
    int range = fromDate.difference(toDate).inDays.abs() + 1;
    Random rand = Random();
    rand.nextInt(range);

    return """[
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
      ]""";
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

    return """[
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
      ]""";
  }

  static String testDataSummaryView(DateTime fromDate, DateTime toDate) {
    return """[
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
      ]""";
  }
}
