import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';

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

  @override
  void paint(Canvas canvas, Size size) {
    double lead = GlobalStyle.scheduleTimeBarWidth;
    double width = size.width;

    int ccsbx = DataUtils.getWindowSize(
        GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    double boxWidth =
        (width - lead - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    canvas.drawRect(Rect.fromLTWH(0, 0, width, size.height), backgroundPainter);

    double xOffset = lead + boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;

    gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
    gridPainter.strokeWidth = 1;
    double end = width - boxWidth / 2;
    double delta = boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    while (xOffset < end) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
      xOffset += delta;
    }

    gridPainter.strokeWidth = 2;
    gridPainter.color = GlobalStyle.scheduleGridColorFullHour(_context);
    canvas.drawLine(Offset(lead, gridPainter.strokeWidth / 2),
        Offset(width, gridPainter.strokeWidth / 2), gridPainter);
    canvas.drawLine(Offset(lead, size.height - gridPainter.strokeWidth / 2),
        Offset(width, size.height - gridPainter.strokeWidth / 2), gridPainter);

    // =========================================================================

    int dayOffset = DataUtils.page2DayOffset(
        _pageOffset, GlobalContext.fromDateWindow, GlobalContext.toDateWindow);

    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    var dateStyle = DataUtils.getDateStyle(boxWidth, textStyle);
    if (dateStyle != DateStyle.full) {
      textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14,
      );
      dateStyle = DataUtils.getDateStyle(boxWidth, textStyle);
    }

    const double yCenter = GlobalStyle.scheduleDateBarHeight / 2;
    xOffset = lead + (boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2) / 2;
    end = width - boxWidth / 4;
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
