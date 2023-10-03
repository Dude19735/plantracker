import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scheduler/context.dart';
import 'package:scheduler/data.dart';
import 'package:scheduler/data_columns.dart';
import 'dart:math';

// class TimeTableBox extends StatefulWidget {
//   final TimeTableData? _subject;
//   final double _width;
//   final double _height;
//   final int _dayOffset;

//   TimeTableBox(this._width, this._height, this._dayOffset, this._subject);

//   @override
//   State<TimeTableBox> createState() => _TimeTableBox();
// }

class BoxEnterNotification extends Notification {
  final int x;
  final int y;
  BoxEnterNotification(this.x, this.y);
}

class BoxLeaveNotification extends Notification {
  final int x;
  final int y;
  BoxLeaveNotification(this.x, this.y);
}

class BoxPressedNotification extends Notification {
  final int x;
  final int y;
  BoxPressedNotification(this.x, this.y);
}

class BoxCancelNotification extends Notification {
  final int x;
  final int y;
  BoxCancelNotification(this.x, this.y);
}

class BoxApproveNotification extends Notification {
  final int x;
  final int y;
  final TimeTableData data;
  BoxApproveNotification(this.x, this.y, this.data);
}

enum TimeTableCellState { inactive, hover, pressed }

class TimeTableBox extends StatelessWidget {
  final double _width;
  final double _height;
  final TimeTableData _subject;
  final List<List<TimeTableCellState>> _edit;
  final int _x;
  final int _y;
  late String _planed;

  TimeTableBox(
      this._x, this._y, this._width, this._height, this._subject, this._edit) {
    _planed = _subject.planed.toString();
  }

  void _showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Input Error"),
      content: Text("Planed times have to be numbers!"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _getEditContainer(BuildContext context, TimeTableData? subject) {
    var focusNode = FocusNode();
    // FocusScope.of(context).requestFocus(focusNode);
    // focusNode.requestFocus();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double ratio = constraints.maxWidth / constraints.maxHeight;
      // print(ratio);
      if (ratio < 0.359) return SizedBox();

      var textField = TextFormField(
          onChanged: (value) {
            print("value changed $value");
            _planed = value;
          },
          focusNode: focusNode,
          initialValue: subject != null ? subject.planed.toString() : "",
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: subject == null ? "..." : "",
          ));

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
                          // height: constraints.maxHeight / 2,
                          width: constraints.maxWidth / 2,
                          child: IconButton(
                            onPressed: () {
                              try {
                                double p = 0.0;
                                if (_planed.compareTo("") != 0) {
                                  p = double.parse(_planed);
                                }
                                print("${_subject.planed} => $p $_planed");
                                BoxApproveNotification(
                                    _x,
                                    _y,
                                    TimeTableData({
                                      ColumnName.subjectId: _subject.subjectId,
                                      ColumnName.date: _subject.date,
                                      ColumnName.planed: p,
                                      ColumnName.recorded: _subject.recorded,
                                      ColumnName.subject: _subject.subject
                                    })).dispatch(context);
                              } on FormatException {
                                _showAlertDialog(context);
                              } catch (e) {
                                print("some sort of exception");
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
                          // height: constraints.maxHeight / 2,
                          width: constraints.maxWidth / 2,
                          child: IconButton(
                            onPressed: () {
                              BoxCancelNotification(_x, _y).dispatch(context);
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
                        // ElevatedButton(onPressed: () {}, child: Text("Cancel"))
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
      // print(
      //     "${constraints.maxWidth} ${constraints.maxHeight} ${constraints.maxWidth / constraints.maxHeight}");
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
                    // if (constraints.maxWidth > w2)
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

  // SizedBox _getRowBox(double width, double height, BuildContext context,
  //     TimeTableData? subject, int dayOffset) {
  //   bool fill = subject != null;
  // }

  Widget? _mux(BuildContext context, bool fill) {
    if (_edit[_x][_y] == TimeTableCellState.pressed) {
      return _getEditContainer(context, _subject);
    }
    if (fill) {
      return _getFullContainer(context, _subject);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // return _getRowBox(widget._width, widget._height, context, widget._subject,
    //     widget._dayOffset);

    bool fill = _subject.planed != 0 || _subject.recorded != 0;
    // print("build cell $_x $_y ${_edit[_x][_y]}");
    return SizedBox(
      width: _width,
      child: GestureDetector(
        onTapUp: (details) {
          BoxPressedNotification(_x, _y).dispatch(context);
        },
        child: MouseRegion(
          onEnter: (event) {
            BoxEnterNotification(_x, _y).dispatch(context);
          },
          onExit: (event) {
            BoxLeaveNotification(_x, _y).dispatch(context);
          },
          child: GlobalStyle.createShadowContainer(context, _mux(context, fill),
              height: _height,
              margin: EdgeInsets.all(GlobalStyle.summaryCardMargin),
              shadow: fill ? true : false,
              border: true, // fill ? false : true,
              color: GlobalStyle.timeTableCellColor(context, _edit[_x][_y]),
              shadowColor: fill
                  ? GlobalStyle.timeTableCellShadeColorFull(context, _subject!)
                  : GlobalStyle.timeTableCellShadeColorEmpty(context)),
        ),
      ),
    );
  }
}
