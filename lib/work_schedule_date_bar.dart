import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/work_schedule_date_bar.dart';

class WorkScheduleDateBar extends StatelessWidget {
  //State<WorkScheduleInnerView> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return

            // SingleChildScrollView(
            //     padding: EdgeInsets.all(0.0),
            //     controller: ScrollController(),
            //     child: GlobalStyle.createShadowContainer(
            //         context, CustomPaint(painter: _GridPainter()),
            //         width: constraints.maxWidth,
            //         height: GlobalStyle.scheduleDateBarHeight,
            //         shadow: true,
            //         margin: EdgeInsets.only(
            //             top: GlobalStyle.summaryCardMargin,
            //             left: GlobalStyle.summaryCardMargin,
            //             right: GlobalStyle.summaryCardMargin)));

            Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                margin: EdgeInsets.only(
                    left: GlobalStyle.summaryCardMargin,
                    right: GlobalStyle.summaryCardMargin),
                child: CustomPaint(painter: _GridPainter()));
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  Paint backgroundPainter = Paint();
  Paint gridPainter = Paint();

  _GridPainter() {
    backgroundPainter.color = Colors.white;
    backgroundPainter.style = PaintingStyle.fill;

    gridPainter.style = PaintingStyle.stroke;
    gridPainter.strokeWidth = 1.0;
    gridPainter.strokeCap = StrokeCap.square;
    gridPainter.color = GlobalStyle.scheduleGridColorBox;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int ccsbx = GlobalContext.fromDateWindow
            .difference(GlobalContext.toDateWindow)
            .inDays
            .abs() +
        1;

    double boxWidth =
        (size.width - GlobalStyle.scheduleGridStrokeWidth * (ccsbx - 1)) /
            ccsbx;
    GlobalContext.scheduleWindowCell =
        Rect.fromLTWH(0, 0, boxWidth, GlobalStyle.scheduleCellHeightPx);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPainter);

    double xOffset = boxWidth + GlobalStyle.scheduleGridStrokeWidth / 2;

    gridPainter.color = GlobalStyle.scheduleGridColorBox;
    gridPainter.strokeWidth = 1;
    while (xOffset < size.width - boxWidth / 2) {
      canvas.drawLine(
          Offset(xOffset, 0), Offset(xOffset, size.height), gridPainter);
      xOffset += boxWidth + GlobalStyle.scheduleGridStrokeWidth;
    }

    gridPainter.strokeWidth = 2;
    gridPainter.color = GlobalStyle.scheduleGridColorFullHour;
    canvas.drawLine(Offset(0, gridPainter.strokeWidth / 2),
        Offset(size.width, gridPainter.strokeWidth / 2), gridPainter);
    canvas.drawLine(
        Offset(0, size.height - gridPainter.strokeWidth / 2),
        Offset(size.width, size.height - gridPainter.strokeWidth / 2),
        gridPainter);

    // =========================================================================

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );
    final textSpan = TextSpan(
      text: 'Hello, world.',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: GlobalContext.scheduleWindowCell.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
