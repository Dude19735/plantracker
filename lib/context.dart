import 'package:flutter/material.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/date.dart';
import 'dart:ui';

import 'package:scheduler/time_table_box.dart';

class GlobalContext {
  static String currentLocale = 'en-GB';

  static Date fromDateWindow = Date.lastMonday();
  static Date toDateWindow = fromDateWindow.addDays(GlobalSettings.initDateWindowSize - 1);

  static bool showSubjectsInSummary = true;
  static GlobalData data = GlobalData();

  static Rect scheduleWindowOutlineRect = Rect.fromLTWH(0, 0, 1, 1);
  static Rect scheduleWindowInlineRect = Rect.fromLTWH(0, 0, 1, 1);
  static Rect scheduleWindowCell = Rect.fromLTWH(0, 0, 1, 1);
  static Rect? scheduleWindowSelectionBox;
  static double scheduleWindowScrollOffset = 500.0;

  static double timeTableWindowScrollOffset = 0;
}

class GlobalSettings {
  // timer settings
  static const int initialWorkCountdownInterval = 10;
  static const int initialBreakCountdownInterval = 5;

  static final DateTime earliestDate = DateTime(2022);
  static final DateTime latestDate = DateTime(2100);

  static const int pageViewScrollWaitTimeMS = 500;

  static const Map<String, Locale> locals = {
    "en-GB": Locale('en', 'GB'),
    "de-CH": Locale('de', 'CH'),
    "fr-CH": Locale('fr', 'CH')
  };

  // initial pages
  static const int splitControllerInitPage = 2 << 31;

  // schedule widget configs
  static const int scheduleHourOffset = 5; // start at 5am
  static const int scheduleBoxRangeS = 60 * 15; // 15 mins schedule box size
  static const int initDateWindowSize = 7;
  static const double scheduleWindowAutoScrollOffset = 0;

  // animation timers
  static const int animationFocusScrollTimeTableMS = 250;
  static const int animationScheduleSelectorMS = 125;
}

class GlobalStyle {
  // ===========================================================================
  // App bar settings
  // ===========================================================================
  static const double appBarHeight = 45;
  static const double appBarTabBarTabWidth = 70.0;
  static const double appBarSeparatorWidth = 1;
  static const double shadowOpacity = 0.1;

  static Color appBarShadowColor(BuildContext context) => Theme.of(context)
      .colorScheme
      .shadow
      .withOpacity(GlobalStyle.shadowOpacity);

  // ===========================================================================
  // schedule colors and paint settings
  // ===========================================================================
  static const double scheduleDateSelectorHeight = 40;
  static const double scheduleDateBarHeight = 63;
  static const double scheduleGridStrokeWidth = 1.0;
  static const double scheduleCellHeightPx = 30;
  static const double scheduleTimeBarWidth = 50;

  static Color scheduleGridColorBox(BuildContext context) => Colors.black12;
  static Color scheduleGridColorFullHour(BuildContext context) =>
      Colors.black54;
  static Color scheduleSelectionColor(BuildContext context) =>
      Colors.blueGrey.withAlpha(50);
  static Color scheduleDateSelectorColor(BuildContext context) =>
      Colors.transparent;
  static Color markerBlue(BuildContext context) =>
      Color.fromARGB(255, 48, 110, 176);
  static Color markerRed(BuildContext context) =>
      Color.fromARGB(255, 176, 48, 48);

  // ===========================================================================
  // Time table colors and paint settings
  // ===========================================================================
  static double timeTableSummaryPM() =>
      2 * (GlobalStyle.summaryCardMargin + GlobalStyle.summaryCardPadding);

  static Color timeTableCellShadeColorFull(
      BuildContext context, TimeTableData data) {
    double workRatio = DataUtils.getWorkRatio(data.recorded, data.planed);
    return Color.lerp(Colors.red, Colors.green, workRatio)!;
  }

  static Color timeTableCellBarColor(BuildContext context, double ratio) {
    return Color.lerp(Colors.brown, Colors.yellowAccent, ratio)!;
  }

  static Color timeTableFullCellBorderColor(BuildContext context) {
    return Colors.black45;
  }

  static Color timeTableSelectedCellBorderColor(BuildContext context) {
    return Colors.black45;
  }

  static Color timeTableEmptyCellBorderColor(BuildContext context) {
    return Colors.black12;
  }

  static Color timeTableActiveCellBackground(BuildContext context) =>
      Colors.white;

  static Color timeTableCellShadeColorEmpty(
          BuildContext context, TimeTableCellState state) =>
      state == TimeTableCellState.inactive
          ? Colors.transparent
          : Colors.black12;

  static Color timeTableCellColor(
          BuildContext context, TimeTableCellState state) =>
      state == TimeTableCellState.inactive
          ? Colors.transparent
          : Colors.black12;

