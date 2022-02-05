import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ImageEditorPainter extends CustomPainter {
  final Map<math.Point<int>, Color> points;
  final int size;

  ImageEditorPainter({
    required this.points,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size _size) {
    double radius = (1 / size) * 0.5;

    points.forEach((key, value) {
      final pos = Offset(
        (key.x.toDouble() / size) * _size.width,
        (key.y.toDouble() / size) * _size.height,
      );

      canvas.drawCircle(
        pos,
        radius * _size.shortestSide,
        Paint()..color = value,
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
