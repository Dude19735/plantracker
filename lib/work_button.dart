import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

/// Flutter code sample for [IconButton].

enum WorkButtonType { red, blue }

class WorkButton extends StatefulWidget {
  final GlobalContext _globalContext;
  final WorkButtonType _type;
  late final String _label;
  late final double _width;
  late final double _height;

  WorkButton(this._globalContext, this._type, this._width, this._height) {
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
  Widget _getButton(BoxConstraints constraints) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        child: SvgPicture.asset(widget._label,
            width: constraints.maxHeight,
            height: constraints.maxWidth,
            semanticsLabel: 'Label'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: widget._width * 0.2,
            height: widget._height * 0.5,
            color: Colors.amber),
        // child: SizedBox(
        //   width: widget._width * 0.2,
        //   height: widget._height,
        //   child: Text(
        //     "hello world",
        //     style: TextStyle(background: Paint()..color = Colors.yellow),
        //   ),
        // ),
        SizedBox(
          width: widget._width * 0.7,
          height: widget._height * 0.5,
          child: IconButton(
              onPressed: () {},
              iconSize: 60,
              icon: SvgPicture.asset(widget._label, semanticsLabel: 'Label')),
        ),
      ],
    );
  }
}
