import 'package:flutter/material.dart';

enum JoinedScrollerIdentifier { left, right }

class JoinedScrollerNotification extends Notification {}

class JoinedScroller {
  final Duration _afterDelay = Duration(milliseconds: 3);

  Map<JoinedScrollerIdentifier, void Function(double offset)?> _jumpTo = {
    JoinedScrollerIdentifier.left: null,
    JoinedScrollerIdentifier.right: null
  };

  Map<JoinedScrollerIdentifier,
          void Function(double offset, Curve curve, Duration duration)?>
      _animateTo = {
    JoinedScrollerIdentifier.left: null,
    JoinedScrollerIdentifier.right: null
  };

  Map<JoinedScrollerIdentifier, void Function(double offset)?> _jumpToHidden = {
    JoinedScrollerIdentifier.left: null,
    JoinedScrollerIdentifier.right: null
  };

  Map<JoinedScrollerIdentifier,
          void Function(double offset, Curve curve, Duration duration)?>
      _animateToHidden = {
    JoinedScrollerIdentifier.left: null,
    JoinedScrollerIdentifier.right: null
  };

  void _disable(JoinedScrollerIdentifier side) {
    _jumpTo[side] = null;
    _animateTo[side] = null;
  }

  void _enable(JoinedScrollerIdentifier side) {
    _jumpTo[side] = _jumpToHidden[side];
    _animateTo[side] = _animateToHidden[side];
  }

  void animateBothTo(double offset, Curve curve, Duration duration) {
    var left = JoinedScrollerIdentifier.left;
    var right = JoinedScrollerIdentifier.right;
    _disable(left);
    _disable(right);

    _animateToHidden[left]!(offset, curve, duration);
    _animateToHidden[right]!(offset, curve, duration);

    Future.delayed(duration + _afterDelay, () {
      _enable(left);
      _enable(right);
    });

    // var f1 = _setState[JoinedScrollerIdentifier.left];
    // var f2 = _setState[JoinedScrollerIdentifier.right];
    // _setState[JoinedScrollerIdentifier.right] = null;
    // _setState[JoinedScrollerIdentifier.left] = null;
  }

  void register(
      JoinedScrollerIdentifier identifier, ScrollController? controller) {
    if (controller != null) {
      _jumpTo[identifier] = (double offset) {
        controller.jumpTo(offset);
      };
      _jumpToHidden[identifier] = _jumpTo[identifier];

      _animateTo[identifier] = (double offset, Curve curve, Duration duration) {
        controller.animateTo(offset, duration: duration, curve: curve);
      };
      _animateToHidden[identifier] = _animateTo[identifier];
    } else {
      _jumpTo[identifier] = null;
      _jumpToHidden[identifier] = null;
      _animateTo[identifier] = null;
      _animateToHidden[identifier] = null;
    }
  }

  bool jumpTo(JoinedScrollerIdentifier scroller, double offset) {
    if (_jumpTo[scroller] != null) {
      var dSide = scroller == JoinedScrollerIdentifier.left
          ? JoinedScrollerIdentifier.right
          : JoinedScrollerIdentifier.left;

      _disable(dSide);
      _jumpTo[scroller]!(offset);
      _enable(dSide);

      return true;
    }
    return false;
  }

  bool animateTo(JoinedScrollerIdentifier scroller, double offset, Curve curve,
      Duration duration) {
    if (_animateTo[scroller] != null) {
      var dSide = scroller == JoinedScrollerIdentifier.left
          ? JoinedScrollerIdentifier.right
          : scroller;

      _disable(dSide);
      _animateTo[scroller]!(offset, curve, duration);
      Future.delayed(duration + _afterDelay, () => _enable(dSide));

      return true;
    }
    return false;
  }
}
