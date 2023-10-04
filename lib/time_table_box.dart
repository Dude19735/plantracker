import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_columns.dart';
import 'dart:math';

class ScrollAndFocusNotification extends Notification {
  final void Function() doAfter;
  final double offset;
  ScrollAndFocusNotification(this.offset, this.doAfter);
}

enum TimeTableCellState { inactive, hover, pressed }

class TimeTableCellStateEncapsulation {
  int _lastX = -1;
  int _lastY = -1;
  final ScrollController _scrollController;
  late final List<List<void Function(TimeTableCellState state)?>> setState;
  late final List<List<TimeTableCellState>> state;

  int lastY() => _lastY;
  int lastX() => _lastX;

  void resetLast() {
    _lastX = -1;
    _lastY = -1;
  }

  bool pressAt(int oldX, int oldY, int dx, int dy, FocusNode? node) {
    if (oldX + dx >= 0 &&
        oldY + dy >= 0 &&
        oldX + dx < setState.length &&
        oldY + dy < setState[0].length) {
      if (state[oldX][oldY] != TimeTableCellState.inactive) {
        setState[oldX][oldY]!(TimeTableCellState.inactive);
        if (node != null && node.hasFocus) {
          node.unfocus();
        }
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
    // print("moveActiveStateTo $_lastX $_lastY ${setState[x][y]}");
    setState[x][y]!(newStateOfThis);

    return res;
  }

  TimeTableCellStateEncapsulation(
      int sRows, int sCols, this._scrollController) {
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

class _TimeTableBox extends State<TimeTableBox> {
  late String _planed;
  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    super.initState();
    _planed = "";
    // ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  void _esc() {
    setState(() {
      widget._state.state[widget._x][widget._y] = TimeTableCellState.inactive;
      widget._state.resetLast();
    });
  }

  void _enter() {
    if (!_formKey.currentState!.validate()) {
      Helpers.showAlertDialog(context, "Input must be a number!");
    } else {
      setState(() {
        if (_planed.compareTo("") != 0) {
          _setSubjectPlanTime(context, double.parse(_planed));
        }
        widget._state.state[widget._x][widget._y] = TimeTableCellState.inactive;
      });
    }
  }

  bool _move(int ox, int oy, FocusNode node) {
    return widget._state
        .pressAt(widget._state.lastX(), widget._state.lastY(), ox, oy, node);
  }

  _unfocus(FocusNode node) {
    if (node.hasFocus) {
      node.unfocus();
    }
  }

  Widget _getEditContainer(BuildContext context, TimeTableData? subject) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double ratio = constraints.maxWidth / constraints.maxHeight;
      if (ratio < 0.359) return SizedBox();

      if (subject != null) {
        _planed = subject.planed.toString();
      }

      var focusNode = FocusNode();
      double offset = widget._x * widget._height;
      ScrollAndFocusNotification(offset, () {
        FocusScope.of(context).requestFocus(focusNode);
      }).dispatch(context);
      // widget._state._scrollController.jumpTo(offset);

      var textField = Form(
        key: _formKey,
        child: TextFormField(
            // onTapOutside: (event) {
            //   print("tabbed outside");
            //   // focusNode.previousFocus();
            // },
            focusNode: focusNode,
            validator: (value) {
              // print("validate");
              if (value != null && value.compareTo("") == 0) return null;
              var val = double.tryParse(value!);
              return val != null ? null : "";
            },
            onChanged: (value) {
              _planed = value;
            },
            initialValue: subject != null ? _planed.toString() : "",
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              errorStyle: TextStyle(height: 0),
              hintText: subject == null ? "..." : "",
            )),
      );

      return Container(
          color: Colors.white,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Center(
            child: RawKeyboardListener(
                focusNode: FocusNode(),
                autofocus: true,
                onKey: (event) {
                  if (event is! RawKeyUpEvent) return;

                  if (event.logicalKey == LogicalKeyboardKey.escape) {
                    _unfocus(focusNode);
                    _esc();
                  } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                    _enter();
                    _move(0, 1, focusNode);
                  } else if (event.isShiftPressed) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      _move(0, -1, focusNode);
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowRight) {
                      _move(0, 1, focusNode);
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      _move(1, 0, focusNode);
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      _move(-1, 0, focusNode);
                    }
                  }
                },
                child: Column(
                  children: [
                    Expanded(child: textField),
                    if (ratio > 0.48)
                      Row(
                        children: [
                          SizedBox(
                            width: constraints.maxWidth / 2,
                            child: IconButton(
                              onPressed: () {
                                _unfocus(focusNode);
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
                            width: constraints.maxWidth / 2,
                            child: IconButton(
                              onPressed: () {
                                _unfocus(focusNode);
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
  }

  Widget _getFullContainer(BuildContext context, TimeTableData subject) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      Widget box;
      if (constraints.maxWidth / constraints.maxHeight >= 1.0) {
        box = SizedBox(
            height: GlobalStyle.summaryEntryBarHeight,
            child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
      } else if (constraints.maxWidth / constraints.maxHeight > 0.5) {
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
  }

  Widget? _mux(BuildContext context, bool fill, TimeTableData? subject) {
    if (widget._state.state[widget._x][widget._y] ==
        TimeTableCellState.pressed) {
      return _getEditContainer(context, subject);
    }
    if (fill) {
      return _getFullContainer(context, subject!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // make sure the cell has an entry
    widget._state.setState[widget._x][widget._y] = (TimeTableCellState state) {
      setState(() {
        widget._state.state[widget._x][widget._y] = state;
      });
    };

    var subject = _getSubject();
    bool fill =
        subject != null && (subject.planed != 0 || subject.recorded != 0);
    return SizedBox(
      width: widget._width,
      child: GestureDetector(
        onTapUp: (details) {
          setState(() {
            widget._state.moveActiveStateTo(widget._x, widget._y,
                TimeTableCellState.inactive, TimeTableCellState.pressed);
          });
        },
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
          child: GlobalStyle.createShadowContainer(
              context, _mux(context, fill, subject),
              height: widget._height,
              margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
              shadow: fill ? true : false,
              border: true, // fill ? false : true,
              color: GlobalStyle.timeTableCellColor(
                  context, widget._state.state[widget._x][widget._y]),
              shadowColor: fill
                  ? GlobalStyle.timeTableCellShadeColorFull(context, subject)
                  : GlobalStyle.timeTableCellShadeColorEmpty(context)),
        ),
      ),
    );
  }
}
