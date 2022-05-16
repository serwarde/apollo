import 'package:flutter/material.dart';

class CircleRotationWidget extends StatefulWidget {
  final Duration? duration;
  final Widget? center;
  final Curve? curve;
  final Widget child;
  final double radius;

  const CircleRotationWidget({
    Key? key,
    this.duration,
    this.center,
    this.curve,
    required this.child,
    required this.radius,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CircleRotationWidget();

}

class _CircleRotationWidget extends State<CircleRotationWidget> with SingleTickerProviderStateMixin{
  final Duration _defaultDuration = const Duration(seconds: 5);
  final Curve _defaultCurve = Curves.linear;
  late final AnimationController _controller;
  late final Animation<double> _forward;
  late final Animation<double> _backward;

  Duration get _duration => widget.duration ?? _defaultDuration;
  Curve get _curve => widget.curve ?? _defaultCurve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    )..repeat(
      period: _duration,
    );
    _forward = CurvedAnimation(parent: _controller, curve: _curve);
    _backward = Tween<double>(begin: 0.0, end: -1.0).animate(_forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _forward,
    child: Stack(
      children: [
        if(widget.center != null)
          Align(
            alignment: Alignment.center,
            child: RotationTransition(
              turns: _backward,
              child: widget.center,
            ),
          ),
        Align(
          alignment: Alignment.center,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(widget.radius, widget.radius, 0),
            child: RotationTransition(
              turns: _backward,
              child: widget.child,
            ),
          ),
        ),
      ],
    ),
  );
}