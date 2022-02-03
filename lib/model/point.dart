import 'package:dot_puzzle/model/puzzle.dart';
import 'package:flutter/material.dart';

class PuzzlePoint {
  int currentX;
  int currentY;
  Animation<Offset>? animationPosition;
  final int correctX;
  final int correctY;
  final int subX;
  final int subY;
  final Puzzle puzzle;
  final bool isBlank;
  final bool isNumber;

  PuzzlePoint({
    required this.puzzle,
    required this.currentX,
    required this.currentY,
    required this.correctX,
    required this.correctY,
    required this.subX,
    required this.subY,
    required this.isBlank,
    required this.isNumber,
    this.animationPosition,
  });

  updateCurrentPosition({required int currentX, required int currentY}) {
    this.currentX = currentX;
    this.currentY = currentY;
  }

  updateAnimationPosition(Animation<Offset> animationPosition) {
    this.animationPosition = animationPosition;
  }

  String get id => "($correctX,$correctY)_($subX,$subY)";

  int get currentIndex => currentX + (currentY * puzzle.size);

  int get correctIndex => correctX + (correctY * puzzle.size);

  int get subIndex => subX + (subY * puzzle.innerPoints);
  int get subIndex2 => subY + (subX * puzzle.innerPoints);

  bool get isDark {
    bool drawBlack;

    if (correctX % 2 == 0) {
      drawBlack = correctY % 2 == 0;
    } else {
      drawBlack = correctY % 2 != 0;
    }
    return drawBlack;
  }
}
