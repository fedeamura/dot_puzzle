import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'dart:math' as math;

class PuzzleModel {
  final List<PuzzleDotModel> dots;
  final int size;
  final int innerDots;
  bool imageMode;

  PuzzleModel({
    required this.dots,
    required this.size,
    required this.innerDots,
    required this.imageMode,
  });

  math.Point<int>? get whiteTilePosition {
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        if (!dots.any((e) => e.currentTileX == i && e.currentTileY == j)) {
          return math.Point<int>(i, j);
        }
      }
    }

    return null;
  }

  bool isInCorrectPosition(int x, int y) {
    return dots.any((e) => e.subX == 0 && e.subY == 0 && e.isInCorrectPosition);
  }

  bool canMove(int x, int y) {
    final touchTilePosition = math.Point<int>(x, y);
    final white = whiteTilePosition;
    if (white == null) return false;
    if (white == touchTilePosition) return false;
    return whiteTilePosition!.x == touchTilePosition.x || whiteTilePosition!.y == touchTilePosition.y;
  }

  List<PuzzleDotModel> getDots(int x, int y) {
    return dots.where((e) => e.currentTileX == x && e.currentTileY == y).toList();
  }

  bool get isCompleted {
    final firsts = dots.where((e) => e.subX == 0 && e.subY == 0);
    return !firsts.any((e) => !e.isInCorrectPosition);
  }
}
