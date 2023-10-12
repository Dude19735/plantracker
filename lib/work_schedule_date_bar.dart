import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'dart:math';

class WorkScheduleDateBar extends StatelessWidget {
  final int _pageOffset;

  WorkScheduleDateBar(this._pageOffset);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            margin: EdgeInsets.only(
                left: GlobalStyle.summaryCardMargin,
                right: GlobalStyle.summaryCardMargin),
            child: CustomPaint(painter: _GridPainter(context, _pageOffset)));
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();
  final BuildContext _context;
  final int _pageOffset;

  _GridPainter(this._context, this._pageOffset) {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = 1.0;
    gridPainter.strokeCap = StrokeCap.square;
  }

  void paintDaily(
      Canvas canvas,
      double lead,
      double canvasWidth,
      double canvasHeight,
      double boxWidth,
      TextStyle textStyle,
      DateStyle dateStyle) {
    double xOffset = lead + boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;

    gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
    gridPainter.strokeWidth = 1;
    double end = canvasWidth - boxWidth / 2;
    double delta = boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    while (xOffset < end) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, canvasHeight), gridPainter);
      xOffset += delta;
    }

    gridPainter.strokeWidth = 2;
    gridPainter.color = GlobalStyle.scheduleGridColorFullHour(_context);
    canvas.drawLine(Offset(lead, gridPainter.strokeWidth / 2),
        Offset(canvasWidth, gridPainter.strokeWidth / 2), gridPainter);
    canvas.drawLine(
        Offset(lead, canvasHeight - gridPainter.strokeWidth / 2),
        Offset(canvasWidth, canvasHeight - gridPainter.strokeWidth / 2),
        gridPainter);

    int dayOffset = DataUtils.page2DayOffset(
        _pageOffset, GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const double yCenter = GlobalStyle.scheduleDateBarHeight / 2;
    end = canvasWidth - boxWidth / 4;
    xOffset = lead + (boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2) / 2;
    while (xOffset < end) {
      DateTime day = DataUtils.addDays(GlobalContext.fromDateWindow, dayOffset);
      textPainter.text = TextSpan(
        text: DataUtils.dateTime2Str(day, style: dateStyle),
        style: textStyle,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: boxWidth,
      );
      final offset = Offset(
          xOffset - textPainter.width / 2, yCenter - textPainter.height / 1.75);
      textPainter.paint(canvas, offset);

      xOffset += delta;
      dayOffset++;
    }
  }

  void paintWeekly(
      Canvas canvas,
      double lead,
      double canvasWidth,
      double canvasHeight,
      double boxWidth,
      TextStyle textStyle,
      DateStyle dateStyle) {
    double xOffset =
        lead + 7 * boxWidth + 6.5 * GlobalStyle.scheduleGridStrokeWidth;

    gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
    gridPainter.strokeWidth = 1;
    double end = canvasWidth - GlobalStyle.scheduleGridStrokeWidth;
    double delta = 7 * (boxWidth + GlobalStyle.scheduleGridStrokeWidth);
    while (xOffset < end) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, canvasHeight), gridPainter);
      xOffset += delta;
    }

    gridPainter.strokeWidth = 2;
    gridPainter.color = GlobalStyle.scheduleGridColorFullHour(_context);
    canvas.drawLine(Offset(lead, gridPainter.strokeWidth / 2),
        Offset(canvasWidth, gridPainter.strokeWidth / 2), gridPainter);
    canvas.drawLine(
        Offset(lead, canvasHeight - gridPainter.strokeWidth / 2),
        Offset(canvasWidth, canvasHeight - gridPainter.strokeWidth / 2),
        gridPainter);

    int dayOffset = DataUtils.page2DayOffset(
        _pageOffset, GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const double yCenter = GlobalStyle.scheduleDateBarHeight / 2;
    xOffset = lead;
    xOffset += delta / 2;
    int maxDay = DataUtils.getWindowSize(
        GlobalContext.fromDateWindow, GlobalContext.toDateWindow);
    while (xOffset < end) {
      DateTime fromDay =
          DataUtils.addDays(GlobalContext.fromDateWindow, dayOffset);
      int dOffset = min(dayOffset + 7, maxDay);
      int deltaDay = dOffset - dayOffset;
      DateTime toDay =
          DataUtils.addDays(GlobalContext.fromDateWindow, dOffset - 1);

      WeekStyle weekStyle =
          DataUtils.getWeekStyle(deltaDay * boxWidth, textStyle);

      textPainter.text = TextSpan(
        text: DataUtils.week2Str(fromDay, toDay,
            style: deltaDay == 7 ? weekStyle : WeekStyle.partial),
        style: textStyle,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: deltaDay * boxWidth,
      );
      if (deltaDay == 7) {
        final offset = Offset(xOffset - textPainter.width / 2,
            yCenter - textPainter.height / 1.75);
        textPainter.paint(canvas, offset);
      } else if (deltaDay >= 4) {
        final offset = Offset(
            xOffset - (7 - deltaDay) * boxWidth / 2 - textPainter.width / 2,
            yCenter - textPainter.height / 1.75);
        textPainter.paint(canvas, offset);
      }

      xOffset += delta;
      dayOffset += 7;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );

    double lead = GlobalStyle.scheduleTimeBarWidth;
    double width = size.width;
    int ccsbx = DataUtils.getWindowSize(
        GlobalContext.fromDateWindow, GlobalContext.toDateWindow);
    double boxWidth =
        (width - lead - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;

    var dateStyle = DataUtils.getDateStyle(boxWidth, textStyle);
    if (dateStyle != DateStyle.full) {
      textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14,
      );
      dateStyle = DataUtils.getDateStyle(boxWidth, textStyle);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, width, size.height), backgroundPainter);
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    // =========================================================================

    if (dateStyle != DateStyle.weekly) {
      paintDaily(
          canvas, lead, width, size.height, boxWidth, textStyle, dateStyle);
    } else {
      paintWeekly(
          canvas, lead, width, size.height, boxWidth, textStyle, dateStyle);
    }

    // =========================================================================
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
