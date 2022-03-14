import 'dart:convert';

import 'package:dot_puzzle/core/color.dart';
import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/model/position.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/model/tile.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/service/puzzle/model/move_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/move_direction.dart';

class PuzzleServiceImpl extends PuzzleService {
  final _numbersValues = <int, Map<int, Color>>{};
  var _imageYellow = <int, Color>{};

  final int _innerDots = 19;
  final int _size = 4;

  @override
  Future<void> init() async {
    await _initNumbers();
    _imageYellow = await _initImage("yellow");
  }

  _initNumbers() async {
    final data = await rootBundle.loadString("assets/numbers.json");
    final json = jsonDecode(data);

    final colors = (json["colors"] as List).map((e) => ColorUtils.fromHexString(e.toString())).where((e) => e != null).map((e) => e!).toList();

    Color? _parseColor(dynamic value) {
      try {
        return colors[int.parse(value)];
      } catch (error) {
        return null;
      }
    }

    PositionModel<int>? _parsePoint(dynamic val1, dynamic val2) {
      try {
        return PositionModel<int>(x: int.parse(val1), y: int.parse(val2));
      } catch (error) {
        return null;
      }
    }

    final val = json["numbers"] as Map<String, dynamic>;
    for (var entry in val.entries) {
      int? number = int.tryParse(entry.key);
      if (number == null) continue;

      final representation = entry.value.toString();
      final items = representation.split(";");
      final result = <int, Color>{};
      for (var item in items) {
        final itemParts = item.split(",");
        if (itemParts.length != 3) continue;

        final point = _parsePoint(itemParts[0], itemParts[1]);
        if (point == null) continue;
        final pointIndex = ListUtils.getIndex(point.x, point.y, _innerDots);

        final color = _parseColor(itemParts[2]);
        if (color == null) continue;

        result[pointIndex] = color;
      }

      _numbersValues[number] = result;
    }
  }

  Future<Map<int, Color>> _initImage(String name) async {
    final data = await rootBundle.loadString("assets/images.json");
    final json = jsonDecode(data);

    final points = (json[name] as String).split(";");
    final result = <int, Color>{};
    for (var item in points) {
      try {
        final parts = item.split(",");
        final point = PositionModel<int>(x: int.parse(parts[0]), y: int.parse(parts[1]));
        final index = ListUtils.getIndex(point.x, point.y, _size * _innerDots);
        final color = ColorUtils.fromHexString(parts[2])!;
        result[index] = color;
      } catch (error) {
        // log("Error parsing point");
      }
    }

    return result;
  }

  @override
  PuzzleModel create() {
    final totalLines = _innerDots * _size;
    var dots = <PuzzleDotModel>[];
    var availablePositions = List.generate(_size * _size, (index) => index);

    // Create the dots
    for (int j = 0; j < _size; j++) {
      for (int i = 0; i < _size; i++) {
        final correctTileIndex = ListUtils.getIndex(i, j, _size);
        if (correctTileIndex == (_size * _size) - 1) {
          continue;
        }

        final currentTileIndex = availablePositions.removeRandom();
        if (currentTileIndex == null) continue;

        for (int subJ = 0; subJ < _innerDots; subJ++) {
          for (int subI = 0; subI < _innerDots; subI++) {
            final subIndex = ListUtils.getIndex(subI, subJ, _innerDots);
            final color = Colors.grey.shade800;
            final numberColor = _numbersValues[correctTileIndex + 1]?[subIndex];

            final dot = PuzzleDotModel(
              incorrectColor: color,
              correctColor: color,
              numberColor: numberColor ?? Colors.transparent,
              imageColor: Colors.transparent,
              correctTile: TileModel(size: _size, index: correctTileIndex),
              currentTile: TileModel(size: _size, index: currentTileIndex),
              subTile: TileModel(size: _innerDots, index: subIndex),
              size: _size,
              innerDots: _innerDots,
            );

            dots.add(dot);
          }
        }
      }
    }

    // Correct colors (RAINBOW)
    int counter = 0;
    final diagonalLines = (totalLines + totalLines) - 1;

    final newDots = <int, PuzzleDotModel>{};
    for (int k = 0; k < totalLines * 2; k++) {
      for (int j = 0; j <= k; j++) {
        int i = k - j;
        if (i < totalLines && j < totalLines) {
          final percentage = counter / diagonalLines;
          final c = HSVColor.fromAHSV(1.0, (percentage * 360) % 360, 1.0, 1.0).toColor();
          final index = ListUtils.getIndex(i, j, _size * _innerDots);
          final dotsInLine = dots.where((e) => e.globalCorrectTile.index == index).toList();

          for (var dot in dotsInLine) {
            final index = dot.globalCorrectTile.index;
            newDots[index] = dot.copyWith(correctColor: c);
          }
        }
      }
      counter++;
    }

    dots = dots.map((dot) {
      final index = dot.globalCorrectTile.index;
      return newDots[index] ?? dot;
    }).toList();

    return PuzzleModel(
      dots: dots,
      size: _size,
      innerDots: _innerDots,
      imageMode: false,
      moves: 0,
    );
  }

