import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

enum SplitDirection { vertical, horizontal }

class SyncNotification extends Notification {}

class PanNotification extends SyncNotification {
  late final String name;
  late final DragUpdateDetails details;
  late final BoxConstraints constraints;
  PanNotification(this.name, this.details, this.constraints);
}

class StartNotification extends SyncNotification {
  late final String name;
  late final TapDownDetails details;
  late final BoxConstraints constraints;
  StartNotification(this.name, this.details, this.constraints);
}

class Ratio {
  double ratio;
  double grabSize;
  Ratio(this.ratio, this.grabSize);
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

  final GlobalContext _globalContext;

  CrossSplit(this._globalContext,
      {this.horizontalInitRatio = GlobalStyle.horizontalInitRatio,
      this.horizontalGrabberSize = GlobalStyle.horizontalGrabberSize,
      this.verticalInitRatio = GlobalStyle.verticalInitRatio,
      this.verticalGrabberSize = GlobalStyle.verticalGrabberSize,
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
        double x1 = vRatio.ratio *
            (notification.constraints.maxWidth - vRatio.grabSize);
        double x2 = vRatio.ratio *
                (notification.constraints.maxWidth - vRatio.grabSize) +
            vRatio.grabSize;
        double px = notification.details.globalPosition.dx;

        if (notification.name.startsWith("h") && x1 <= px && px <= x2) {
          _tabbedCenter = true;
        } else {
          _tabbedCenter = false;
        }
      }

      // we moved the thing => clear the width lists
      for (var item in widget._globalContext.data.summaryData.data) {
        widget._globalContext.data.minSubjectTextHeight[item.subjectId] = 0;
      }
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
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
            widget._globalContext,
            "hAll",
            hRatio,
            SplitDirection.horizontal,
            color: GlobalStyle.grabberColor,
            topOrLeft: Row(children: [
              Split(
                widget._globalContext,
                "vTop",
                vRatio,
                SplitDirection.vertical,
                color: GlobalStyle.grabberColor,
                topOrLeft: widget.topLeft,
                bottomOrRight: widget.topRight,
              )
            ]),
            bottomOrRight: Row(children: [
              Split(widget._globalContext, "vBottom", vRatio,
                  SplitDirection.vertical,
                  color: GlobalStyle.grabberColor,
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
  late final Ratio _ratio;

  late final Widget topOrLeft;
  late final Widget bottomOrRight;

  final GlobalContext _globalContext;

  Split(this._globalContext, this._name, this._ratio, this._direction,
      {this.color = GlobalStyle.grabberColor,
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
          for (var item in _globalContext.data.summaryData.data) {
            double width = sizes["sb1_w"]! as double;
            double oldHeight =
                _globalContext.data.minSubjectTextHeight[item.subjectId]!;
            double height =
                GlobalContext.getTextHeight(item.subject, context, width);
            _globalContext.data.minSubjectTextHeight[item.subjectId] =
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
                  child: topOrLeft,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.allScroll,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: _direction == SplitDirection.horizontal
                            ? _ratio.grabSize
                            : constraints.maxHeight,
                        width: _direction == SplitDirection.horizontal
                            ? constraints.maxWidth
                            : _ratio.grabSize,
                        color: color,
                      ),
                      onPanUpdate: (DragUpdateDetails details) {
                        PanNotification(_name, details, constraints)
                            .dispatch(context);
                      },
                      onTapDown: (TapDownDetails details) {
                        StartNotification(_name, details, constraints)
                            .dispatch(context);
                      }),
                ),
                SizedBox(
                    width: sizes["sb2_w"],
                    height: sizes["sb2_h"],
                    child: bottomOrRight)
              ],
            ));
      }),
    );
  }
}
