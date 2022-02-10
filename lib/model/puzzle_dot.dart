import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/model/position.dart';
import 'package:dot_puzzle/model/tile.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PuzzleDotModel extends Equatable {
  final int _size;
  final int _innerDots;
  final TileModel currentTile;
  final TileModel correctTile;
  final TileModel subTile;
  final TileModel globalCurrentTile;
  final TileModel globalCorrectTile;
  final PositionModel correctPosition;
  final PositionModel currentPosition;
  final bool isInCorrectPosition;
  final bool isNumber;

  final Color imageColor;
  final Color incorrectColor;
  final Color correctColor;
  final Color numberColor;

  PuzzleDotModel({
    required int size,
    required int innerDots,
    required this.incorrectColor,
    required this.correctColor,
    required this.numberColor,
    required this.imageColor,
    required this.currentTile,
    required this.correctTile,
    required this.subTile,
  })  : _size = size,
        _innerDots = innerDots,
        isInCorrectPosition = currentTile.index == correctTile.index,
        isNumber = numberColor != Colors.transparent,
        globalCurrentTile = TileModel(
          size: size * innerDots,
          index: ListUtils.getIndex(
            (currentTile.x * innerDots) + subTile.x,
            (currentTile.y * innerDots) + subTile.y,
            size * innerDots,
          ),
        ),
        globalCorrectTile = TileModel(
          size: size * innerDots,
          index: ListUtils.getIndex(
            (correctTile.x * innerDots) + subTile.x,
            (correctTile.y * innerDots) + subTile.y,
            size * innerDots,
          ),
        ),
        correctPosition = PositionModel(
          x: (correctTile.x / size) + (subTile.x / (innerDots * size)) + (1 / (innerDots * size * 2)),
          y: (correctTile.y / size) + (subTile.y / (innerDots * size)) + (1 / (innerDots * size * 2)),
        ),
        currentPosition = PositionModel(
          x: (currentTile.x / size) + (subTile.x / (innerDots * size)) + (1 / (innerDots * size * 2)),
          y: (currentTile.y / size) + (subTile.y / (innerDots * size)) + (1 / (innerDots * size * 2)),
        );

  PuzzleDotModel copyWith({
    int? currentTileIndex,
    Color? correctColor,
    Color? imageColor,
  }) =>
      PuzzleDotModel(
        size: _size,
        innerDots: _innerDots,
        correctTile: correctTile,
        currentTile: currentTile.copyWith(index: currentTileIndex ?? currentTile.index),
        subTile: subTile,
        incorrectColor: incorrectColor,
        correctColor: correctColor ?? this.correctColor,
        numberColor: numberColor,
        imageColor: imageColor ?? this.imageColor,
      );

  @override
  List<Object?> get props => [
        imageColor,
        incorrectColor,
        correctColor,
        numberColor,
      ];
}
