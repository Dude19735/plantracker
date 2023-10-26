import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/date.dart';
import 'package:flutter/gestures.dart';

class SelectionNotification extends Notification {
  final double x;
  final double y;
  final double width;
  final double height;
  final double secondsFrom;
  final double secondsTo;
  final int date;
  SelectionNotification(this.x, this.y, this.width, this.height,
      this.secondsFrom, this.secondsTo, this.date);
}

class WorkScheduleSelectionOverlay extends StatefulWidget {
  final ScrollController _scrollController;
  final double _startx;
  final double _starty;
  WorkScheduleSelectionOverlay(
      this._scrollController, this._startx, this._starty);

  @override
  State<WorkScheduleSelectionOverlay> createState() =>
      _WorkScheduleSelectionOverlay();
}

// class _SelectedBox {
//   final double x;
//   final double y;
//   final double width;
//   final double height;
//   final double secondsFrom;
//   final double secondsTo;
//   final int date;
//   _SelectedBox(this.x, this.y, this.width, this.height, this.secondsFrom,
//       this.secondsTo, this.date);

//   @override
//   String toString() {
//     return "\nx: $x\ny: $y\nwidth: $width\nheight: $height\nsecondsFrom: $secondsFrom\nsecondsTo: $secondsTo\ndate: $date\n";
//   }
// }