  @override
  PuzzleModel reset(PuzzleModel model) {
    final size = model.size;
    var availablePositions = List.generate(size * size, (index) => index);

    final dots = <int, List<PuzzleDotModel>>{};
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        final index = ListUtils.getIndex(i, j, size);
        dots[index] = model.getDots(i, j);
      }
    }

    final newDots = <PuzzleDotModel>[];
    for (int j = size - 1; j >= 0; j--) {
      for (int i = size - 1; i >= 0; i--) {
        final index = ListUtils.getIndex(i, j, size);
        final currentPosition = availablePositions.removeRandom();
        if (currentPosition == null) continue;

        final editedDots = dots[index]?.map((e) => e.copyWith(currentTileIndex: currentPosition)).toList() ?? [];
        newDots.addAll(editedDots);
      }
    }

    return model.copyWith(
      moves: 0,
      dots: newDots,
    );
  }

  @override
  PuzzleModel sort(PuzzleModel model) {
    final size = model.size;

    final dots = <int, List<PuzzleDotModel>>{};
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        final index = ListUtils.getIndex(i, j, size);
        dots[index] = model.getDots(i, j);
      }
    }

    final newDots = <PuzzleDotModel>[];
    for (int j = size - 1; j >= 0; j--) {
      for (int i = size - 1; i >= 0; i--) {
        final index = ListUtils.getIndex(i, j, size);
        final editedDots = dots[index]?.map((e) => e.copyWith(currentTileIndex: e.correctTile.index)).toList() ?? [];
        newDots.addAll(editedDots);
      }
    }

    return model.copyWith(dots: newDots);
  }

  @override
  PuzzleModel convertToImage(PuzzleModel model) {
    final dots = model.dots.map((dot) {
      final index = dot.globalCorrectTile.index;
      final color = _imageYellow[index] ?? Colors.grey.shade800;
      return dot.copyWith(imageColor: color);
    }).toList();

    return model.copyWith(
      dots: dots,
      imageMode: true,
    );
  }

  @override
  PuzzleModel convertToNumbers(PuzzleModel model) {
    return model.copyWith(imageMode: false);
  }

  @override
  Map<int, Color> getNumberRepresentation(int number) {
    return _numbersValues[number] ?? <int, Color>{};
  }

  @override
  PuzzleMoveResult move(PuzzleModel model, int x, int y) {
    final whiteTilePosition = model.whiteTilePosition;

    if (whiteTilePosition == null || !model.canMove(x, y)) {
      return PuzzleMoveResult(model: model);
    }

    final touchTilePosition = PositionModel<int>(x: x, y: y);
    bool horizontalReorder = whiteTilePosition.y == touchTilePosition.y;
    bool reverse = false;
    PuzzleMoveDirection moveDirection;
    int deltaX;
    int deltaY;
    List<PuzzleDotModel> movedDots;

    if (horizontalReorder) {
      int from, to;
      if (whiteTilePosition.x < touchTilePosition.x) {
        moveDirection = PuzzleMoveDirection.left;
        reverse = true;
        from = whiteTilePosition.x + 1;
        to = touchTilePosition.x;
      } else {
        moveDirection = PuzzleMoveDirection.right;
        from = touchTilePosition.x;
        to = whiteTilePosition.x - 1;
      }
      movedDots = model.dots.where((e) => e.currentTile.y == whiteTilePosition.y && e.currentTile.x >= from && e.currentTile.x <= to).toList();
    } else {
      int from, to;
      if (whiteTilePosition.y < touchTilePosition.y) {
        reverse = true;
        moveDirection = PuzzleMoveDirection.up;
        from = whiteTilePosition.y + 1;
        to = touchTilePosition.y;
      } else {
        moveDirection = PuzzleMoveDirection.down;
        from = touchTilePosition.y;
        to = whiteTilePosition.y - 1;
      }
      movedDots = model.dots.where((e) => e.currentTile.x == whiteTilePosition.x && e.currentTile.y >= from && e.currentTile.y <= to).toList();
    }

    deltaX = (!horizontalReorder ? 0 : (reverse ? -1 : 1));
    deltaY = (horizontalReorder ? 0 : (reverse ? -1 : 1));

    final editedDots = <int, PuzzleDotModel>{};
    final newCorrectDots = <PuzzleDotModel>[];
    final newIncorrectDots = <PuzzleDotModel>[];

    for (var dot in movedDots) {
      final index = dot.globalCorrectTile.index;

      int currentTileX = dot.currentTile.x + deltaX;
      int currentTileY = dot.currentTile.y + deltaY;
      int newTileIndex = ListUtils.getIndex(currentTileX, currentTileY, model.size);

      final editedDot = dot.copyWith(currentTileIndex: newTileIndex);
      if (dot.isInCorrectPosition != editedDot.isInCorrectPosition) {
        if (editedDot.isInCorrectPosition) {
          newCorrectDots.add(editedDot);
        } else {
          newIncorrectDots.add(editedDot);
        }
      }
      editedDots[index] = editedDot;
    }

    return PuzzleMoveResult(
      model: model.copyWith(
        dots: model.dots.map((dot) {
          final index = dot.globalCorrectTile.index;
          return editedDots[index] ?? dot;
        }).toList(),
        moves: model.moves + 1,
      ),
      moveDirection: moveDirection,
      movedDots: movedDots,
      newCorrectDots: newCorrectDots,
      newIncorrectDots: newIncorrectDots,
    );
  }
}
