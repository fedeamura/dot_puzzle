
import 'package:dot_puzzle/core/list.dart';
import 'package:flutter/material.dart';

class AnimatedPixelDigitPainter extends CustomPainter {
  final Map<int, Offset> positions;
  final Map<int, Color> colors;
  final int size;

  AnimatedPixelDigitPainter({
    required this.colors,
    required this.positions,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size _size) {
    double radius = ((1 / size) * 0.5) * _size.shortestSide;

    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        final index = ListUtils.getIndex(i, j, size);
        final color = colors[index];
        final position = positions[index];
        if (color == null || color == Colors.transparent) continue;
        if (position == null) continue;

        canvas.drawCircle(
          Offset(
            (position.dx * _size.width) + radius,
            (position.dy * _size.height) + radius,
          ),
          radius,
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedPixelDigitPainter oldDelegate) {
    return true;
  }
}
