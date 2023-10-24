import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';
import 'package:scheduler/date.dart';
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
      Date day = GlobalContext.fromDateWindow.addDays(dayOffset);
      // print("${GlobalContext.fromDateWindow} $day $dayOffset $_pageOffset");
      textPainter.text = TextSpan(
        text: Date.Date2Str(day, style: dateStyle),
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

  int _d(dateStyle) {
    switch (dateStyle) {
      case DateStyle.weekly:
        return 7;
      case DateStyle.weekly2:
        return 14;
      default:
        return 1;
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
    int wDelta = _d(dateStyle);
    double xOffset = lead +
        wDelta * boxWidth +
        (wDelta - 0.5) * GlobalStyle.scheduleGridStrokeWidth;

    gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
    gridPainter.strokeWidth = 1;
    double end = canvasWidth - GlobalStyle.scheduleGridStrokeWidth;
    double delta = wDelta * (boxWidth + GlobalStyle.scheduleGridStrokeWidth);
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
    int maxDay = GlobalContext.fromDateWindow.absWindowSizeWith(GlobalContext.toDateWindow);
    while (xOffset < end) {
      Date fromDay = GlobalContext.fromDateWindow.addDays(dayOffset);
      int dOffset = min(dayOffset + wDelta, maxDay);
      int deltaDay = dOffset - dayOffset;
      Date toDay = GlobalContext.fromDateWindow.addDays(dOffset - 1);

      WeekStyle weekStyle =
          Date.getWeekStyle(deltaDay * boxWidth, textStyle);

      textPainter.text = TextSpan(
        text: Date.week2Str(fromDay, toDay,
            style: deltaDay == wDelta ? weekStyle : WeekStyle.partial),
        style: textStyle,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: deltaDay * boxWidth,
      );
      if (deltaDay == wDelta) {
        final offset = Offset(xOffset - textPainter.width / 2,
            yCenter - textPainter.height / 1.75);
        textPainter.paint(canvas, offset);
      } else if (deltaDay >= 4) {
        final offset = Offset(
            xOffset -
                (wDelta - deltaDay) * boxWidth / 2 -
                textPainter.width / 2,
            yCenter - textPainter.height / 1.75);
        textPainter.paint(canvas, offset);
      }

      xOffset += delta;
      dayOffset += wDelta;
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
    int ccsbx = GlobalContext.fromDateWindow.absWindowSizeWith(GlobalContext.toDateWindow);
    double boxWidth =
        (width - lead - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;

    var dateStyle = Date.getDateStyle(boxWidth, textStyle);
    if (dateStyle != DateStyle.full) {
      textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14,
      );
      dateStyle = Date.getDateStyle(boxWidth, textStyle);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, width, size.height), backgroundPainter);
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    // =========================================================================

    if (ccsbx > 8 * 7) dateStyle = DateStyle.weekly2;
    if (dateStyle != DateStyle.weekly && dateStyle != DateStyle.weekly2) {
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
