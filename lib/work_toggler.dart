import 'package:flutter/material.dart';
import 'dart:math';

enum _WorkTogglerState {
  slideLR,
  contractLR,
  slideRL,
  contractRL,
  retractLR,
  retractRL
}

class WorkToggler extends StatefulWidget {
  final void Function() onHitL;
  final void Function() onHitR;
  final Color restingColor;
  final Color activatedColor;
  final int animTimeMS;
  final double minSliderRatio;

  const WorkToggler(
      {required this.onHitL,
      required this.onHitR,
      this.restingColor = Colors.orange,
      this.activatedColor = Colors.red,
      this.animTimeMS = 500,
      this.minSliderRatio = -1.0});

  @override
  State<WorkToggler> createState() => _WorkToggler();
}

class _WorkToggler extends State<WorkToggler>
    with SingleTickerProviderStateMixin {
  double _ratio;
  double _tempRatio;
  _WorkTogglerState _state;
  Alignment _alignment = Alignment.topLeft;
  late Animation<double> _animation;
  late AnimationController _controller;

  _WorkToggler()
      : _ratio = 0.0,
        _tempRatio = 0.0,
        _state = _WorkTogglerState.slideLR;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.animTimeMS), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          if (_controller.status == AnimationStatus.completed) {
            if (_state == _WorkTogglerState.contractLR ||
                _state == _WorkTogglerState.retractRL) {
              _state = _WorkTogglerState.slideRL;
            } else if (_state == _WorkTogglerState.contractRL ||
                _state == _WorkTogglerState.retractLR) {
              _state = _WorkTogglerState.slideLR;
            }
            _controller.reset();
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _c(Color color1, Color color2, double ratio) {
    int r1 = color1.red;
    int g1 = color1.green;
    int b1 = color1.blue;

    int r2 = color2.red;
    int g2 = color2.green;
    int b2 = color2.blue;

    double s = 4;
    double val = 1 - (exp(s * ratio) - 1) * (1 / (exp(s) - 1));
    return Color.fromARGB(
        255,
        (val * r1 + (1 - val) * r2).round(),
        (val * g1 + (1 - val) * g2).round(),
        (val * b1 + (1 - val) * b2).round());
  }

  double _f(double maxVal, double x, double slope, double minRatio) {
    return maxVal -
        exp(slope * (x + (log(maxVal - minRatio) / (slope)))) -
        minRatio;
  }

  bool _checkValidForInteraction() {
    return _state == _WorkTogglerState.slideLR ||
        _state == _WorkTogglerState.slideRL;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double minRatio = 0.0;
        if (widget.minSliderRatio < 0) {
          minRatio = 1 / constraints.maxWidth * constraints.maxHeight;
        } else {
          minRatio = widget.minSliderRatio;
        }

        if (_state == _WorkTogglerState.slideLR && _ratio < minRatio) {
          _ratio = minRatio;
        } else if (_state == _WorkTogglerState.contractLR ||
            _state == _WorkTogglerState.contractRL) {
          _ratio = 1.0 - _f(1.0, _animation.value, -6, minRatio);
        } else if (_state == _WorkTogglerState.retractLR ||
            _state == _WorkTogglerState.retractRL) {
          _ratio = _tempRatio - _f(_tempRatio, _animation.value, -6, minRatio);
        }

        return GestureDetector(
          child: FractionallySizedBox(
            alignment: _alignment,
            widthFactor: _ratio,
            heightFactor: 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: _c(widget.restingColor, widget.activatedColor, _ratio),
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
          onTapDown: (TapDownDetails details) {
            if (!_checkValidForInteraction()) return;
            _controller.reset();
          },
          onPanEnd: (details) {
            if (!_checkValidForInteraction()) return;
            if (_ratio >= 1.0) {
              if (_state == _WorkTogglerState.slideLR) {
                _alignment = Alignment.topRight;
                _controller.forward();
                _state = _WorkTogglerState.contractLR;
                widget.onHitR();
              } else if (_state == _WorkTogglerState.slideRL) {
                _alignment = Alignment.topLeft;
                _controller.forward();
                _state = _WorkTogglerState.contractRL;
                widget.onHitL();
              }
            } else {
              if (_state == _WorkTogglerState.slideLR) {
                _controller.forward();
                _tempRatio = _ratio;
                _state = _WorkTogglerState.retractLR;
              } else if (_state == _WorkTogglerState.slideRL) {
                _controller.forward();
                _tempRatio = _ratio;
                _state = _WorkTogglerState.retractRL;
              }
            }
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (!_checkValidForInteraction()) {
              return;
            }
            setState(() {
              double size = constraints.maxWidth;
              double dd = details.localPosition.dx;

              if (_state == _WorkTogglerState.slideLR) {
                _ratio = 1 / size * dd;
              } else if (_state == _WorkTogglerState.slideRL) {
                _ratio = 1 - 1 / size * dd;
              }

              if (_ratio > 1.0) {
                _ratio = 1.0;
              } else if (_ratio < 0.0) {
                _ratio = 0.0;
              }
            });
          },
        );
      },
    );
  }
}
