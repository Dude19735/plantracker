import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/work_toggler.dart';

enum WorkButtonType { red, blue }

class WorkButton extends StatefulWidget {
  @override
  State<WorkButton> createState() => _WorkButton();
}

class _WorkButton extends State<WorkButton> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 1,
        child: Column(
          children: [
            Expanded(
                child: GlobalStyle.createShadowContainer(
                    context,
                    RotatedBox(
                        quarterTurns: 1,
                        child: WorkToggler(
                          onHitL: () {
                            print("L");
                          },
                          onHitR: () {
                            print("R");
                          },
                          icon: [
                            Icons.keyboard_double_arrow_right_outlined,
                            Icons.keyboard_double_arrow_left_outlined
                          ],
                          minSliderRatio: 0.5,
                          restingColorL: GlobalStyle.markerRed(context),
                          restingColorR: GlobalStyle.markerBlue(context),
                        )),
                    margin: EdgeInsets.all(0.0),
                    padding: EdgeInsets.all(0.0),
                    borderRadius: GlobalStyle.clockBarBoxRadius,
                    borderColor:
                        GlobalStyle.clockBarTogglerButtonOutline(context),
                    shadow: false,
                    border: true)),
          ],
        ),
      ),
      Expanded(
        flex: 2,
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
          ],
        ),
      )
    ]);
  }
}
