import 'package:flutter/material.dart';
import 'dart:math' as math show sin, pi;

//https://github.com/jogboms/flutter_spinkit/
class ScaleYWidget extends AnimatedWidget {
  const ScaleYWidget({
    Key? key,
    required Animation<double> scaleY,
    required this.child,
    this.alignment = Alignment.bottomCenter,
  }) : super(key: key, listenable: scaleY);

  final Widget child;
  final Alignment alignment;

  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(transform: Matrix4.identity()..scale(1.0, scale.value, 1.0), alignment: alignment, child: child);
  }
}

class DelayTween extends Tween<double> {
  DelayTween({double? begin, double? end, required this.delay}) : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) => super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