class _WorkScheduleSelectionOverlay extends State<WorkScheduleSelectionOverlay>
    with SingleTickerProviderStateMixin {
  final double _topFrame = 0;
  final double _sideFrame = 0;

  late Animation<double> _animation;
  late AnimationController _controller;
  late double _curXPos;
  late double _curYPos;
  bool _animBackwards = false;
  bool _verticalDragging = false;

  _WorkScheduleSelectionOverlay();

  @override
  void initState() {
    super.initState();
    _curXPos = -1;
    _curYPos = -1;
    _controller = AnimationController(
        duration:
            Duration(milliseconds: GlobalSettings.animationScheduleSelectorMS),
        vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          if (GlobalContext.scheduleWindowSelectionBox != null) {
            double top = GlobalContext.scheduleWindowSelectionBox!.top;
            GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
                _curXPos,
                top,
                GlobalContext.scheduleWindowCell.width,
                _curYPos -
                    top +
                    _animation.value * GlobalStyle.scheduleCellHeightPx +
                    (_animBackwards ? GlobalStyle.scheduleCellHeightPx : 0));
          }

          if (_controller.status == AnimationStatus.completed) {}
        });
      });

    double xpos = _roundToVFrame(widget._startx);
    double ypos = _roundToHFrame(widget._starty);
    _initSelection(xpos, ypos);
  }

  // @override
  // void addListener(VoidCallback listener) {}

  double _roundToVFrame(double xval) {
    double xpos = (xval - _sideFrame - GlobalStyle.scheduleTimeBarWidth) -
        (xval - _sideFrame - GlobalStyle.scheduleTimeBarWidth) %
            (GlobalContext.scheduleWindowCell.width +
                GlobalStyle.scheduleGridStrokeWidth);

    return xpos;
  }

  double _roundToHFrame(double yval) {
    double yvalOffset = yval - _topFrame - GlobalStyle.scheduleDateBarHeight;
    double ypos = yvalOffset -
        yvalOffset %
            (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth);

    return ypos;
  }

  bool _clampConditions(double xMousePos, double yMousePos) {
    return !GlobalContext.scheduleWindowInlineRect
        .contains(Offset(xMousePos, yMousePos));
  }

  void _autoScroll(double dy) {
    if (!_verticalDragging) return;

    double height = GlobalContext.scheduleWindowOutlineRect.height;
    if (dy > height + GlobalSettings.scheduleWindowAutoScrollOffset) {
      widget._scrollController.jumpTo(widget._scrollController.offset + 5);

      // this is more of an emergency solution than something usefull!
      // if (!_scrollController.position.atEdge) {
      //   Future<void>.delayed(Duration(milliseconds: 100))
      //       .then((value) => _autoScroll(dy + 5));
      // }
    } else if (dy < GlobalSettings.scheduleWindowAutoScrollOffset) {
      widget._scrollController.jumpTo(widget._scrollController.offset - 5);
    }
  }

  bool _resetSelection(double dy) {
    if (_resetConditions(dy)) {
      return true;
    }
    return false;
  }

  void _reset() {
    _controller.reset();
    GlobalContext.scheduleWindowSelectionBox = null;
    _curYPos = -1;
    _curXPos = -1;
    _animBackwards = false;
  }

  // WorkScheduleEntry? _getEntry() {
  //   if (GlobalContext.scheduleWindowSelectionBox == null) return null;
  //   if (GlobalContext.scheduleWindowSelectionBox!.height < 0) return null;

  //   var t = _getSelectedTime();
  //   // print(t.toString());
  //   // print(t["secondsFrom"]! / 60);
  //   return WorkScheduleEntry(t.x, t.y, t.width, t.height, null);
  // }

  bool _resetConditions(double dy) {
    bool reset = dy < 0 &&
        (GlobalContext.scheduleWindowSelectionBox == null ||
            GlobalContext.scheduleWindowSelectionBox!.height <
                GlobalStyle.scheduleCellHeightPx);

    return reset;
  }

  void _dispatchSelectedTime(BuildContext context) {
    double x = GlobalContext.scheduleWindowSelectionBox!.left;
    double y = GlobalContext.scheduleWindowSelectionBox!.top;
    double width = GlobalContext.scheduleWindowSelectionBox!.width;
    double height = GlobalContext.scheduleWindowSelectionBox!.height;

    double secondsFrom = y /
        (GlobalStyle.scheduleCellHeightPx +
            GlobalStyle.scheduleGridStrokeWidth) *
        GlobalSettings.scheduleBoxRangeS;

    double ch =
        GlobalStyle.scheduleCellHeightPx + GlobalStyle.scheduleGridStrokeWidth;
    double rHeight =
        ch * (height / ch).ceil() - GlobalStyle.scheduleGridStrokeWidth;

    double secondsTo = secondsFrom +
        (rHeight + GlobalStyle.scheduleGridStrokeWidth) /
            (GlobalStyle.scheduleCellHeightPx +
                GlobalStyle.scheduleGridStrokeWidth) *
            GlobalSettings.scheduleBoxRangeS;

    int yearOffset =
        (x / (width + GlobalStyle.scheduleGridStrokeWidth)).round();
    Date year = GlobalContext.fromDateWindow.addDays(yearOffset);

    SelectionNotification(
            x + GlobalStyle.summaryCardMargin,
            y + GlobalStyle.summaryCardMargin,
            width,
            rHeight,
            secondsFrom,
            secondsTo,
            year.toInt())
        .dispatch(context);

    // return _SelectedBox(
    //     x + GlobalStyle.summaryCardMargin,
    //     y + GlobalStyle.summaryCardMargin,
    //     width,
    //     rHeight,
    //     secondsFrom,
    //     secondsTo,
    //     year.toInt());
  }

  void _initSelection(double xpos, double ypos) {
    if (_curYPos != ypos) {
      _curYPos = ypos;
      _curXPos = xpos; //xMousePos;
      GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
          _curXPos,
          ypos,
          GlobalContext.scheduleWindowCell.width,
          GlobalStyle.scheduleCellHeightPx);

      _animBackwards = false;
      // _controller.reset();
      // _controller.forward();
    }
  }

  void _continueSelection(double xpos, double ypos, double dy) {
    if (_curYPos != ypos) {
      _curYPos = ypos;
      _curXPos = xpos; //xMousePos;
      GlobalContext.scheduleWindowSelectionBox = Rect.fromLTWH(
          _curXPos,
          GlobalContext.scheduleWindowSelectionBox!.top,
          GlobalContext.scheduleWindowCell.width,
          _curYPos +
              GlobalStyle.scheduleCellHeightPx -
              GlobalContext.scheduleWindowSelectionBox!.top);

      _animBackwards = dy < 0; // details.delta.dy < 0;
      _controller.reset();
      _animBackwards ? _controller.reverse(from: 1) : _controller.forward();
    } else if (_curXPos != xpos) {
      GlobalContext.scheduleWindowSelectionBox = GlobalContext
          .scheduleWindowSelectionBox!
          .translate(xpos - _curXPos, 0);
      _curXPos = xpos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        _CustomGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_CustomGestureRecognizer>(
                () => _CustomGestureRecognizer(),
                (_CustomGestureRecognizer instance) {})
        // VerticalDragGestureRecognizer:
        //     GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
        //         () => VerticalDragGestureRecognizer(),
        //         (VerticalDragGestureRecognizer instance) {
        //   instance.dragStartBehavior = DragStartBehavior.start;
        //   instance
        //     ..onUpdate = (details) {
        //       print("update");
        //     }
        //     ..onEnd = (details) {
        //       print("end");
        //     };
        // })
      },
      // TapGestureRecognizer:
      //     GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      //   () => TapGestureRecognizer(),
      //   (TapGestureRecognizer instance) {
      //     instance
      //       ..onTapDown = (TapDownDetails details) {
      //         setState(() {
      //           print("down");
      //         });
      //       }
      //       ..onTapUp = (TapUpDetails details) {
      //         setState(() {
      //           print("up");
      //         });
      //       }
      //       ..onTap = () {
      //         setState(() {
      //           print("tap");
      //         });
      //       }
      //       ..onTapCancel = () {
      //         setState(() {
      //           print("cancel");
      //         });
      //       };
      //   },
      // ),
      // },
      child: Container(
          color: Colors.red.withAlpha(127),
          width: GlobalContext.scheduleWindowInlineRect.width - 100,
          height: GlobalContext.scheduleWindowInlineRect.height,
          child: CustomPaint(painter: _SelectedBoxPainter(context))),
    );
    // var lol = Navigator.of(context).addListener();
    // return GestureDetector(
    //   onVerticalDragDown: (details) {
    //     print("vertical drag start");
    //   },
    //   onVerticalDragUpdate: (details) {
    //     double localDy = details.localPosition.dy;
    //     double localDx = details.localPosition.dx;
    //     double ddy = details.delta.dy;
    //     setState(() {
    //       _verticalDragging = true;
    //       _autoScroll(localDy);

    //       if (_resetSelection(ddy)) return;

    //       double yMousePos = localDy; // + widget._scrollController.offset;
    //       // print(yMousePos);
    //       double xMousePos = _roundToVFrame(localDx);

    //       if (_clampConditions(xMousePos, yMousePos)) return;

    //       double ypos = _roundToHFrame(yMousePos);
    //       // if (GlobalContext.scheduleWindowSelectionBox == null) {
    //       //   _initSelection(xMousePos, ypos);
    //       // } else {
    //       _continueSelection(xMousePos, ypos, ddy);
    //       // }
    //     });
    //   },
    //   onVerticalDragEnd: (details) {
    //     setState(() {
    //       _verticalDragging = false;
    //       // emit notification here...
    //       // _currentEntry = _getEntry();
    //       // if (entry != null) _entries.add(entry);
    //       _dispatchSelectedTime(context);
    //       _reset();
    //     });
    //   },
    //   child: Container(
    //       color: Colors.red.withAlpha(127),
    //       width: GlobalContext.scheduleWindowInlineRect.width - 100,
    //       height: GlobalContext.scheduleWindowInlineRect.height,
    //       child: CustomPaint(painter: _SelectedBoxPainter(context))),
    // );

    // LayoutBuilder(
    //   builder: (BuildContext context, BoxConstraints constraints) {
    // get from outside => no need
    // double numBoxes = 24 * (3600 / GlobalSettings.scheduleBoxRangeS);

    // already there, just use it
    // GlobalContext.scheduleWindowOutlineRect =
    //     Rect.fromLTRB(0, 0, constraints.maxWidth, constraints.maxHeight);

    // already there, just use it
    // GlobalContext.scheduleWindowInlineRect = Rect.fromLTWH(
    //     0,
    //     GlobalStyle.scheduleDateBarHeight,
    //     constraints.maxWidth,
    //     GlobalStyle.scheduleCellHeightPx * numBoxes +
    //         //(numBoxes - 1) * GlobalStyle.scheduleGridStrokeWidth +
    //         GlobalStyle.scheduleDateBarHeight);

    // get this one from the parent...
    // _scrollController = ScrollController(
    //     initialScrollOffset: GlobalContext.scheduleWindowScrollOffset,
    // keepScrollOffset: true);

    // produce one of these...
    // var innerView = Stack(children: [
    //   Container(
    //     margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
    //     width: constraints.maxWidth -
    //         GlobalStyle.scheduleTimeBarWidth -
    //         2 * GlobalStyle.summaryCardMargin,
    //     height: GlobalContext.scheduleWindowInlineRect.height,
    //     child: CustomPaint(painter: _GridPainter(context)),
    //   ),
    //   if (_currentEntry != null) _currentEntry!,
    //   for (var e in _getEntries(constraints)) e
    // ]);
