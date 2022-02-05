import 'package:dot_puzzle/model/tile.dart';
import 'package:flutter/material.dart';

class PuzzleDotModel {
  double positionX;
  double positionY;
  int currentTileX;
  int currentTileY;
  Color color;
  Color incorrectColor;
  Color correctColor;
  Color? imageColor;
  Color? numberColor;
  double opacity;
  int diagonalLine;

  final int correctTileX;
  final int correctTileY;
  final int subX;
  final int subY;

  PuzzleDotModel({
    this.opacity = 1.0,
    required this.color,
    required this.incorrectColor,
    required this.correctColor,
    required this.numberColor,
    this.imageColor,
    required this.positionX,
    required this.positionY,
    required this.currentTileX,
    required this.currentTileY,
    required this.correctTileX,
    required this.correctTileY,
    required this.subX,
    required this.subY,
    required this.diagonalLine,
  });

  int gerCurrentTileIndex(int size) => currentTileX + (currentTileY * size);

  int getCorrectTileIndex(int size) => correctTileX + (correctTileY * size);

  Offset getCorrectPosition(int size, int innerPoints) {
    final pos = Offset(correctTileX / size, correctTileY / size);
    return Offset(
      pos.dx + (subX / (innerPoints * size)) + (1 / (innerPoints * size * 2)),
      pos.dy + (subY / (innerPoints * size)) + (1 / (innerPoints * size * 2)),
    );
  }

  Offset getCurrentPosition(int size, int innerPoints) {
    final pos = Offset(currentTileX / size, currentTileY / size);
    return Offset(
      pos.dx + (subX / (innerPoints * size)) + (1 / (innerPoints * size * 2)),
      pos.dy + (subY / (innerPoints * size)) + (1 / (innerPoints * size * 2)),
    );
  }

  bool get isNumber => numberColor != null;

  bool get isInCorrectPosition => correctTileX == currentTileX && correctTileY == currentTileY;

  int getCurrentX(int innerDots) => (currentTileX * innerDots) + subX;

  int getCurrentY(int innerDots) => (currentTileY * innerDots) + subY;

  int getCurrentIndex(int size, int innerDots) => getCurrentX(innerDots) + (getCurrentY(innerDots) * size);

  int getCorrectX(int innerDots) => (correctTileX * innerDots) + subX;

  int getCorrectY(int innerDots) => (correctTileY * innerDots) + subY;

  int getCorrectIndex(int size, int innerDots) => getCorrectX(innerDots) + (getCorrectY(innerDots) * size);

  TileModel getCurrentTile(int size) => TileModel(
        x: currentTileX,
        y: currentTileY,
        index: getCorrectTileIndex(size),
      );
}
