import 'dart:convert';

import 'package:dot_puzzle/core/color.dart';
import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/model/position.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/model/tile.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // @override
  // PuzzleModel updateDotsColor(PuzzleModel model, List<PuzzleDotModel> dots, {Color? color, double t = 1.0}) {
  //   final editedDots = <String, PuzzleDotModel>{};
  //   for (var dot in dots) {
  //     Color newColor;
  //     if (color != null) {
  //       newColor = color;
  //     } else {
  //       if (model.imageMode) {
  //         newColor = dot.imageColor;
  //       } else {
  //         if (dot.isNumber) {
  //           newColor = dot.numberColor;
  //         } else {
  //           if (dot.isInCorrectPosition) {
  //             newColor = dot.correctColor;
  //           } else {
  //             newColor = dot.incorrectColor;
  //           }
  //         }
  //       }
  //     }
  //     editedDots[dot.id] = dot.copyWith(
  //       color: Color.lerp(dot.color, newColor, Curves.decelerate.transform(t)),
  //     );
  //   }
  //
  //   return model.copyWith(
  //     dots: model.dots.map((e) => editedDots[e.id] ?? e).toList(),
  //   );
  // }
  //
  // @override
  // PuzzleModel updateDotsPosition(
  //   PuzzleModel model, {
  //   Offset? focusPosition,
  //   double t = 1.0,
  // }) {
  //   double delta = 1.5;
  //   double f = 0.05;
  //   double shimmer = 0.3;
  //
  //   for (var dot in model.dots) {
  //     final currentPosition = Offset(dot.positionX, dot.positionY);
  //     final correctPosition = dot.getCurrentPosition(model.size, model.innerDots);
  //     Offset newPosition = correctPosition;
  //
  //     double opacity = 1.0;
  //     if (focusPosition != null) {
  //       final distance = (focusPosition - currentPosition).distance;
  //       if (distance < delta) {
  //         final distancePercentage = distance / delta;
  //         final force = f * (1 - (distancePercentage));
  //         final x = correctPosition.dx - focusPosition.dx;
  //         final y = correctPosition.dy - focusPosition.dy;
  //         final angle = math.atan(y / x) - (correctPosition.dx < focusPosition.dx ? math.pi : 0.0);
  //         newPosition = correctPosition + Offset(math.cos(angle) * force, math.sin(angle) * force);
  //
  //         if (distancePercentage < shimmer) {
  //           opacity = Curves.easeInOut.transform(MathUtils.map(distancePercentage, 0, shimmer, 0.0, 1.0));
  //         }
  //       }
  //     }
  //
  //     dot.positionX = lerpDouble(currentPosition.dx, newPosition.dx, Curves.decelerate.transform(t))!;
  //     dot.positionY = lerpDouble(currentPosition.dy, newPosition.dy, Curves.decelerate.transform(t))!;
  //     dot.opacity = lerpDouble(dot.opacity, opacity, Curves.decelerate.transform(t))!;
  //   }
  // }

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
}
