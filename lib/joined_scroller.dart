import 'package:flutter/material.dart';

enum JoinedScrollerSide { left, right }

typedef TControllerHash = int;
typedef TJumpTo = Map<TControllerHash, void Function(double offset)?>;
typedef TAnimTo = Map<TControllerHash,
    Future<void> Function(double offset, Curve curve, Duration duration)?>;
typedef TJumpToRegEntryNullable = Map<JoinedScrollerSide, TJumpTo?>;
typedef TAnimToRegEntryNullable = Map<JoinedScrollerSide, TAnimTo?>;
typedef TJumpToRegEntry = Map<JoinedScrollerSide, TJumpTo>;
typedef TAnimToRegEntry = Map<JoinedScrollerSide, TAnimTo>;

class JoinedScrollerNotification extends Notification {}

class JoinedScroller {
  bool _inAnimation = false;
  Map<TControllerHash, ScrollController> _controller = {};

  TJumpToRegEntryNullable _jumpTo = {
    JoinedScrollerSide.left: {},
    JoinedScrollerSide.right: {}
  };
  TAnimToRegEntryNullable _animateTo = {
    JoinedScrollerSide.left: {},
    JoinedScrollerSide.right: {}
  };
  TJumpToRegEntry _jumpToHidden = {
    JoinedScrollerSide.left: {},
    JoinedScrollerSide.right: {}
  };
  TAnimToRegEntry _animateToHidden = {
    JoinedScrollerSide.left: {},
    JoinedScrollerSide.right: {}
  };

  void _disable(JoinedScrollerSide side) {
    _jumpTo[side] = null;
    _animateTo[side] = null;
  }

  void _enable(JoinedScrollerSide side) {
    _jumpTo[side] = _jumpToHidden[side]!;
    _animateTo[side] = _animateToHidden[side]!;
  }

  JoinedScrollerSide _otherSide(JoinedScrollerSide side) {
    return side == JoinedScrollerSide.left
        ? JoinedScrollerSide.right
        : JoinedScrollerSide.left;
  }

  void _clean() {
    var left = JoinedScrollerSide.left;
    var right = JoinedScrollerSide.right;

    var keys = _jumpToHidden[left]!.keys.toList();
    for (var key in keys) {
      if (!_controller[key]!.hasClients) {
        remove(key, left);
      }
    }

    keys = _jumpToHidden[right]!.keys.toList();
    for (var key in keys) {
      if (!_controller[key]!.hasClients) {
        remove(key, right);
      }
    }
  }

  void remove(TControllerHash hash, JoinedScrollerSide side) {
    _controller[hash]!.dispose();
    _controller.remove(hash);
    _jumpTo[side]?.remove(hash);
    _jumpToHidden[side]!.remove(hash);
    _animateTo[side]?.remove(hash);
    _animateToHidden[side]!.remove(hash);
  }

  MapEntry<TControllerHash, ScrollController> register(
      double initOffset, JoinedScrollerSide side) {
    ScrollController controller = ScrollController(
        initialScrollOffset: initOffset, keepScrollOffset: true);

    int hash = controller.hashCode;
    _controller[hash] = controller;

    _jumpToHidden[side]![hash] = (double offset) {
      if (controller.hasClients) {
        controller.jumpTo(offset);
      } else {}
    };
    _jumpTo[side]?[hash] = _jumpToHidden[side]![hash];
    _animateToHidden[side]![hash] =
        (double offset, Curve curve, Duration duration) async {
      if (controller.hasClients) {
        return controller.animateTo(offset, duration: duration, curve: curve);
      } else {
        return Future<void>(() => {});
      }
    };
    _animateTo[side]?[hash] = _animateToHidden[side]![hash];
    return MapEntry(hash, controller);
  }

  void jumpTo(JoinedScrollerSide side, double offset) {
    if (_inAnimation) return;

    if (_jumpTo[side] != null) {
      _inAnimation = true;
      var oSide = _otherSide(side);

      _disable(oSide);
      var keys = _jumpTo[side]!.keys.toList();
      for (var key in keys) {
        _jumpTo[side]![key]!(offset);
      }
      _clean();
      _enable(oSide);
      _inAnimation = false;
    }
  }

  Stream<void> _animStream(
      double offset, Curve curve, Duration duration) async* {
    var left = JoinedScrollerSide.left;
    var right = JoinedScrollerSide.right;

    for (var key in _animateToHidden[left]!.keys) {
      yield _animateToHidden[left]![key]!(offset, curve, duration);
    }
    for (var key in _animateToHidden[right]!.keys) {
      yield _animateToHidden[right]![key]!(offset, curve, duration);
    }
  }

  Future<void> _animHelper(Stream<void> stream) async {
    await stream.last;
  }

  void animateBothTo(double offset, Curve curve, Duration duration) {
    if (_inAnimation) return;

    var left = JoinedScrollerSide.left;
    var right = JoinedScrollerSide.right;
    _inAnimation = true;

    _disable(left);
    _disable(right);
    _animHelper(_animStream(offset, curve, duration)).then((value) {
      _clean();
      _enable(left);
      _enable(right);
      _inAnimation = false;
    });
  }
}
