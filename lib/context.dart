import 'package:flutter/material.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_utils.dart';

class CurrentConfig {
  static String currentLocale = 'en-GB';

  // schedule widget configs
  static int scheduleHourOffset = 5; // start at 5am
  static int scheduleBoxRangeS = 60 * 15; // 15 mins schedule box size
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
}

class GlobalStyle {
  // layout settings
  static const double appBarHeight = 45;
  static const double clockBarWidth = 120;
  static const double subjectSelectorHeight = 45;
  static const double horizontalGrayLineHeight = 3;
  static const double summaryEntryBarHeight = 20;
  static const double tabBarTabWidth = 70.0;

  // schedule colors and paint settings
  static const Color scheduleGridColorBox = Colors.black12;
  static const Color scheduleGridColorFullHour = Colors.black54;
  static const double scheduleGridStrokeWidth = 1.0;
  static int scheduleBoxHeightPx = 30; // height of a schedule box in pixel

  // marker colors
  static const Color markerBlue = Color.fromARGB(255, 48, 110, 176);
  static const Color markerRed = Color.fromARGB(255, 176, 48, 48);

  // grabber
  static const double horizontalInitRatio = 0.25;
  static const double horizontalGrabberSize = 10;
  static const double verticalInitRatio = 0.75;
  static const double verticalGrabberSize = 10;
  static const Color grabberColor = Colors.green;

  // summary and time table card settings
  static const double cardMargin = 5.0; //5.0;
  static const double cardPadding = 5.0; //5.0;

  // background cards padding and color
  static const double globalCardMargin = 3.0;
  static const double globalCardPadding = 8.0; //8.0;
  static const Color globalCardColor = Colors.black12;
  static const double globalBorderRadius = 0.0;

  // Datepicker box
  static const double dateTimeButtonRadius = 5.0;

  static Widget createShadowContainer(BuildContext context, Widget? child,
      {margin = GlobalStyle.cardMargin,
      borderRadius = GlobalStyle.globalBorderRadius,
      width,
      height,
      color = Colors.white}) {
    return Container(
        width: width,
        height: height,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: color,
          border: Border(
              left: BorderSide.none,
              right: BorderSide.none,
              top: BorderSide.none,
              bottom: BorderSide.none),
          borderRadius:
              BorderRadius.circular(borderRadius), //border corner radius
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .shadow
                  .withOpacity(0.1), //color of shadow
              spreadRadius: 3, //spread radius
              blurRadius: 4, // blur radius
              offset: Offset(0, 0), // changes position of shadow
              //first paramerter of offset is left-right
              //second parameter is top to down
            ),
            //you can set more BoxShadow() here
          ],
        ),
        child: child);
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

class GlobalContext {
  bool showSubjectsInSummary = true;
  GlobalData data = GlobalData(DataUtils.getLastMonday(DateTime.now()),
      DataUtils.getNextSunday(DateTime.now()));
}
