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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},        
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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},
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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},
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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},
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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},
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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},
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
          "${ColumnName.date}": ${DataUtils.dateTime2Int(DataUtils.addDays(fromDate, rand.nextInt(range)))},
          "${ColumnName.fromTime}": ${13.0 * 60 * 60},
          "${ColumnName.toTime}": ${14.8 * 60 * 60}
        }
      ]""";
  }

  static String testDataSubjects(DateTime fromDate, DateTime toDate) {
    String res = "[";
    for (int i = 0; i < DataValues.subjectNames.length; i++) {
      res += """{
          "${ColumnName.subjectId}": $i,
          "${ColumnName.subjectAcronym}": "${DataValues.subjectNames[i]}",
          "${ColumnName.subject}": "${DataValues.subjectNames[i]}",
          "${ColumnName.active}": 1,
          "${ColumnName.activeFromDate}": ${DataUtils.dateTime2Int(fromDate)},
          "${ColumnName.activeToDate}": ${DataUtils.dateTime2Int(toDate)}
        },""";
    }
    res = res.substring(0, res.length - 1);
    res += "]";
    return res;
  }

  static String testDataTimeTableView(DateTime fromDate, DateTime toDate) {
    // int range = DataUtils.getWindowSize(fromDate, toDate);

    List<Map<String, dynamic>> entries = [];
    for (var d = fromDate;
        d.compareTo(toDate) <= 0;
        d = DataUtils.addDays(d, 1)) {
      int subjectId = d.weekday - 1;
      entries.add({
        ColumnName.subjectId: subjectId,
        ColumnName.date: DataUtils.dateTime2Int(d),
        ColumnName.planed: DataValues.planedTime[d.weekday],
        ColumnName.recorded: DataValues.recordedTime[d.weekday],
        ColumnName.subject: DataValues.subjectNames[subjectId]
      });
    }

    Map<int, List<Map<String, dynamic>>> tdata = {};
    for (var elem in entries) {
      int dkey = elem[ColumnName.date];
      if (tdata[dkey] == null) {
        tdata[dkey] = [elem];
      } else {
        tdata[dkey]!.add(elem);
      }
    }

    return DataUtils.mapOfListsToStr(tdata);
  }
}
