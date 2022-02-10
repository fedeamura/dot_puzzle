import 'dart:developer';

import 'package:dot_puzzle/model/puzzle.dart';
import 'package:flutter/material.dart';

class PuzzleDotsPainter extends CustomPainter {
  final PuzzleModel puzzle;
  final Map<int, Color> colors;
  final Map<int, Offset> positions;
  final Map<int, double> opacities;

  PuzzleDotsPainter({
    required this.puzzle,
    required this.colors,
    required this.positions,
    required this.opacities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = (1 / (puzzle.innerDots * puzzle.size)) * 0.5;

    for (var dot in puzzle.dots) {
      final index = dot.globalCorrectTile.index;

      final pos = positions[index];
      final color = colors[index];
      final opacity = opacities[index] ?? 1.0;
      if (pos == null || color == null || color == Colors.transparent) {
        continue;
      }

      canvas.drawCircle(
        Offset(pos.dx * size.width, pos.dy * size.height),
        radius * size.shortestSide,
        Paint()..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PuzzleDotsPainter oldDelegate) {
    return oldDelegate.puzzle != puzzle || colors != oldDelegate.colors || positions != oldDelegate.positions || opacities != oldDelegate.opacities;
  }
}
