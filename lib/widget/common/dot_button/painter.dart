import 'package:dot_puzzle/core/list.dart';
import 'package:flutter/material.dart';

class DotButtonPainter extends CustomPainter {
  final Color color;
  final int length;
  final Map<int, Offset> positions;
  final Map<int, double> opacities;

  DotButtonPainter({
    required this.length,
    required this.color,
    required this.positions,
    required this.opacities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = ((1 / length) * 0.5) * size.width;

    if (color == Colors.transparent) return;

    for (int j = 0; j < length; j++) {
      for (int i = 0; i < length; i++) {
        final index = ListUtils.getIndex(i, j, length);
        final pos = positions[index];
        if (pos == null) continue;

        final opacity = opacities[index];

        canvas.drawCircle(
          Offset(
            (pos.dx * size.width) + radius,
            (pos.dy * size.height) + radius,
          ),
          radius,
          Paint()..color = color.withOpacity(opacity ?? 1.0),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotButtonPainter oldDelegate) {
    if (color != oldDelegate.color) return true;
    if (length != oldDelegate.length) return true;
    if (positions != oldDelegate.positions) return true;
    if (opacities != oldDelegate.opacities) return true;

    return false;
  }
}
