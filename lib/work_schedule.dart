// import 'animated_toggle.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scheduler/context.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/work_toggler.dart';

/// Flutter code sample for [IconButton].

class WorkSchedule extends StatefulWidget {
  final GlobalContext _globalContext;

  WorkSchedule(this._globalContext);

  @override
  State<WorkSchedule> createState() => _WorkSchedule();
}

class _WorkSchedule extends State<WorkSchedule>
    with SingleTickerProviderStateMixin {
  // List<bool> _isDisabled = [false, true, false];

  // void _onTap() {
  //   if (_isDisabled[_controller.index]) {
  //     int index = _controller.previousIndex;
  //     setState(() {
  //       _controller.index = index;
  //     });
  //   }
  // }

  @override
  void initState() {
    // _controller.addListener(_onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.amber,
          width: double.infinity,
          height: GlobalStyle.appBarHeight,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.chevron_left)),
              Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: IconButton(
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100));
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: IconButton(
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100));
                    },
                    icon: Icon(Icons.calendar_month_outlined)),
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
