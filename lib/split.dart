import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

enum SplitDirection { vertical, horizontal }

class SyncNotification extends Notification {}

class HoverNotification extends SyncNotification {
  final String name;
  final PointerHoverEvent details;
  final BoxConstraints constraints;
  HoverNotification(this.name, this.details, this.constraints);
}

class PanNotification extends SyncNotification {
  final String name;
  final DragUpdateDetails details;
  final BoxConstraints constraints;
  PanNotification(this.name, this.details, this.constraints);
}

class StartNotification extends SyncNotification {
  final String name;
  final TapDownDetails details;
  final BoxConstraints constraints;
  StartNotification(this.name, this.details, this.constraints);
}

class Ratio {
  double ratio;
  double grabSize;
  Ratio(this.ratio, this.grabSize);
}

class DragCursor {
  MouseCursor cursor;
  DragCursor(this.cursor);
}

class CrossSplit extends StatefulWidget {
  final double verticalInitRatio;
  final double verticalGrabberSize;
  final double horizontalInitRatio;
  final double horizontalGrabberSize;

  final Widget topLeft;
  final Widget bottomLeft;
  final Widget topRight;
  final Widget bottomRight;

  CrossSplit(
      {this.horizontalInitRatio = GlobalStyle.splitterHInitRatio,
      this.horizontalGrabberSize = GlobalStyle.splitterHGrabberSize,
      this.verticalInitRatio = GlobalStyle.splitterVInitRatio,
      this.verticalGrabberSize = GlobalStyle.splitterVGrabberSize,
      this.topLeft = const Placeholder(),
      this.topRight = const Placeholder(),
      this.bottomLeft = const Placeholder(),
      this.bottomRight = const Placeholder()});

  @override
  State<CrossSplit> createState() => _CrossSplit();
}

class _CrossSplit extends State<CrossSplit> {
  // late Split h;
  late final Split hTop;
  late final Split hBottom;

  late final Ratio vRatio;
  late final Ratio hRatio;

  late final DragCursor cursor;

  bool _tabbedCenter = false;

  void _vSync(PanNotification notification) {
    vRatio.ratio += notification.details.delta.dx /
        (notification.constraints.maxWidth - vRatio.grabSize);
    if (vRatio.ratio < 0) {
      vRatio.ratio = 0.0;
    } else if (vRatio.ratio > 1.0) {
      vRatio.ratio = 1.0;
    }
  }

  void _hSync(PanNotification notification) {
    hRatio.ratio += notification.details.delta.dy /
        (notification.constraints.maxHeight - hRatio.grabSize);
    if (hRatio.ratio < 0) {
      hRatio.ratio = 0.0;
    } else if (hRatio.ratio > 1.0) {
      hRatio.ratio = 1.0;
    }
  }

  static bool _mouseInCenter(
      Ratio vRatio, double width, double dx, String name) {
    double x1 = vRatio.ratio * (width - vRatio.grabSize);
    double x2 = vRatio.ratio * (width - vRatio.grabSize) + vRatio.grabSize;

    // add the clockBarWidth because it's inside the same parent
    double px = dx - GlobalStyle.clockBarWidth;

    bool center = name.startsWith("h") && x1 <= px && px <= x2;

    return center;
  }

