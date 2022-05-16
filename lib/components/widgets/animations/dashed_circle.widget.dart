import 'dart:math';

import 'package:awesome_poll_app/utils/commons.dart';

class DashedCirclePainter extends CustomPainter {
  final Size? size;
  final int dashes;
  final Color color;
  final double gapSize;
  final double strokeWidth;

  DashedCirclePainter({
    this.size,
    this.dashes = 30,
    this.color = Colors.red,
    this.gapSize = 10,
    this.strokeWidth = 3,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final double gap = pi / 180 * gapSize;
    final double singleAngle = (pi * 2) / dashes;
    var path = Path();
    for (int i = 0; i < dashes; i++) {
      path.addArc(Offset.zero & (this.size ?? size), gap + singleAngle * i, singleAngle - gap * 2);
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return true; //TODO
  }

}