/*
        var view = GestureDetector(
            onVerticalDragUpdate: (details) {
              print("drag update");
              double localDy = details.localPosition.dy;
              double localDx = details.localPosition.dx;
              double ddy = details.delta.dy;
              setState(() {
                _verticalDragging = true;
                _autoScroll(localDy);

                if (_resetSelection(ddy)) return;

                double yMousePos = localDy + widget._scrollController.offset;
                double xMousePos = _roundToVFrame(localDx);

                if (_clampConditions(xMousePos, yMousePos)) return;

                double ypos = _roundToHFrame(yMousePos);
                if (GlobalContext.scheduleWindowSelectionBox == null) {
                  _initSelection(xMousePos, ypos);
                } else {
                  _continueSelection(xMousePos, ypos, ddy);
                }
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
                _verticalDragging = false;
                // emit notification here...
                // _currentEntry = _getEntry();
                // if (entry != null) _entries.add(entry);
                _reset();
              });
            },
            child: Container(color: Colors.amber.withAlpha(127), width: constraints.minWidth, height: constraints.minHeight,)
            // CustomScrollView(controller: _scrollController, slivers: [
            //   SliverAppBar(
            //     pinned: true,
            //     elevation: 0,
            //     backgroundColor: Colors.transparent,
            //     surfaceTintColor: Colors.transparent,
            //     foregroundColor: Colors.transparent,
            //     shadowColor: Colors.black,
            //     // leadingWidth: GlobalStyle.scheduleTimeBarWidth +
            //     //     GlobalStyle.summaryCardMargin,
            //     // leading: Container(
            //     //     height: GlobalStyle.scheduleDateBarHeight,
            //     //     color: Colors.red),
            //     flexibleSpace: WorkScheduleDateBar(widget._pageDaysOffset),
            //   ),
            //   SliverList(
            //     delegate: SliverChildBuilderDelegate(
            //       (BuildContext context, int index) {
            //         return Row(
            //           children: [
            //             WorkScheduleTimeBar(),
            //             innerView,
            //           ],
            //         );
            //       },
            //       childCount: 1,
            //     ),
            //   )
            // ])
            );

        return view;
        // return NotificationListener(
        //     onNotification: (notification) {
        //       if (notification is ScrollNotification) {
        //         GlobalContext.scheduleWindowScrollOffset =
        //             notification.metrics.pixels;
        //         return true; // cut event propagation
        //       }
        //       return false;
        //     },
        //     child: view);
      }
    );
    */
  }
}
// }

