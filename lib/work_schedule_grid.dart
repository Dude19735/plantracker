import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/date.dart';

class WorkScheduleGrid extends StatelessWidget {
  final double _maxWidth;
  final Date _fromDate;
  final Date _toDate;

  WorkScheduleGrid(this._maxWidth, this._fromDate, this._toDate);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
      width: _maxWidth -
          GlobalStyle.scheduleTimeBarWidth -
          2 * GlobalStyle.summaryCardMargin,
      height: GlobalContext.scheduleWindowInlineRect.height,
      child: CustomPaint(painter: _GridPainter(context, _fromDate, _toDate)),
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();
  Paint rectPainter = Paint();
  final Date _fromDate;
  final Date _toDate;
  BuildContext _context;

  _GridPainter(this._context, this._fromDate, this._toDate) {
    backgroundPainter.color = GlobalStyle.scheduleBackgroundColor(_context);
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = GlobalStyle.scheduleGridStrokeWidth;
    gridPainter.strokeCap = StrokeCap.round;

    // rectPainter.style = PaintingStyle.fill;
    // rectPainter.strokeWidth = 1;
    // rectPainter.color = GlobalStyle.scheduleSelectionColor(_context);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print("paint canvas");
    int ccsbx = _fromDate.absWindowSizeWith(_toDate);

    double boxWidth =
        (size.width - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    double xOffset = boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;
    gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
    while (xOffset < size.width - boxWidth / 2) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
      xOffset += boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    }

    double yOffset = GlobalStyle.scheduleCellHeightPx +
        GlobalStyle.scheduleGridStrokeWidth / 2;
    int counter = 1;
    while (yOffset < size.height - GlobalStyle.scheduleGridStrokeWidth) {
      if (counter % 4 == 0) {
        gridPainter.color = GlobalStyle.scheduleGridColorFullHour(_context);
      } else {
        gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
      }
      canvas.drawLine(
          Offset(0, yOffset), Offset(size.width, yOffset), gridPainter);
      counter++;
      yOffset += GlobalStyle.scheduleGridStrokeWidth +
          GlobalStyle.scheduleCellHeightPx;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class SelectorPainter extends StatelessWidget {
  final double _maxWidth;
  final Date _fromDate;
  final Date _toDate;

  SelectorPainter(this._maxWidth, this._fromDate, this._toDate);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
      width: _maxWidth -
          GlobalStyle.scheduleTimeBarWidth -
          2 * GlobalStyle.summaryCardMargin,
      height: GlobalContext.scheduleWindowInlineRect.height,
      child: CustomPaint(painter: _GridPainter(context, _fromDate, _toDate)),
    );
  }
}
