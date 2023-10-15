import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scheduler/context.dart';
import 'dart:collection';

enum SplitControllerLocation { top, bottom }

class ChangePageNotification extends Notification {}

class StartChangeSplitControllerPageNotification
    extends ChangePageNotification {
  final ScrollDirection direction;
  StartChangeSplitControllerPageNotification(this.direction);
}

class EndChangeSplitControllerPageNotification extends ChangePageNotification {}

// class PageScrolledNotification extends Notification {
//   final int page;
//   final bool backwards;
//   final bool flipPage;
//   PageScrolledNotification(this.page, this.backwards, {this.flipPage = false});
// }

class PVScrollPhysics extends ScrollPhysics {
  const PVScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  PVScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PVScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}

class SplitController {
  bool _bottomPageScrolling = false;
  late final int animationMs;
  int _currentPage = GlobalSettings.splitControllerInitPage;
  final PageController _topPageController =
      PageController(initialPage: GlobalSettings.splitControllerInitPage);
  final PageController _bottomPageController =
      PageController(initialPage: GlobalSettings.splitControllerInitPage);
  // Queue<int> _queued = Queue();

  SplitController({this.animationMs = 500});

  void changePage(ScrollDirection direction, void Function() doAfter,
      {Curve curve = Curves.decelerate}) {
    if (direction == ScrollDirection.forward) {
      // the _currentPage must be changed before the split_controller rebuild
      _currentPage++;
      _topPageController.nextPage(
          duration: Duration(milliseconds: animationMs), curve: curve);
      _bottomPageController
          .nextPage(duration: Duration(milliseconds: animationMs), curve: curve)
          .then((value) {
        doAfter();
      });
    } else if (direction == ScrollDirection.reverse) {
      // the _currentPage must be changed before the split_controller rebuild
      _currentPage--;
      _topPageController.previousPage(
          duration: Duration(milliseconds: animationMs), curve: curve);
      _bottomPageController
          .previousPage(
              duration: Duration(milliseconds: animationMs), curve: curve)
          .then((value) {
        doAfter();
      });
    }
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
        // allowImplicitScrolling: true,
        clipBehavior: Clip.none,
        physics: PVScrollPhysics(),
        onPageChanged: (page) {
          if (page != _currentPage) {
            Debugger.splitController(
                "   page changed in builder $_currentPage => $page");

            _currentPage = page;
          }
        },
        controller: location == SplitControllerLocation.top
            ? _topPageController
            : _bottomPageController,
        pageSnapping: true,
        itemBuilder: (context, index) {
          Debugger.splitController(
              "      =====> Generating page with index $index and current page number $_currentPage and offset ${index - _currentPage}");
          return Center(
            child: childBuilder(index - _currentPage),
          );
        },
      ),
    );
  }
}
