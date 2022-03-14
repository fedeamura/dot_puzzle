import 'dart:ui';

import 'package:dot_puzzle/model/puzzle.dart';
import 'package:flutter/material.dart';

import 'index.dart';

class PuzzleDotsPainter extends CustomPainter {
  final PuzzleModel puzzle;
  final Map<int, DotData> dotData;

  PuzzleDotsPainter({
    required this.puzzle,
    required this.dotData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dotSize = (1 / (puzzle.innerDots * puzzle.size));

    final points = <Color, List<Offset>>{};
    for (var dot in puzzle.dots) {
      final index = dot.globalCorrectTile.index;
      final data = dotData[index];

      final pos = data?.position;
      final color = data?.color;
      final opacity = data?.opacity ?? 1.0;
      if (pos == null || color == null || color == Colors.transparent || opacity == 0.0) {
        continue;
      }

      final c = color.withOpacity(opacity);
      final dots = points[c] ?? <Offset>[];
      dots.add(Offset(pos.dx * size.width, pos.dy * size.height));
      points[c] = dots;
    }

    points.forEach((key, value) {
      canvas.drawPoints(
        PointMode.points,
        value,
        Paint()
          ..color = key
          ..style = PaintingStyle.stroke
          ..strokeWidth = dotSize * size.shortestSide * 0.8,
      );
    });
  }

  @override
  bool shouldRepaint(covariant PuzzleDotsPainter oldDelegate) {
    if (oldDelegate.puzzle != puzzle) return true;
    if (oldDelegate.dotData != dotData) return true;
    return false;
  }
}
