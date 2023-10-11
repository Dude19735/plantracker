import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';

enum SplitDirection { vertical, horizontal }

enum CrossSplitComponent {
  none,
  top,
  bottom,
  tl,
  tr,
  bl,
  br,
  vSeparatorTop,
  vSeparatorBottom,
  hSeparator
}

typedef TSetComponentState
    = Map<CrossSplitComponent, void Function(void Function()?)?>;

class SyncNotification extends Notification {}

class PanNotification extends SyncNotification {
  final SplitDirection direction;
  final DragUpdateDetails details;
  final BoxConstraints constraints;
  PanNotification(this.direction, this.details, this.constraints);
}

class StartNotification extends SyncNotification {
  final bool center;
  StartNotification(this.center);
}

class SplitMetrics {
  final double tlWidth;
  final double tlHeight;
  final double brWidth;
  final double brHeight;
  SplitMetrics(
      {this.tlWidth = 0,
      this.tlHeight = 0,
      this.brWidth = 0,
      this.brHeight = 0});

  @override
  String toString() {
    return "\ntop/left\t[w,h]:\t[$tlWidth,$tlHeight]\nbottom/right\t[w,h]:\t[$brWidth,$brHeight]";
  }
}

class Ratio {
  double hRatio;
  double vRatio;
  double vGrabSize;
  double hGrabSize;
  Ratio(this.vRatio, this.hRatio, this.vGrabSize, this.hGrabSize);
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

  final Widget Function(SplitMetrics metrics)? topLeft;
  final Widget Function(SplitMetrics metrics)? bottomLeft;
  final Widget Function(SplitMetrics metrics)? topRight;
  final Widget Function(SplitMetrics metrics)? bottomRight;

  static const String hAll = "hAll";
  static const String vTop = "vTop";
  static const String vBottom = "vBottom";

  CrossSplit(
      {this.horizontalInitRatio = GlobalStyle.splitterHInitRatio,
      this.horizontalGrabberSize = GlobalStyle.splitterHGrabberSize,
      this.verticalInitRatio = GlobalStyle.splitterVInitRatio,
      this.verticalGrabberSize = GlobalStyle.splitterVGrabberSize,
      this.topLeft,
      this.topRight,
      this.bottomLeft,
      this.bottomRight});

  @override
  State<CrossSplit> createState() => _CrossSplit();
}

class _CrossSplit extends State<CrossSplit> {
  late final Split hTop;
  late final Split hBottom;
  late final Ratio ratio;
  late final DragCursor cursor;
  bool _tabbedCenter = false;

  void _vSync(PanNotification notification) {
    ratio.vRatio += notification.details.delta.dx /
        (notification.constraints.maxWidth - ratio.vGrabSize);
    if (ratio.vRatio < 0) {
      ratio.vRatio = 0.0;
    } else if (ratio.vRatio > 1.0) {
      ratio.vRatio = 1.0;
    }
  }

  void _hSync(PanNotification notification) {
    ratio.hRatio += notification.details.delta.dy /
        (notification.constraints.maxHeight - ratio.hGrabSize);
    if (ratio.hRatio < 0) {
      ratio.hRatio = 0.0;
    } else if (ratio.hRatio > 1.0) {
      ratio.hRatio = 1.0;
    }
  }

