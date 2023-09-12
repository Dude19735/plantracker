// import 'animated_toggle.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/work_toggler.dart';
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
  // Widget _getButton(BoxConstraints constraints) {
  //   return Material(
  //     type: MaterialType.transparency,
  //     child: InkWell(
  //       onTap: () {},
  //       child: SvgPicture.asset(widget._label,
  //           width: constraints.maxHeight,
  //           height: constraints.maxWidth,
  //           semanticsLabel: 'Label'),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 1,
        child: Column(
          children: [
            Expanded(
                child: RotatedBox(
                    quarterTurns: 1,
                    child: WorkToggler(
                      onHitL: () {
                        print("L");
                      },
                      onHitR: () {
                        print("R");
                      },
                      minSliderRatio: 0.5,
                    ))),
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
            ),
            // AnimatedToggle(120, 60, const ["OFF", " ON "],
            //     buttonColor: Theme.of(context).colorScheme.primary,
            //     buttonTextColor: Theme.of(context).colorScheme.background,
            //     backgroundColor: Colors.transparent,
            //     textColor: Theme.of(context).textTheme.titleSmall!.color!,
            //     forcedPosition: true)
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Padding(
        padding: EdgeInsets.only(top: 0, bottom: 0),
        child: RotatedBox(
          quarterTurns: 1,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(),
                trackHeight: 3,
                trackShape: CustomTrackShape(),
                disabledActiveTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent),
            child: Slider(
                value: _currentSliderValue,
                max: 1,
                divisions: 1,
                onChanged: (double value) {
                  setState(() {
                    if (value == 1) {
                    } else if (value == 0) {}
                    _currentSliderValue = value;
                  });
                }),
          ),
        ),
      );
    });
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
