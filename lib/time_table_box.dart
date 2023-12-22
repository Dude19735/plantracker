import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_columns.dart';
import 'dart:math';

import 'package:scheduler/data_utils.dart';
import 'package:scheduler/date.dart';

class ScrollAndFocusNotification extends Notification {
  final void Function() doAfter;
  final double offset;
  ScrollAndFocusNotification(this.offset, this.doAfter);
}

enum TimeTableCellState { inactive, hover, pressed }

class TimeTableCellStateEncapsulation {
  int _lastX = -1;
  int _lastY = -1;
  late final List<List<void Function(TimeTableCellState state)?>> setState;
  late final List<List<TimeTableCellState>> state;

  int lastY() => _lastY;
  int lastX() => _lastX;

  void resetLast() {
    _lastX = -1;
    _lastY = -1;
  }

  @override
  String toString() {
    return "${setState.hashCode} ${state.hashCode}";
  }

  bool pressAt(int oldX, int oldY, int dx, int dy) {
    if (oldX + dx >= 0 &&
        oldY + dy >= 0 &&
        oldX + dx < setState.length &&
        oldY + dy < setState[0].length) {
      if (state[oldX][oldY] != TimeTableCellState.inactive) {
        setState[oldX][oldY]!(TimeTableCellState.inactive);
      }

      _lastX = oldX + dx;
      _lastY = oldY + dy;

      setState[_lastX][_lastY]!(TimeTableCellState.pressed);
      return true;
    }
    return false;
  }

  bool moveActiveStateTo(int x, int y, TimeTableCellState newStateOfLast,
      TimeTableCellState newStateOfThis) {
    bool res = true;
    if (_lastX == -1) {
      res = false;
    } else {
      setState[_lastX][_lastY]!(newStateOfLast);
    }

    _lastX = x;
    _lastY = y;
    setState[x][y]!(newStateOfThis);

    return res;
  }

  TimeTableCellStateEncapsulation(int sRows, int sCols) {
    state = List<List<TimeTableCellState>>.generate(
        sRows,
        (i) => List<TimeTableCellState>.generate(
            sCols, (index) => TimeTableCellState.inactive,
            growable: false),
        growable: false);

    setState = List<List<void Function(TimeTableCellState state)?>>.generate(
        sRows,
        (i) => List<void Function(TimeTableCellState state)?>.generate(
            sCols, (index) => null,
            growable: false),
        growable: false);
  }
}

class SettableFocusNode extends FocusNode {
  bool _focus = true;
  set focus(bool value) {
    _focus = value;
  }

  @override
  bool get hasFocus => _focus;
}

class TimeTableBox extends StatefulWidget {
  final double _width;
  final double _height;
  final int _subjectId;
  final int _date;
  final int _x;
  final int _y;
  final TimeTableCellStateEncapsulation _state;

  TimeTableBox(this._x, this._y, this._width, this._height, this._subjectId,
      this._date, this._state);

  @override
  State<TimeTableBox> createState() => _TimeTableBox();
}

