import 'package:flutter/material.dart';

class SplitController {
  final PageController topPageController = PageController(initialPage: 2 << 31);
  final PageController bottomPageController =
      PageController(initialPage: 2 << 31);

  void nextPage(
      {Duration duration = const Duration(milliseconds: 250),
      Curve curve = Curves.linear}) {
    topPageController.nextPage(duration: duration, curve: curve);
    bottomPageController.nextPage(duration: duration, curve: curve);
    // bottomPageController.position.addListener(() {topPageController.position})
  }

  void previousPage(
      {Duration duration = const Duration(milliseconds: 250),
      Curve curve = Curves.linear}) {
    topPageController.previousPage(duration: duration, curve: curve);
    bottomPageController.previousPage(duration: duration, curve: curve);
  }
}
