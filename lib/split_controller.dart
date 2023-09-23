import 'package:flutter/material.dart';
import 'dart:math';

import 'package:scheduler/split.dart';

enum SplitControllerLocation { top, bottom }

class SplitController {
  final PageController _topPageController =
      PageController(initialPage: 2 << 31);
  final PageController _bottomPageController =
      PageController(initialPage: 2 << 31);

  bool _bottomPageScrolling = false;
  // bool _topPageScrolling = false;
  // bool _inAnimation = false;
  // bool _reverse = false;
  late final int animationMs;

  // late Animation<double> _animation;
  // late AnimationController _controller;

  SplitController(
      //dynamic parentState, Function() onAnimationStepCompleted,
      {this.animationMs = 250}) {
    // if (parentState is! TickerProvider) {
    //   throw Exception("SplitController Parent must be TickerProvider");
    // }
    // _controller = AnimationController(
    //     duration: Duration(milliseconds: animationMs), vsync: parentState);

    // _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
    //   ..addListener(() {
    //     // print("listener doing it's thing");
    //     // if (_bottomPageScrolling) {

    //     double pos = _bottomPageController.position.pixels;
    //     if (_reverse) {
    //       pos = pos.ceilToDouble() - _animation.value;
    //     } else {
    //       pos = pos.floorToDouble() + _animation.value;
    //     }

    //     print(
    //         "$_reverse ${_bottomPageController.position.pixels} ${_animation.value} $pos");
    //     _topPageController.position.jumpTo(pos);

    //     _bottomPageController.position.jumpTo(pos);

    //     if (_controller.status == AnimationStatus.completed) {
    //       _inAnimation = false;
    //       _controller.stop();
    //       _controller.reset();
    //       print("finished animation");
    //     }
    //     onAnimationStepCompleted();
    //   });
  }

  void nextPage({Curve curve = Curves.linear}) {
    _topPageController.nextPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
    _bottomPageController.nextPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
    // bottomPageController.position.addListener(() {topPageController.position})
  }

  void previousPage({Curve curve = Curves.linear}) {
    _topPageController.previousPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
    _bottomPageController.previousPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
  }

  Widget widget(Widget child, SplitControllerLocation location) {
    return NotificationListener(
      onNotification: (notification) {
        // if (_inAnimation) {
        //   return false;
        // }
        if (notification is UserScrollNotification) {
          // print("scroll start notification notification");
          // _controller.reset();
          if (location == SplitControllerLocation.top) {
            _bottomPageScrolling = false;
            // _topPageScrolling = true;
          } else if (location == SplitControllerLocation.bottom) {
            _bottomPageScrolling = true;
            // _topPageScrolling = false;
          }
        }
        // else if (notification is ScrollEndNotification) {
        //   if (notification.dragDetails != null) {
        //     // _bottomPageController.animateTo(2.0,
        //     //     curve: Curves.linear, duration: Duration(milliseconds: 2000));
        //     // _topPageController.nextPage(
        //     //     curve: Curves.linear, duration: Duration(milliseconds: 2000));

        //     // _bottomPageScrolling = false;
        //     // _topPageScrolling = false;
        //     // _inAnimation = true;

        //     // double rem = _bottomPageController.position.pixels -
        //     //     _bottomPageController.position.pixels.floor();
        //     // if (rem < 0.5) {
        //     //   _reverse = true;
        //     //   _controller.forward(from: 1 - rem);
        //     // } else {
        //     //   _reverse = false;
        //     //   _controller.forward(from: rem);
        //     // }

        //     // print(notification.dragDetails);
        //     // print("scroll end notification ${Random().nextInt(10000)}");
        //   }
        // } else
        else if (notification is ScrollUpdateNotification) {
          if (_bottomPageScrolling) {
            _topPageController.position
                .jumpTo(_bottomPageController.position.pixels);
          } else {
            _bottomPageController.position
                .jumpTo(_topPageController.position.pixels);
          }
          // print(_bottomPageController.position.pixels);
          // print("scroll update notification");
        }
        return false;
      },
      child: PageView.builder(
        controller: location == SplitControllerLocation.top
            ? _topPageController
            : _bottomPageController,
        pageSnapping: true,
        itemBuilder: (context, index) {
          return Center(
            child: child,
          );
        },
      ),
    );
  }
}