  bool onSync(SyncNotification notification) {
    if (notification is StartNotification) {
      _tabbedCenter = notification.center;
    }
    if (notification is PanNotification) {
      setState(() {
        if (_tabbedCenter) {
          _vSync(notification);
          _hSync(notification);
        } else if (notification.direction == SplitDirection.vertical) {
          _vSync(notification);
        } else {
          _hSync(notification);
        }
      });
    }

    // we moved the thing => clear the width lists
    for (var item in GlobalContext.data.summaryData.data) {
      GlobalContext.data.minSubjectTextHeight[item.subjectId] = 0;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    ratio = Ratio(widget.horizontalInitRatio, widget.verticalInitRatio,
        widget.verticalGrabberSize, widget.horizontalGrabberSize);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SyncNotification>(
      onNotification: onSync,
      child: Column(
        children: [
          Split(
            CrossSplit.hAll,
            ratio, //hRatio,
            SplitDirection.horizontal,
            color: GlobalStyle.splitterHGrabberColor(context),
            topOrLeft: (SplitMetrics metrics) => SplitContainer(
                metrics,
                CrossSplitComponent.top,
                (SplitMetrics metrics) => Row(children: [
                      Split(
                        CrossSplit.vTop,
                        ratio, //vRatio,
                        SplitDirection.vertical,
                        color: GlobalStyle.splitterVGrabberColor(context),
                        topOrLeft: (SplitMetrics metrics) => SplitContainer(
                            metrics, CrossSplitComponent.tl, widget.topLeft),
                        bottomOrRight: (SplitMetrics metrics) => SplitContainer(
                            metrics, CrossSplitComponent.tr, widget.topRight),
                      )
                    ])),
            bottomOrRight: (SplitMetrics metrics) => SplitContainer(
                metrics,
                CrossSplitComponent.bottom,
                (SplitMetrics metrics) => Row(children: [
                      Split(CrossSplit.vBottom, ratio,
                          /*vRatio,*/ SplitDirection.vertical,
                          color: GlobalStyle.splitterVGrabberColor(context),
                          topOrLeft: (SplitMetrics metrics) => SplitContainer(
                              metrics,
                              CrossSplitComponent.bl,
                              widget.bottomLeft),
                          bottomOrRight: (SplitMetrics metrics) =>
                              SplitContainer(metrics, CrossSplitComponent.br,
                                  widget.bottomRight))
                    ])),
          ),
        ],
      ),
    );
  }
}

class SplitContainer extends StatefulWidget {
  final Widget Function(SplitMetrics metrics)? child;
  final CrossSplitComponent _place;
  final SplitMetrics _metrics;
  static final TSetComponentState _setState = {
    CrossSplitComponent.top: null,
    CrossSplitComponent.bottom: null,
    CrossSplitComponent.tl: null,
    CrossSplitComponent.tr: null,
    CrossSplitComponent.bl: null,
    CrossSplitComponent.br: null
  };

  SplitContainer(this._metrics, this._place, this.child);

  static bool setComponentState(
      CrossSplitComponent component, void Function()? stateUpdate) {
    if (_setState[component] != null) {
      _setState[component]!(stateUpdate);
      return true;
    }
    return false;
  }

  @override
  State<SplitContainer> createState() => _SplitContainer();
}

class _SplitContainer extends State<SplitContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SplitContainer._setState[widget._place] = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget._place != CrossSplitComponent.none) {
      SplitContainer._setState[widget._place] = (void Function()? stateUpdate) {
        setState(() {
          if (stateUpdate != null) {
            stateUpdate();
          }
        });
      };
    }

    return widget.child != null
        ? widget.child!(widget._metrics)
        : Placeholder();
  }
}

class Split extends StatefulWidget {
  final SplitDirection _direction;
  final String _name;
  final Color color;
  late final Ratio _ratio;

  late final Widget Function(SplitMetrics metrics)? topOrLeft;
  late final Widget Function(SplitMetrics metrics)? bottomOrRight;

  Split(this._name, this._ratio, this._direction,
      {this.color = Colors.transparent, this.topOrLeft, this.bottomOrRight});

  @override
  State<Split> createState() => _Split();
}

class _Split extends State<Split> {
  DragCursor _cursor = DragCursor(SystemMouseCursors.allScroll);
  bool _center = false;
  CrossSplitComponent _crossSplitComponent = CrossSplitComponent.none;

