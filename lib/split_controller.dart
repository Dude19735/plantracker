import 'package:flutter/material.dart';

enum SplitControllerLocation { top, bottom }

class ChangePageNotification extends Notification {
  final bool backwards;
  ChangePageNotification(this.backwards);
}

class PageScrolledNotification extends Notification {
  final int page;
  final bool backwards;
  final bool flipPage;
  PageScrolledNotification(this.page, this.backwards, {this.flipPage = false});
}

class SplitController {
  bool _bottomPageScrolling = false;
  late final int animationMs;
  int _currentPage = 2 << 31;
  final PageController _topPageController =
      PageController(initialPage: 2 << 31);
  final PageController _bottomPageController =
      PageController(initialPage: 2 << 31);

  bool emitNotificationOnPageChanged = true;

  SplitController({this.animationMs = 250});

  void nextPage({Curve curve = Curves.linear}) {
    _topPageController.nextPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
    _bottomPageController.nextPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
  }

  void previousPage({Curve curve = Curves.linear}) {
    _topPageController.previousPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
    _bottomPageController.previousPage(
        duration: Duration(milliseconds: animationMs), curve: curve);
  }

  Widget widget(BuildContext context, Widget Function(int) childBuilder,
      SplitControllerLocation location) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (location == SplitControllerLocation.top) {
            _bottomPageScrolling = false;
          } else if (location == SplitControllerLocation.bottom) {
            _bottomPageScrolling = true;
          }
        } else if (notification is ScrollUpdateNotification) {
          if (_bottomPageScrolling) {
            _topPageController.position
                .jumpTo(_bottomPageController.position.pixels);
          } else {
            _bottomPageController.position
                .jumpTo(_topPageController.position.pixels);
          }
        }
        return false;
      },
      child: PageView.builder(
        clipBehavior: Clip.none,
        allowImplicitScrolling: true,
        onPageChanged: (page) {
          if (page != _currentPage) {
            bool backwards = page < _currentPage;
            _currentPage = page;
            PageScrolledNotification(page, backwards).dispatch(context);
          }
        },
        controller: location == SplitControllerLocation.top
            ? _topPageController
            : _bottomPageController,
        pageSnapping: true,
        itemBuilder: (context, index) {
          // print("build page $index $_currentPage ${index - _currentPage}");
          // child.setPageOffset(_currentPage - index);
          return Center(
            child: childBuilder(index - _currentPage),
          );
        },
      ),
    );
  }
}
