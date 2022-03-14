import 'package:dot_puzzle/core/list.dart';
import 'package:flutter/material.dart';

class AnimatedDotDigitPainter extends CustomPainter {
  final Map<int, Offset> positions;
  final int length;
  final Color color;

  AnimatedDotDigitPainter({
    required this.color,
    required this.positions,
    required this.length,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = ((1 / length) * 0.5) * size.shortestSide;

    for (int j = 0; j < length; j++) {
      for (int i = 0; i < length; i++) {
        final index = ListUtils.getIndex(i, j, length);
        final position = positions[index];
        if (position == null) continue;

        canvas.drawCircle(
          Offset(
            (position.dx * size.width) + radius,
            (position.dy * size.height) + radius,
          ),
          radius,
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedDotDigitPainter oldDelegate) {
    if (oldDelegate.positions != positions) return true;
    if (oldDelegate.length != length) return true;
    if (oldDelegate.color != color) return true;
    return false;
  }
}