  Map getSizes(BoxConstraints constraints) {
    double ratio = widget._name.startsWith("v")
        ? widget._ratio.vRatio
        : widget._ratio.hRatio;
    double grabSize = widget._name.startsWith("v")
        ? widget._ratio.vGrabSize
        : widget._ratio.hGrabSize;
    return {
      "sb1_w": widget._direction == SplitDirection.vertical
          ? (constraints.maxWidth - grabSize) * ratio
          : null,
      "sb1_h": widget._direction == SplitDirection.horizontal
          ? (constraints.maxHeight - grabSize) * ratio
          : null,
      "sb2_w": widget._direction == SplitDirection.vertical
          ? (constraints.maxWidth - grabSize) * (1 - ratio)
          : null,
      "sb2_h": widget._direction == SplitDirection.horizontal
          ? (constraints.maxHeight - grabSize) * (1 - ratio)
          : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    _crossSplitComponent = widget._direction == SplitDirection.horizontal
        ? CrossSplitComponent.hSeparator
        : (widget._name.compareTo(CrossSplit.vTop) == 0
            ? CrossSplitComponent.vSeparatorTop
            : CrossSplitComponent.vSeparatorBottom);
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        var sizes = getSizes(constraints);

        var metrics = SplitMetrics(
          tlWidth: sizes["sb1_w"] ?? 0,
          tlHeight: sizes["sb1_h"] ?? 0,
          brWidth: sizes["sb2_w"] ?? 0,
          brHeight: sizes["sb2_h"] ?? 0,
        );

        return SizedBox(
          height: constraints.maxHeight,
          child: Flex(
            direction: widget._direction == SplitDirection.horizontal
                ? Axis.vertical
                : Axis.horizontal,
            children: [
              SizedBox(
                width: sizes["sb1_w"],
                height: sizes["sb1_h"],
                child: ClipRect(
                    child: widget.topOrLeft == null
                        ? null
                        : widget.topOrLeft!(metrics)),
              ),
              SplitContainer(
                  SplitMetrics(),
                  _crossSplitComponent,
                  (SplitMetrics metrics) => MouseRegion(
                        cursor: _cursor.cursor,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                                color: widget.color,
                                child: widget._direction ==
                                        SplitDirection.horizontal
                                    ? RotatedBox(
                                        quarterTurns: 1,
                                        child: VerticalDivider(
                                          width: widget._ratio.vGrabSize,
                                          thickness: 2,
                                          indent: GlobalStyle.summaryCardMargin,
                                          endIndent:
                                              GlobalStyle.summaryCardMargin,
                                        ),
                                      )
                                    : VerticalDivider(
                                        width: widget._ratio.hGrabSize,
                                        thickness: 4,
                                        indent: GlobalStyle.summaryCardMargin,
                                        endIndent:
                                            GlobalStyle.summaryCardMargin,
                                      )),
                            onPanUpdate: (DragUpdateDetails details) {
                              PanNotification(
                                      widget._direction, details, constraints)
                                  .dispatch(context);
                            },
                            onTapDown: (TapDownDetails details) {
                              StartNotification(_center).dispatch(context);
                            }),
                        onHover: (event) {
                          SplitContainer.setComponentState(_crossSplitComponent,
                              () {
                            if (widget._direction ==
                                SplitDirection.horizontal) {
                              double x1 =
                                  widget._ratio.vRatio * constraints.maxWidth -
                                      widget._ratio.vGrabSize / 2;
                              double x2 =
                                  widget._ratio.vRatio * constraints.maxWidth +
                                      widget._ratio.vGrabSize / 2;

                              double px = event.localPosition.dx;

                              _center = x1 <= px && px <= x2;
                            } else {
                              _center = false;
                            }

                            if (_center) {
                              _cursor.cursor = SystemMouseCursors.move;
                            } else if (widget._direction ==
                                SplitDirection.vertical) {
                              _cursor.cursor = SystemMouseCursors.resizeColumn;
                            } else if (widget._direction ==
                                SplitDirection.horizontal) {
                              _cursor.cursor = SystemMouseCursors.resizeRow;
                            }
                          });
                        },
                        onExit: (event) {
                          SplitContainer.setComponentState(_crossSplitComponent,
                              () {
                            _cursor.cursor = SystemMouseCursors.basic;
                          });
                        },
                      )),
              SizedBox(
                  width: sizes["sb2_w"],
                  height: sizes["sb2_h"],
                  child: ClipRect(
                      child: widget.bottomOrRight == null
                          ? null
                          : widget.bottomOrRight!(metrics)))
            ],
          ),
        );
      }),
    );
  }
}