class _TimeTableBox extends State<TimeTableBox>
    with AutomaticKeepAliveClientMixin {
  // late String _planed;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final Set<LogicalKeyboardKey> _digits = {
    LogicalKeyboardKey.digit0,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9,
    // LogicalKeyboardKey.colon,
    // LogicalKeyboardKey.comma,
    LogicalKeyboardKey.period,
    LogicalKeyboardKey.numpad0,
    LogicalKeyboardKey.numpad1,
    LogicalKeyboardKey.numpad2,
    LogicalKeyboardKey.numpad3,
    LogicalKeyboardKey.numpad4,
    LogicalKeyboardKey.numpad5,
    LogicalKeyboardKey.numpad6,
    LogicalKeyboardKey.numpad7,
    LogicalKeyboardKey.numpad8,
    LogicalKeyboardKey.numpad9,
  };

  TimeTableData? _getSubject() {
    var subj = GlobalContext.data.timeTableData.data[widget._subjectId];
    if (subj != null) {
      var sDate = subj[widget._date];
      if (sDate != null) {
        return sDate;
      }
    }
    return null;
  }

  void _setSubjectPlanTime(BuildContext context, double planed) {
    var subj = GlobalContext.data.timeTableData.data[widget._subjectId];
    bool send = false;
    if (subj != null) {
      var sDate = subj[widget._date];
      {
        if (sDate != null) {
          var old = GlobalContext.data.timeTableData
              .data[widget._subjectId]![widget._date]!.planed;
          GlobalContext.data.timeTableData
              .data[widget._subjectId]![widget._date]!.planed = planed;
          if (old == planed) {
            send = false;
          }
        } else if (planed != 0) {
          send = true;
          GlobalContext.data.timeTableData
              .data[widget._subjectId]![widget._date] = TimeTableData({
            ColumnName.subjectId: widget._subjectId,
            ColumnName.date: widget._date,
            ColumnName.planed: planed,
            ColumnName.recorded: 0.0,
            ColumnName.subject:
                GlobalContext.data.subjectData.data[widget._subjectId]!.subject
          });
        }
      }
    } else if (planed != 0) {
      GlobalContext.data.timeTableData.data[widget._subjectId] = {
        widget._date: TimeTableData({
          ColumnName.subjectId: widget._subjectId,
          ColumnName.date: widget._date,
          ColumnName.planed: planed,
          ColumnName.recorded: 0.0,
          ColumnName.subject:
              GlobalContext.data.subjectData.data[widget._subjectId]!.subject
        })
      };
      send = true;
    }

    if (send) {
      DataChangedNotificationTimeTableData().dispatch(context);
    }
  }

  void _esc() {
    if (widget._state.state[widget._x][widget._y] !=
        TimeTableCellState.inactive) {
      setState(() {
        widget._state.state[widget._x][widget._y] = TimeTableCellState.inactive;
        widget._state.resetLast();
      });
    }
  }

  void _enter() {
    if (!_formKey.currentState!.validate()) {
      Helpers.showAlertDialog(context, "Input must be a number!");
    } else {
      setState(() {
        if (_controller.text.compareTo("") != 0) {
          _setSubjectPlanTime(context, double.parse(_controller.text));
        }
        widget._state.state[widget._x][widget._y] = TimeTableCellState.inactive;
      });
    }
  }

  bool _move(int ox, int oy) {
    return widget._state
        .pressAt(widget._state.lastX(), widget._state.lastY(), ox, oy);
  }

  bool _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _controller.text =
            _controller.text.substring(0, _controller.text.length - 1);
        return true;
      }
      if (_digits.contains(event.logicalKey)) {
        String label = event.logicalKey.keyLabel;
        String num = label.substring(label.length - 1, label.length);
        _controller.text += num;
        return true;
      }
    }

    if (event is! RawKeyUpEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _enter();
      _move(0, 1);
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _esc();
      return true;
    }

    if (event.isShiftPressed) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _move(0, -1);
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _move(0, 1);
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        double offset = (widget._x + 1) * widget._height;
        ScrollAndFocusNotification(offset, () {}).dispatch(context);
        _move(1, 0);
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        double offset = (widget._x - 1) * widget._height;
        ScrollAndFocusNotification(offset, () {}).dispatch(context);
        _move(-1, 0);
        return true;
      }
    }
    return false;
  }

  _unfocus(FocusNode node) {
    if (node.hasFocus) {
      node.unfocus();
    }
  }

  Widget _getEditContainer(BuildContext context, TimeTableData? subject) {
    var child = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double ratio = constraints.maxWidth / constraints.maxHeight;
      if (ratio < 0.359) return SizedBox();

      _controller.text = subject != null ? subject.planed.toString() : "";
      _controller.selection = TextSelection(
          baseOffset: 0, extentOffset: _controller.value.text.length);

      var textField = TextFormField(
          controller: _controller,
          enabled: false,
          // onTapOutside: (event) {
          //   _esc();
          // },
          validator: (value) {
            if (value != null && value.compareTo("") == 0) return null;
            var val = double.tryParse(value!);
            return val != null ? null : "";
          },
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            errorStyle: TextStyle(height: 0),
            hintText: subject == null ? "..." : "",
          ));

      var textForm = Form(key: _formKey, child: textField);

      var keyboardFocus = FocusNode(onKey: (FocusNode node, RawKeyEvent event) {
        if (!_onKey(event)) {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      });

      keyboardFocus.requestFocus();

      return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
              color: GlobalStyle.timeTableActiveCellBackground(context),
              border: Border.all(
                  width: 1, color: GlobalStyle.scheduleGridColorBox(context)),
              borderRadius:
                  BorderRadius.circular(GlobalStyle.summaryCardBorderRadius)),
          child: Center(
            child: RawKeyboardListener(
                focusNode: keyboardFocus,
                autofocus: true,
                // onKey: _onKey,
                child: Column(
                  children: [
                    Expanded(child: textForm),
                    if (ratio > 0.48)
                      Row(
                        children: [
                          SizedBox(
                            width: constraints.maxWidth / 2 - 1,
                            child: IconButton(
                              onPressed: () {
                                _enter();
                                widget._state.resetLast();
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero))),
                              icon: Icon(Icons.check),
                              iconSize: min(constraints.maxHeight / 3,
                                  constraints.maxWidth / 3),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth / 2 - 1,
                            child: IconButton(
                              onPressed: () {
                                _esc();
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero))),
                              icon: Icon(Icons.cancel),
                              iconSize: min(constraints.maxHeight / 3,
                                  constraints.maxWidth / 3),
                              padding: EdgeInsets.zero,
                            ),
                          )
                        ],
                      )
                  ],
                )),
          ));
    });

    // make sure that new text fields are always created in inactive state
    // to avoid exceptions during sideways scrolling
    return GlobalStyle.createShadowContainer(context, child,
        height: widget._height,
        margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
        shadow: false,
        border: true,
        borderColor: GlobalStyle.timeTableSelectedCellBorderColor(context),
        color: GlobalStyle.timeTableCellShadeColorEmpty(
            context, widget._state.state[widget._x][widget._y]));
  }

  Widget _getFullContainer(BuildContext context, TimeTableData subject) {
    var outerBox = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var date = Date.fromInt(subject.date);
      Widget box;
      double aspect = constraints.maxWidth / constraints.maxHeight;
      if (aspect >= 1.0) {
        box = SizedBox(
            height: GlobalStyle.summaryEntryBarHeight,
            child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (aspect >= 2.0) Text(date.toFormatedString()),
                        if (aspect >= 2.0) Spacer(),
                        Text(subject.recorded.toString(),
                            style: TextStyle(fontSize: 16)),
                        Text("/"),
                        Text(subject.planed.toString(),
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Column(children: [
                      SizedBox(height: GlobalStyle.summaryEntryBarHeight / 3),
                      SizedBox(
                        width: constraints.maxWidth,
                        height: GlobalStyle.summaryEntryBarHeight / 2,
                        child: AnimatedFractionallySizedBox(
                          alignment: Alignment.topLeft,
                          duration: const Duration(seconds: 2),
                          curve: Curves.fastOutSlowIn,
                          widthFactor: clampDouble(
                              subject.recorded / subject.planed, 0, 1),
                          heightFactor: 1.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: GlobalStyle.timeTableCellBarColor(
                                  context,
                                  clampDouble(subject.recorded / subject.planed,
                                      0.05, 1.0)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: GlobalStyle.summaryEntryBarHeight / 3),
                      SizedBox(
                        width: constraints.maxWidth,
                        height: GlobalStyle.summaryEntryBarHeight / 2,
                        child: AnimatedFractionallySizedBox(
                          alignment: Alignment.topLeft,
                          duration: const Duration(seconds: 2),
                          curve: Curves.fastOutSlowIn,
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: GlobalStyle.timeTableCellBarColor(
                                  context, 1.0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ])
                  ],
                )));
      } else if (aspect > 0.5) {
        box = SizedBox(
            height: GlobalStyle.summaryEntryBarHeight,
            child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(subject.recorded.toString(),
                        style: TextStyle(fontSize: 16)),
                    Text(subject.planed.toString(),
                        style: TextStyle(fontSize: 12))
                  ],
                )));
      } else {
        box = SizedBox();
      }

      return Padding(
          padding: EdgeInsets.all(GlobalStyle.summaryCardPadding), child: box);
    });

    return GestureDetector(
        onTapUp: _f,
        child: GlobalStyle.createShadowContainer(context, outerBox,
            height: widget._height,
            margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
            shadow: false,
            border: true,
            borderColor: GlobalStyle.timeTableFullCellBorderColor(context),
            color: GlobalStyle.timeTableCellShadeColorFull(context, subject)));
  }

  Widget _getEmptyContainer(context) {
    return GestureDetector(
        onTapUp: _f,
        child: GlobalStyle.createShadowContainer(context, null,
            height: widget._height,
            margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
            shadow: false,
            border: true,
            borderColor: GlobalStyle.timeTableEmptyCellBorderColor(context),
            color: GlobalStyle.timeTableCellShadeColorEmpty(
                context, widget._state.state[widget._x][widget._y])));
  }

  void _f(TapUpDetails details) {
    setState(() {
      widget._state.moveActiveStateTo(widget._x, widget._y,
          TimeTableCellState.inactive, TimeTableCellState.pressed);
      double offset = widget._x * widget._height;
      ScrollAndFocusNotification(offset, () {}).dispatch(context);
    });
  }

  Widget? _mux(BuildContext context, bool fill, TimeTableData? subject) {
    if (widget._state.state[widget._x][widget._y] ==
        TimeTableCellState.pressed) {
      return _getEditContainer(context, subject);
    }
    if (fill) {
      return _getFullContainer(context, subject!);
    }
    return _getEmptyContainer(context);
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    Debugger.timeTableBox(
        "Init cell ${widget._x} ${widget._y} ${widget._date} ${hashCode.toRadixString(16)}");
  }

  @override
  void dispose() {
    super.dispose();
    Debugger.timeTableBox(
        "Dispose cell ${widget._x} ${widget._y} ${hashCode.toRadixString(16)}");
    // widget._state.setState[widget._x][widget._y] = (TimeTableCellState state) {
    //   print(
    //       "tried to update disposed widget ${widget._x} ${widget._y} $hashCode");
    // };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Debugger.timeTableBox(
        "Build cell ${widget._x} ${widget._y} ${widget._date}");

    widget._state.setState[widget._x][widget._y] = (TimeTableCellState state) {
      Debugger.timeTableBox(
          "Run setState of ${widget._x} ${widget._y} ${widget._date}");
      setState(() {
        widget._state.state[widget._x][widget._y] = state;
      });
    };

    var subject = _getSubject();
    bool fill =
        subject != null && (subject.planed != 0 || subject.recorded != 0);
    return SizedBox(
      width: widget._width,
      child: MouseRegion(
        onEnter: (event) {
          if (widget._state.state[widget._x][widget._y] !=
              TimeTableCellState.pressed) {
            setState(() {
              widget._state.state[widget._x][widget._y] =
                  TimeTableCellState.hover;
            });
          }
        },
        onExit: (event) {
          if (widget._state.state[widget._x][widget._y] !=
              TimeTableCellState.pressed) {
            setState(() {
              widget._state.state[widget._x][widget._y] =
                  TimeTableCellState.inactive;
            });
          }
        },
        child: _mux(context, fill, subject),
      ),
    );
  }
}