  bool onSync(SyncNotification notification) {
    setState(() {
      if (notification is PanNotification) {
        if (_tabbedCenter) {
          _vSync(notification);
          _hSync(notification);
        } else if (notification.name.startsWith("v")) {
          _vSync(notification);
        } else {
          _hSync(notification);
        }
      } else if (notification is StartNotification) {
        if (_CrossSplit._mouseInCenter(
            vRatio,
            notification.constraints.maxWidth,
            notification.details.globalPosition.dx,
            notification.name)) {
          _tabbedCenter = true;
        } else {
          _tabbedCenter = false;
        }
      } else if (notification is HoverNotification) {
        if (_CrossSplit._mouseInCenter(
            vRatio,
            notification.constraints.maxWidth,
            notification.details.position.dx,
            notification.name)) {
          cursor.cursor = SystemMouseCursors.move;
        } else if (notification.name.startsWith("v")) {
          cursor.cursor = SystemMouseCursors.resizeColumn;
        } else if (notification.name.startsWith("h")) {
          cursor.cursor = SystemMouseCursors.resizeRow;
        }
      }

      // we moved the thing => clear the width lists
      for (var item in GlobalContext.data.summaryData.data) {
        GlobalContext.data.minSubjectTextHeight[item.subjectId] = 0;
      }
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    cursor = DragCursor(SystemMouseCursors.allScroll);
    vRatio = Ratio(widget.horizontalInitRatio, widget.verticalGrabberSize);
    hRatio = Ratio(widget.verticalInitRatio, widget.horizontalGrabberSize);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SyncNotification>(
      onNotification: onSync,
      child: Column(
        children: [
          Split(
            "hAll",
            hRatio,
            SplitDirection.horizontal,
            cursor,
            color: GlobalStyle.splitterHGrabberColor,
            topOrLeft: Row(children: [
              Split(
                "vTop",
                vRatio,
                SplitDirection.vertical, cursor,
                //this,
                color: GlobalStyle.splitterVGrabberColor,
                topOrLeft: widget.topLeft,
                bottomOrRight: widget.topRight,
              )
            ]),
            bottomOrRight: Row(children: [
              Split("vBottom", vRatio, SplitDirection.vertical, cursor,
                  color: GlobalStyle.splitterVGrabberColor,
                  topOrLeft: widget.bottomLeft,
                  bottomOrRight: widget.bottomRight)
            ]),
          ),
        ],
      ),
    );
  }
}

class Split extends StatelessWidget {
  final SplitDirection _direction;
  final String _name;
  final Color color;
  final DragCursor _cursor;
  late final Ratio _ratio;

  late final Widget topOrLeft;
  late final Widget bottomOrRight;

  Split(
      this._name,
      this._ratio,
      this._direction,
      // this._parent,
      this._cursor,
      {this.color = GlobalStyle.splitterVGrabberColor,
      this.topOrLeft = const Placeholder(),
      this.bottomOrRight = const Placeholder()});

  Map getSizes(BoxConstraints constraints) {
    return {
      "sb1_w": _direction == SplitDirection.vertical
          ? (constraints.maxWidth - _ratio.grabSize) * _ratio.ratio
          : null,
      "sb1_h": _direction == SplitDirection.horizontal
          ? (constraints.maxHeight - _ratio.grabSize) * _ratio.ratio
          : null,
      "sb2_w": _direction == SplitDirection.vertical
          ? (constraints.maxWidth - _ratio.grabSize) * (1 - _ratio.ratio)
          : null,
      "sb2_h": _direction == SplitDirection.horizontal
          ? (constraints.maxHeight - _ratio.grabSize) * (1 - _ratio.ratio)
          : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        var sizes = getSizes(constraints);

        if (sizes["sb1_w"] != null) {
          for (var item in GlobalContext.data.summaryData.data) {
            double width = (sizes["sb1_w"]! as double) -
                // 2 * GlobalStyle.summaryCardPadding -
                // 2 * GlobalStyle.cardMargin -
                2 * GlobalStyle.splitterCellMargin;
            double oldHeight =
                GlobalContext.data.minSubjectTextHeight[item.subjectId]!;
            double height =
                GlobalStyle.getTextHeight(item.subject, context, width);
            GlobalContext.data.minSubjectTextHeight[item.subjectId] =
                max(oldHeight, height);
          }
        }

        return SizedBox(
          height: constraints.maxHeight,
          child: Flex(
            direction: _direction == SplitDirection.horizontal
                ? Axis.vertical
                : Axis.horizontal,
            children: [
              SizedBox(
                width: sizes["sb1_w"],
                height: sizes["sb1_h"],
                child: ClipRect(child: topOrLeft),
              ),
              MouseRegion(
                cursor: _cursor.cursor,
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                        // height: _direction == SplitDirection.horizontal
                        //     ? _ratio.grabSize
                        //     : constraints.maxHeight,
                        // width: _direction == SplitDirection.horizontal
                        //     ? constraints.maxWidth
                        //     : _ratio.grabSize,
                        color: color,
                        child: _direction == SplitDirection.horizontal
                            ? RotatedBox(
                                quarterTurns: 1,
                                child: VerticalDivider(
                                  width: _ratio.grabSize,
                                  thickness: 2,
                                  indent: GlobalStyle.summaryCardMargin,
                                  endIndent: GlobalStyle.summaryCardMargin,
                                ),
                              )
                            : VerticalDivider(
                                width: _ratio.grabSize,
                                thickness: 4,
                                indent: GlobalStyle.summaryCardMargin,
                                endIndent: GlobalStyle.summaryCardMargin,
                              )),
                    onPanUpdate: (DragUpdateDetails details) {
                      PanNotification(_name, details, constraints)
                          .dispatch(context);
                    },
                    onTapDown: (TapDownDetails details) {
                      StartNotification(_name, details, constraints)
                          .dispatch(context);
                    }),
                onHover: (PointerHoverEvent details) {
                  HoverNotification(_name, details, constraints)
                      .dispatch(context);
                },
              ),
              SizedBox(
                  width: sizes["sb2_w"],
                  height: sizes["sb2_h"],
                  child: ClipRect(child: bottomOrRight))
            ],
          ),
        );
      }),
    );
  }
}
