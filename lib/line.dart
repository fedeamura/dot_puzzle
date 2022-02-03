import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v;

class LinePainter extends CustomPainter {
  final Offset point1;
  final Offset point2;

  LinePainter({
    required this.point1,
    required this.point2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotRadius = size.shortestSide * 0.005;

    final force = 0.1;
    final p1 = Offset(point1.dx * size.width, point1.dy * size.height);
    final p2 = Offset(point2.dx * size.width, point2.dy * size.height);
    final x = p1.dx - p2.dx;
    final y = p1.dy - p2.dy;

    canvas.drawCircle(
      p1,
      dotRadius * 2,
      Paint()..color = Colors.red,
    );
    canvas.drawCircle(
      p2,
      dotRadius,
      Paint()..color = Colors.red,
    );

    // Hipotenusa
    canvas.drawLine(p1, p2, Paint()..color = Colors.blue);

    // Cateto adyacente
    canvas.drawLine(p1, (Offset(p2.dx, p1.dy)), Paint()..color = Colors.blue);

    // Cateto opuesto
    canvas.drawLine(p2, (Offset(p2.dx, p1.dy)), Paint()..color = Colors.blue);

    final angle = math.atan(y / x) - (p2.dx < p1.dx ? math.pi : 0.0);
    log("Angle ${v.degrees(angle)}. Cos ${math.cos(angle)}");

    // P3
    final targetX = p2.dx + (math.cos(angle) * force * size.width);
    final targetY = p2.dy + (math.sin(angle) * force * size.height);
    final p3 = Offset(targetX, targetY);
    canvas.drawCircle(p3, dotRadius, Paint()..color = Colors.green);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return true;
  }
}
