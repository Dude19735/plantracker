import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data_utils.dart';

class WorkScheduleTimeBar extends StatelessWidget {
  WorkScheduleTimeBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: GlobalContext.scheduleWindowInlineRect.height,
        width: GlobalStyle.scheduleTimeBarWidth,
        child: CustomPaint(painter: _GridPainter(context)));
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();
  final BuildContext _context;

  _GridPainter(this._context) {
    backgroundPainter.color = GlobalStyle.scheduleBackgroundColor(_context);
    ;
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = 1.0;
    gridPainter.strokeCap = StrokeCap.square;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // double boxWidth = GlobalStyle.scheduleTimeBarWidth;

    canvas.drawRect(
        Rect.fromLTWH(
            0, 0, size.width, GlobalContext.scheduleWindowInlineRect.height),
        backgroundPainter);

    // double xOffset = boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;

    // gridPainter.color = GlobalStyle.scheduleGridColorBox(_context);
    // gridPainter.strokeWidth = 1;
    // double end = size.width - boxWidth / 2;
    // double delta = boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    // while (xOffset < end) {
    //   canvas.drawLine(
    //       Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
    //   xOffset += delta;
    // }

    // double yOffset = 0.0;
    // gridPainter.strokeWidth = 2;
    // gridPainter.color = GlobalStyle.scheduleGridColorFullHour(_context);
    // canvas.drawLine(Offset(0, gridPainter.strokeWidth / 2),
    //     Offset(size.width, gridPainter.strokeWidth / 2), gridPainter);
    // canvas.drawLine(
    //     Offset(0, size.height - gridPainter.strokeWidth / 2),
    //     Offset(size.width, size.height - gridPainter.strokeWidth / 2),
    //     gridPainter);

    // =========================================================================

    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // const double yCenter = GlobalStyle.scheduleDateBarHeight / 2.25;
    double cellHeight = GlobalContext.scheduleWindowInlineRect.height / 24;
    double end = GlobalContext.scheduleWindowInlineRect.height;
    double yOffset = 0;

    int t = GlobalSettings.scheduleHourOffset;
    while (yOffset < end) {
      textPainter.text = TextSpan(
        text: t.toString().padLeft(2, "0"),
        style: textStyle,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: GlobalStyle.scheduleTimeBarWidth,
      );
      final offset = Offset(size.width / 2, yOffset + 10);
      textPainter.paint(canvas, offset);

      yOffset += cellHeight;
      t++;
      t %= 24;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
