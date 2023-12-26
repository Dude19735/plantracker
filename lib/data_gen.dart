import 'dart:math';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/data_columns.dart';
import 'package:scheduler/date.dart';

class DataGen {
  static String testWorkRecord(Date fromDate, Date toDate) {
    return "";
  }

  static String testDateScheduleViewPlan(Date fromDate, Date toDate) {
    int range = fromDate.absWindowSizeWith(toDate);
    Random rand = Random();
    rand.nextInt(range);

    String res = "[";
    for (var d = fromDate; d.compareTo(toDate) <= 0; d = d.addDays(1)) {
      int subjectId = d.weekday() - 1;
      res += """{
          "${ColumnName.subjectId}": $subjectId,
          "${ColumnName.subjectAcronym}": "${DataValues.subjectAcronym[subjectId]}",
          "${ColumnName.subject}": "${DataValues.subjectNames[subjectId]}",
          "${ColumnName.planUnitTypeId}": 1,
          "${ColumnName.planUnitType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${fromDate.toInt()},
          "${ColumnName.seriesToDate}": ${fromDate.toInt()},
          "${ColumnName.noteId}": 1,
          "${ColumnName.note}": "Note-S1-1",      
          "${ColumnName.date}": ${d.toInt()},        
          "${ColumnName.fromTime}": ${(3.0 + subjectId) * 60 * 60},
          "${ColumnName.toTime}": ${(4.5 + subjectId) * 60 * 60}
        },""";
    }
    res = res.substring(0, res.length - 1);
    res += "]";
    return res;
  }

  static String testDataSubjects(Date fromDate, Date toDate) {
    String res = "[";
    for (int i = 0; i < DataValues.subjectNames.length; i++) {
      res += """{
          "${ColumnName.subjectId}": $i,
          "${ColumnName.subjectAcronym}": "${DataValues.subjectNames[i]}",
          "${ColumnName.subject}": "${DataValues.subjectNames[i]}",
          "${ColumnName.active}": 1,
          "${ColumnName.activeFromDate}": ${fromDate.toInt()},
          "${ColumnName.activeToDate}": ${toDate.toInt()}
        },""";
    }
    res = res.substring(0, res.length - 1);
    res += "]";
    return res;
  }

  static String testDataTimeTableView(Date fromDate, Date toDate) {
    // int range = DataUtils.getWindowSize(fromDate, toDate);

    List<Map<String, dynamic>> entries = [];
    for (var d = fromDate; d.compareTo(toDate) <= 0; d = d.addDays(1)) {
      int subjectId = d.weekday() - 1;
      entries.add({
        ColumnName.subjectId: subjectId,
        ColumnName.date: d.toInt(),
        ColumnName.planedTime: DataValues.planedTime[d.weekday()],
        ColumnName.recordedTime: DataValues.recordedTime[d.weekday()],
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
