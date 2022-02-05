import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:flutter/material.dart';

class PuzzleDotsPainter extends CustomPainter {
  final PuzzleModel puzzle;

  PuzzleDotsPainter({
    required this.puzzle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = (1 / (puzzle.innerDots * puzzle.size)) * 0.5;

    for (var dot in puzzle.dots) {

      canvas.drawCircle(
        Offset(
          dot.positionX * size.width,
          dot.positionY * size.height,
        ),
        radius * size.shortestSide,
        Paint()..color = dot.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PuzzleDotsPainter oldDelegate) {
    return oldDelegate.puzzle != puzzle;
  }
}
