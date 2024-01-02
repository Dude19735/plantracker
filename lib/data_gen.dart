import 'dart:math';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/data_columns.dart';
import 'package:scheduler/date.dart';

class DataGen {
  static String testWorkRecord(Date fromDate, Date toDate) {
    Random rand = Random();

    String res = "[";
    int workUnitId = 0;
    for (var d = fromDate; d.compareTo(toDate) <= 0; d = d.addDays(1)) {
      int subjectId = d.weekday() - 1;
      WorkUnitType workUnitType = WorkUnitType.work;
      double finalTime = ((5.5 + subjectId) * 60 * 60);
      double fromTime = ((3.0 + subjectId) * 60 * 60);
      double toTime = fromTime + 30 * 60;
      int index = 0;
      while (fromTime < finalTime) {
        res += """{
            "${ColumnName.workUnitId}": $workUnitId,
            "${ColumnName.subjectId}": ${subjectId == 1 && index > 4 ? subjectId + 1 : subjectId},
            "${ColumnName.workUnitGroupId}": null,
            "${ColumnName.workUnitType}": ${workUnitType.index}, 
            "${ColumnName.date}": ${d.toInt()},
            "${ColumnName.fromTime}": $fromTime,
            "${ColumnName.toTime}": $toTime
          },""";
        index++;
        workUnitId++;
        fromTime = toTime;
        // toTime += (30 * 60);
        if (workUnitType == WorkUnitType.pause) {
          toTime = toTime + (30 + rand.nextInt(10) - 5) * 60;
        } else {
          toTime = toTime + (10 + rand.nextInt(3) - 6) * 60;
        }
        if (workUnitType == WorkUnitType.pause) {
          workUnitType = WorkUnitType.work;
        } else {
          workUnitType = WorkUnitType.pause;
        }
      }
    }

    for (var d = fromDate; d.compareTo(toDate) <= 0; d = d.addDays(1)) {
      int subjectId = d.weekday() - 1;
      WorkUnitType workUnitType = WorkUnitType.work;
      double finalTime = ((8.3 + subjectId) * 60 * 60);
      double fromTime = ((7.0 + subjectId) * 60 * 60);
      double toTime = fromTime + 25 * 60;
      while (fromTime < finalTime) {
        res += """{
            "${ColumnName.workUnitId}": $workUnitId,
            "${ColumnName.subjectId}": $subjectId,
            "${ColumnName.workUnitGroupId}": null,
            "${ColumnName.workUnitType}": ${workUnitType.index},
            "${ColumnName.date}": ${d.toInt()},
            "${ColumnName.fromTime}": $fromTime,
            "${ColumnName.toTime}": $toTime
          },""";
        workUnitId++;
        fromTime = toTime;
        // toTime += (30 * 60);
        if (workUnitType == WorkUnitType.pause) {
          toTime = toTime + (25 + rand.nextInt(10) - 5) * 60;
        } else {
          toTime = toTime + (10 + rand.nextInt(3) - 6) * 60;
        }
        if (workUnitType == WorkUnitType.pause) {
          workUnitType = WorkUnitType.work;
        } else {
          workUnitType = WorkUnitType.pause;
        }
      }
    }

    res = res.substring(0, res.length - 1);
    res += "]";
    return res;
  }

  static String testDateScheduleViewPlan(Date fromDate, Date toDate) {
    int range = fromDate.absWindowSizeWith(toDate);
    Random rand = Random();
    rand.nextInt(range);

    String res = "[";
    for (var d = fromDate; d.compareTo(toDate) <= 0; d = d.addDays(1)) {
      int subjectId = d.weekday() - 1;
      double fromTime = (3.0 + subjectId) * 60 * 60;
      res += """{
          "${ColumnName.subjectId}": $subjectId,
          "${ColumnName.planUnitTypeId}": 1,
          "${ColumnName.planUnitType}": "Free Work",  
          "${ColumnName.seriesId}": -1,    
          "${ColumnName.seriesFromDate}": ${fromDate.toInt()},
          "${ColumnName.seriesToDate}": ${fromDate.toInt()},
          "${ColumnName.noteId}": 1,
          "${ColumnName.note}": "Note-S1-1",      
          "${ColumnName.date}": ${d.toInt()},        
          "${ColumnName.fromTime}": $fromTime,
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
          "${ColumnName.subjectName}": "${DataValues.subjectNames[i]}",
          "${ColumnName.subjectColor}": "${DataValues.subjectColor[i]}",
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
        ColumnName.recordedTime: DataValues.recordedTime[d.weekday()]
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
