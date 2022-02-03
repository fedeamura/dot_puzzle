import 'dart:math' as math;

import 'package:dot_puzzle/model/point.dart';

class Puzzle {
  List<PuzzlePoint> points;
  final int size;
  final int innerPoints;

  Puzzle({
    required this.points,
    required this.size,
    required this.innerPoints,
  });

  updatePoints(List<PuzzlePoint> points) {
    this.points = points;
  }

  math.Point<int> get blankPosition {
    final p = points.where((e) => e.subX == 0 && e.subY == 0 && e.isBlank).toList();
    return math.Point<int>(p[0].currentX, p[0].currentY);
  }
}
