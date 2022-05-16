import 'package:flutter/material.dart';

import 'package:awesome_poll_app/utils/animation_utils.dart';

class FancyLoadingWidget extends StatefulWidget {
  final int? pollBars;
  final double? barWidth;
  final double? barHeight;
  final double? barGapSpace;
  final Color? barColor;
  final Duration? duration;
  final double? minScale;
  final double? maxScale;
  final BoxDecoration? boxDecoration;

  const FancyLoadingWidget({
    Key? key,
    this.duration,
    this.boxDecoration,
    this.barWidth,
    this.barHeight,
    this.barColor,
    this.pollBars,
    this.minScale,
    this.maxScale,
    this.barGapSpace,
  })  : assert(pollBars != null && pollBars >= 0, "number of poll bars must be positive"),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _FancyLoadingWidget();
}

class _FancyLoadingWidget extends State<FancyLoadingWidget> with SingleTickerProviderStateMixin {
  final int _defaultPollBars = 4;
  final double _defaultWidth = 20;
  final double _defaultHeight = 30;
  final Duration _defaultDuration = const Duration(milliseconds: 1500);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    )..repeat(
      period: widget.duration ?? _defaultDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _curved() => CurvedAnimation(parent: _controller, curve: Curves.linear);

  Widget _buildSpacer() =>  SizedBox(width: widget.pollBars == 0 ? 2 * _gapSize : _gapSize);

  Widget _buildAnimatedWidget() => SizedBox(
    width: _barWidth,
    height: _barHeight,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: widget.barColor ?? Colors.red,
      ),
    ),
  );

  Iterable<Widget> _buildBars() sync* {
    for(int i = 0; i < _bars; i++) {
      yield ScaleYWidget(
        scaleY: DelayTween(begin: _minScale, end: _maxScale, delay: 1 / _bars * i).animate(_curved()),
        child: _buildAnimatedWidget(),
      );
      yield _buildSpacer();
    }
  }

  int get _bars => widget.pollBars ?? _defaultPollBars;

  double get _gapSize => widget.barGapSpace ?? 20;

  double get _minScale => widget.minScale ?? 0;

  double get _maxScale => widget.maxScale ?? 2;

  double get width => ((widget.barWidth ?? _defaultWidth) * _bars) + (2 * _gapSize) + ((_bars - 1) * _gapSize) + _bars;

  double get height => _barHeight * _maxScale;

  double get _barWidth => widget.barWidth ?? _defaultWidth;

  double get _barHeight => widget.barHeight ?? _defaultHeight;

  @override
  Widget build(BuildContext context) => Container(
    decoration: widget.boxDecoration,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: FractionalOffset.bottomLeft,
        width: width,
        height: height,
        child: Row(
          children: [
            _buildSpacer(),
            ..._buildBars(),
          ],
        ),
      ),
    ),
  );
}

class DefaultFancyLoadingWidget extends StatelessWidget {
  const DefaultFancyLoadingWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => FancyLoadingWidget(
    barColor: Theme.of(context).colorScheme.primary,
    pollBars: 3,
    barWidth: 28,
    barHeight: 50,
    barGapSpace: 18,
    boxDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        width: 2.0,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

}