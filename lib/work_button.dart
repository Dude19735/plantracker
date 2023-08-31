import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flutter code sample for [IconButton].

enum WorkButtonType { red, blue }

class WorkButton extends StatefulWidget {
  final GlobalContext _globalContext;
  final WorkButtonType _type;
  late final String _label;

  WorkButton(this._globalContext, this._type) {
    if (_type == WorkButtonType.red) {
      _label = "lib/img/clock_red.svg";
    } else {
      _label = "lib/img/clock_blue.svg";
    }
  }

  @override
  State<WorkButton> createState() => _WorkButton();
}

class _WorkButton extends State<WorkButton> {
  Widget _getButton() {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(width: 5),
          color: Colors.greenAccent,
        ),
        child: InkWell(
          //borderRadius: BorderRadius.circular(100.0),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: SvgPicture.asset(widget._label, semanticsLabel: 'Label'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return _getButton();
      // IconButton(
      //     padding: EdgeInsets.all(0),
      //     icon: SvgPicture.asset(widget._label, semanticsLabel: 'Label'),
      //     onPressed: () {});
    });
  }
}