  // ===========================================================================
  // splitter and grabber settings
  // ===========================================================================
  static const double splitterHInitRatio = 0.25;
  static const double splitterHGrabberSize = 10;
  static const double splitterVInitRatio = 0.75;
  static const double splitterVGrabberSize = 10;

  static Color splitterVGrabberColor(BuildContext context) =>
      Colors.transparent;
  static Color splitterHGrabberColor(BuildContext context) =>
      Colors.transparent;

  // distance between edge of group of containers and surroundings
  // static const double splitterCellMargin = 8.0;
  // distance between edge of group of containers and individual containers
  // static const double splitterCellPadding = 0.0; //8.0;

  // ===========================================================================
  // summary and time table card settings
  // ===========================================================================
  // distance between edge of individual container and surroundings
  static const double summaryCardMargin = 3.0; //5.0;
  // distance between edge of individual container and card contents
  static const double summaryCardPadding = 2.0; //5.0;
  static const double summaryCardBorderRadius = 5.0;
  static const double summaryEntryBarHeight = 20;

  static TextStyle summaryTextStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400);

  static Color globalCardColor(BuildContext context) => Colors.black12;
  static Color summaryPlanedTimeBarColor(BuildContext context) =>
      Colors.black38;

  static Color summaryRecordedTimeBarColor(
      BuildContext context, SummaryData data) {
    double workRatio = DataUtils.getWorkRatio(data.recorded, data.planed);
    return Color.lerp(Colors.red, Colors.green, workRatio)!;
  }

  // ===========================================================================
  // clock bar settings
  // ===========================================================================
  static const double clockBarVerticalSpacerHeight = 24.0;
  static const double clockBarPadding = 16;
  static const double clockBarWidth = 120;
  static const double clockBarBoxRadius = 5.0;
  static const double clockBarSubjectSelectorHeight = 45;
  static const double clockBarToTabViewSpacer = 16;

  static Color clockBarTogglerButtonOutline(context) => Colors.black;

  // Datepicker box
  static const double DateButtonRadius = 5.0;

  static Widget createShadowContainer(BuildContext context, Widget? child,
      {margin = const EdgeInsets.all(0.0),
      padding = const EdgeInsets.all(0.0),
      borderRadius = GlobalStyle.summaryCardBorderRadius,
      width,
      height,
      color = Colors.transparent,
      borderColor = Colors.transparent,
      shadowColor,
      bool shadow = true,
      bool border = false}) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        border: border
            ? Border.all(color: borderColor)
            : Border(
                left: BorderSide.none,
                right: BorderSide.none,
                top: BorderSide.none,
                bottom: BorderSide.none),
        borderRadius:
            BorderRadius.circular(borderRadius), //border corner radius
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: shadowColor ??
                      GlobalStyle.appBarShadowColor(context), //color of shadow
                  spreadRadius: 3, //spread radius
                  blurRadius: 4, // blur radius
                  offset: Offset(0, 0), // changes position of shadow
                  //first paramerter of offset is left-right
                  //second parameter is top to down
                ),
                //you can set more BoxShadow() here
              ]
            : [],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  // static int dateToInt(Date date) {
  //   int res = date.year * 10000 + date.month * 100 + date.day;
  //   return res;
  // }
}

class Helpers {
  static void showAlertDialog(BuildContext context, String errorMsg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text(errorMsg),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class Debugger {
  static const bool _dataDebug = false;
  static const bool _mainDebug = false;
  static const bool _timeTableDebug = false;
  static const bool _timeTableBoxDebug = false;
  static const bool _workScheduleDebug = false;
  static const bool _workScheduleInnerViewDebug = false;
  static const bool _workScheduleDateBarDebug = false;
  static const bool _splitControllerDebug = false;

  static void data(String msg) {
    if (_dataDebug) {
      print("DataDebug");
      print(msg);
    }
  }

  static void main(String msg) {
    if (_mainDebug) {
      print("MainDebug");
      print(msg);
    }
  }

  static void timeTable(String msg) {
    if (_timeTableDebug) {
      print("TimeTableDebug");
      print(msg);
    }
  }

  static void timeTableBox(String msg) {
    if (_timeTableBoxDebug) {
      print("TimeTableBoxDebug");
      print(msg);
    }
  }

  static void workSchedule(String msg) {
    if (_workScheduleDebug) {
      print("WorkScheduleDebug");
      print(msg);
    }
  }

  static void workScheduleInnerView(String msg) {
    if (_workScheduleInnerViewDebug) {
      print("WorkScheduleInnerViewDebug");
      print(msg);
    }
  }

  static void workScheduleDateBar(String msg) {
    if (_workScheduleDateBarDebug) {
      print("WorkScheduleDateBarDebug");
      print(msg);
    }
  }

  static void splitController(String msg) {
    if (_splitControllerDebug) {
      print("SplitControllerDebug");
      print(msg);
    }
  }
}