class _CustomGestureRecognizer extends VerticalDragGestureRecognizer {
  // @override
  // void acceptGesture(int pointer) {
  //   print("accepted pointer");
  // }

  // @override
  // String get debugDescription => throw UnimplementedError();

  // @override
  // void rejectGesture(int pointer) {
  //   print("reject gesture");
  // }

  // @override
  // void addAllowedPointer(PointerDownEvent event) {
  //   print("add allowed pointer");
  // }

  // @override
  // void addAllowedPointer(PointerDownEvent event) {
  //   super.addAllowedPointer(event);
  //   if (_state == _DragState.ready) {
  //     _initialButtons = event.buttons;
  //   }
  //   _addPointer(event);
  // }
}

class _SelectedBoxPainter extends CustomPainter {
  Paint rectPainter = Paint();
  Paint backgroundPainter = Paint();
  BuildContext _context;

  _SelectedBoxPainter(this._context) {
    backgroundPainter.color = Colors.blue.withAlpha(80);
    backgroundPainter.style = PaintingStyle.fill;

    rectPainter.style = PaintingStyle.fill;
    rectPainter.strokeWidth = 1;
    rectPainter.color =
        Colors.red; // GlobalStyle.scheduleSelectionColor(_context);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawRect(GlobalContext.scheduleWindowInlineRect, backgroundPainter);

    if (GlobalContext.scheduleWindowSelectionBox != null) {
      canvas.drawRect(GlobalContext.scheduleWindowSelectionBox!, rectPainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
