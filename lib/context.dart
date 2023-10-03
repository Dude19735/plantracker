import 'package:flutter/material.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';

class GlobalContext {
  static String currentLocale = 'en-GB';

  static DateTime fromDateWindow = DataUtils.getLastMonday(DateTime.now());
  static DateTime toDateWindow =
      fromDateWindow.add(Duration(days: GlobalSettings.initDateWindowSize - 1));

  static bool showSubjectsInSummary = true;
  static GlobalData data = GlobalData();

  static Rect scheduleWindowOutlineRect = Rect.fromLTWH(0, 0, 1, 1);
  static Rect scheduleWindowInlineRect = Rect.fromLTWH(0, 0, 1, 1);
  static Rect scheduleWindowCell = Rect.fromLTWH(0, 0, 1, 1);
  static Rect? scheduleWindowSelectionBox;
  static double scheduleWindowScrollOffset = 500.0;
}

class GlobalSettings {
  // timer settings
  static const int initialWorkCountdownInterval = 10;
  static const int initialBreakCountdownInterval = 5;

  static final DateTime earliestDate = DateTime(2022);
  static final DateTime latestDate = DateTime(2100);

  static const Map<String, Locale> locals = {
    "en-GB": Locale('en', 'GB'),
    "de-CH": Locale('de', 'CH'),
    "fr-CH": Locale('fr', 'CH')
  };

  // schedule widget configs
  static const int scheduleHourOffset = 5; // start at 5am
  static const int scheduleBoxRangeS = 60 * 15; // 15 mins schedule box size
  static const int initDateWindowSize = 7;
  static const int pageChangeDurationMS = 250;
  static const double scheduleWindowAutoScrollOffset = 0;
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
  static Color timeTableCellShadeColorFull(BuildContext context) =>
      Colors.green;
  static Color timeTableCellShadeColorEmpty(BuildContext context) =>
      Colors.transparent;
  static Color timeTableCellColor(BuildContext context) => Colors.transparent;

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
  static const double splitterCellMargin = 8.0;
  // distance between edge of group of containers and individual containers
  // static const double splitterCellPadding = 0.0; //8.0;

  // ===========================================================================
  // summary and time table card settings
  // ===========================================================================
  // distance between edge of individual container and surroundings
  static const double summaryCardMargin = 6.0; //5.0;
  // distance between edge of individual container and card contents
  static const double summaryCardPadding = 5.0; //5.0;
  static const double summaryCardBorderRadius = 5.0;
  static const double summaryEntryBarHeight = 20;

  static Color globalCardColor(BuildContext context) => Colors.black12;

  // ===========================================================================
  // clock bar settings
  // ===========================================================================
  static const double clockBarSpacingDistance = 8.0;
  static const double clockBarPadding = 15;
  static const double clockBarWidth = 120;
  static const double clockBarBoxRadius = 5.0;
  static const double subj$ectSelectorHeight = 45;

  // Datepicker box
  static const double dateTimeButtonRadius = 5.0;

  static Widget createShadowContainer(BuildContext context, Widget? child,
      {margin = const EdgeInsets.all(0.0),
      padding = const EdgeInsets.all(0.0),
      borderRadius = GlobalStyle.summaryCardBorderRadius,
      width,
      height,
      color = Colors.transparent,
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
            ? Border.all(color: GlobalStyle.scheduleGridColorBox(context))
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

  static int dateToInt(DateTime date) {
    int res = date.year * 10000 + date.month * 100 + date.day;
    return res;
  }

  static double getTextHeight(
      String text, BuildContext context, double maxWidth) {
    var style = DefaultTextStyle.of(context).style;
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: maxWidth);
    final numLines = tp.computeLineMetrics().length;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    )..layout();

    // print("$numLines, ${numLines * textPainter.height}: $text");
    return numLines * textPainter.height;
  }
}
