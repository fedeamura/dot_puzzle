import 'package:dot_puzzle/model/point.dart';
import 'package:flutter/material.dart';

class DotPainter extends CustomPainter {
  final List<PuzzlePoint> points;
  late Paint paintDark;
  late Paint paintEven;
  late Paint paintNumber;

  DotPainter({
    required this.points,
  }) {
    paintDark = Paint()..color = Colors.grey.shade300;
    paintEven = Paint()..color = Colors.grey.shade200;
    paintNumber = Paint()..color = Colors.red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var point in points) {
      final x = point.animationPosition?.value.dx ?? 0.0;
      final y = point.animationPosition?.value.dy ?? 0.0;
      final radius = (1 / (point.puzzle.innerPoints * point.puzzle.size)) * 0.5;

      if (point.isBlank) continue;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        radius * size.shortestSide,
        point.isNumber ? paintNumber : (point.isDark ? paintDark : paintEven),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DotPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class DotPainterModel {
  final Offset position;
  final Color color;
  final double radius;

  DotPainterModel({
    required this.position,
    required this.color,
    required this.radius,
  });
}
