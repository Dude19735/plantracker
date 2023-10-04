import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_columns.dart';
import 'dart:math';

enum TimeTableCellState { inactive, hover, pressed }

class TimeTableCellStateEncapsulation {
  int _lastX = -1;
  int _lastY = -1;
  late final List<List<void Function(TimeTableCellState state)?>> setState;
  late final List<List<TimeTableCellState>> state;

  void resetLast() {
    _lastX = -1;
    _lastY = -1;
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
  }

  Widget _getEditContainer(BuildContext context, TimeTableData? subject) {
    var focusNode = FocusNode();
    // FocusScope.of(context).requestFocus(focusNode);
    // focusNode.requestFocus();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double ratio = constraints.maxWidth / constraints.maxHeight;
      if (ratio < 0.359) return SizedBox();

      if (subject != null) {
        _planed = subject.planed.toString();
      }
      var textField = Form(
        key: _formKey,
        child: TextFormField(
            // onTapOutside: (event) {
            //   print("tabbed outside");
            //   // focusNode.previousFocus();
            // },
            validator: (value) {
              print("validate");
              var val = double.tryParse(value!);
              return val != null ? null : "";
            },
            onChanged: (value) {
              _planed = value;
            },
            focusNode: focusNode,
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
            child: Focus(
              onFocusChange: (value) {
                // FocusScope.of(context).requestFocus(focusNode);
              },
              autofocus: true,
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
                              if (!_formKey.currentState!.validate()) {
                                Helpers.showAlertDialog(
                                    context, "Input must be a number!");
                              } else {
                                setState(() {
                                  _setSubjectPlanTime(
                                      context, double.parse(_planed));
                                  widget._state.state[widget._x][widget._y] =
                                      TimeTableCellState.inactive;
                                  widget._state.resetLast();
                                });
                              }
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
                              setState(() {
                                widget._state.state[widget._x][widget._y] =
                                    TimeTableCellState.inactive;
                                widget._state.resetLast();
                              });
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
              ),
            ),
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
