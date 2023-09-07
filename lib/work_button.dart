import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

/// Flutter code sample for [IconButton].

enum WorkButtonType { red, blue }

class WorkButton extends StatefulWidget {
  final GlobalContext _globalContext;
  late final String _label;

  WorkButton(this._globalContext);

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
    return Row(children: [
      Expanded(
        flex: 1,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: WorkBreakSlider()),
                ],
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 3,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                        onPressed: () {},
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero))),
                        icon: SvgPicture.asset("lib/img/clock_red.svg",
                            semanticsLabel: 'Label')),
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: IconButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero))),
                      icon: SvgPicture.asset("lib/img/clock_blue.svg",
                          semanticsLabel: 'Label')),
                )
              ]),
            )
          ],
        ),
      )
    ]);
  }
}

class WorkBreakSlider extends StatefulWidget {
  const WorkBreakSlider({super.key});

  @override
  State<WorkBreakSlider> createState() => _WorkBreakSlider();
}

class _WorkBreakSlider extends State<WorkBreakSlider> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
            thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 7.0,
          pressedElevation: 4.0,
        )),
        child: Slider(
            value: _currentSliderValue,
            max: 1,
            divisions: 1,
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            }),
      ),
    );
  }
}
