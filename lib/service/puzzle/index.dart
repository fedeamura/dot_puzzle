import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:dot_puzzle/core/color.dart';
import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/core/math.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class PuzzleServiceImpl extends PuzzleService {
  final _numbersValues = <int, Map<math.Point<int>, Color>>{};
  var _imageYellow = <math.Point<int>, Color>{};
  final int _innerDots = 19;

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

    math.Point<int>? _parsePoint(dynamic val1, dynamic val2) {
      try {
        return math.Point<int>(int.parse(val1), int.parse(val2));
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
      final result = <math.Point<int>, Color>{};
      for (var item in items) {
        final itemParts = item.split(",");
        if (itemParts.length != 3) continue;

        final point = _parsePoint(itemParts[0], itemParts[1]);
        if (point == null) continue;

        final color = _parseColor(itemParts[2]);
        if (color == null) continue;

        result[point] = color;
      }

      _numbersValues[number] = result;
    }
  }

  Future<Map<math.Point<int>, Color>> _initImage(String name) async {
    final data = await rootBundle.loadString("assets/images.json");
    final json = jsonDecode(data);

    final points = (json[name] as String).split(";");
    final result = <math.Point<int>, Color>{};
    for (var item in points) {
      try {
        final parts = item.split(",");
        final point = math.Point<int>(int.parse(parts[0]), int.parse(parts[1]));
        final color = ColorUtils.fromHexString(parts[2])!;
        result[point] = color;
      } catch (error) {
        log("Error parsing point");
      }
    }

    return result;
  }

  @override
  PuzzleModel create({required int size}) {
    final totalLines = _innerDots * size;
    final dots = <PuzzleDotModel>[];
    var availablePositions = List.generate(size * size, (index) => index);

    // Create the dots
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        final index = ListUtils.getIndex(i, j, size);
        if (index == (size * size) - 1) continue;

        final currentPosition = availablePositions.removeRandom();
        if (currentPosition == null) continue;

        final currentX = ListUtils.getX(currentPosition, size);
        final currentY = ListUtils.getY(currentPosition, size);
        for (int subJ = 0; subJ < _innerDots; subJ++) {
          for (int subI = 0; subI < _innerDots; subI++) {
            final color = Colors.grey.shade400;
            final numberColor = _numbersValues[index + 1]?[math.Point<int>(subI, subJ)];

            final dot = PuzzleDotModel(
              color: color,
              incorrectColor: color,
              correctColor: color,
              numberColor: numberColor,
              currentTileX: currentX,
              currentTileY: currentY,
              positionX: 0.0,
              positionY: 0.0,
              correctTileX: i,
              correctTileY: j,
              subX: subI,
              subY: subJ,
              diagonalLine: 0,
            );
            final pos = dot.getCurrentPosition(size, _innerDots);
            dot.positionX = pos.dx;
            dot.positionY = pos.dy;
            dots.add(dot);
          }
        }
      }
    }

    // Correct colors (RAINBOW)
    int counter = 0;
    final diagonalLines = (totalLines + totalLines) - 1;

    for (int k = 0; k < totalLines * 2; k++) {
      for (int j = 0; j <= k; j++) {
        int i = k - j;
        if (i < totalLines && j < totalLines) {
          final percentage = counter / diagonalLines;
          final c = HSVColor.fromAHSV(1.0, (percentage * 360) % 360, 1.0, 1.0).toColor();

          final dotsInLine = dots
              .where((e) => !e.isNumber && ((e.correctTileX * _innerDots) + e.subX) == i && ((e.correctTileY * _innerDots) + e.subY) == j)
              .toList();
          for (var dot in dotsInLine) {
            dot.correctColor = c;
            dot.diagonalLine = counter;
          }
        }
      }
      counter++;
    }

    return PuzzleModel(
      dots: dots,
      size: size,
      innerDots: _innerDots,
      imageMode: false,
    );
  }

  @override
  void shuffle(PuzzleModel model) {
    final size = model.size;
    var availablePositions = List.generate(size * size, (index) => index);

    final dots = <math.Point<int>, List<PuzzleDotModel>>{};
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        dots[math.Point<int>(i, j)] = model.dots.where((e) => e.currentTileX == i && e.currentTileY == j).toList();
      }
    }

    for (int j = size - 1; j >= 0; j--) {
      for (int i = size - 1; i >= 0; i--) {
        final currentPosition = availablePositions.removeRandom();
        if (currentPosition == null) continue;

        final currentX = ListUtils.getX(currentPosition, size);
        final currentY = ListUtils.getY(currentPosition, size);

        dots[math.Point<int>(i, j)]?.forEach((dot) {
          dot.currentTileX = currentX;
          dot.currentTileY = currentY;
        });
      }
    }
  }

  @override
  void sort(PuzzleModel model) {
    final size = model.size;

    final dots = <math.Point<int>, List<PuzzleDotModel>>{};
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        dots[math.Point<int>(i, j)] = model.dots.where((e) => e.currentTileX == i && e.currentTileY == j).toList();
      }
    }

    for (int j = size - 1; j >= 0; j--) {
      for (int i = size - 1; i >= 0; i--) {
        dots[math.Point<int>(i, j)]?.forEach((dot) {
          dot.currentTileX = dot.correctTileX;
          dot.currentTileY = dot.correctTileY;
        });
      }
    }
  }

  @override
  void updateCorrectDotsColor(PuzzleModel model, List<PuzzleDotModel> dots, {double t = 1.0}) {
    for (var dot in dots) {
      if (model.imageMode) {
        dot.color = Color.lerp(dot.color, dot.imageColor ?? Colors.transparent, Curves.decelerate.transform(t))!;
      } else {
        if (dot.isNumber) {
          dot.color = Color.lerp(dot.color, dot.numberColor ?? Colors.transparent, Curves.decelerate.transform(t))!;
        } else {
          if (dot.isInCorrectPosition) {
            dot.color = Color.lerp(dot.color, dot.correctColor, Curves.decelerate.transform(t))!;
          } else {
            dot.color = Color.lerp(dot.color, dot.incorrectColor, Curves.decelerate.transform(t))!;
          }
        }
      }
    }
  }

  @override
  void updateDotsColor(PuzzleModel model, List<PuzzleDotModel> dots, {Color? color, double t = 1.0}) {
    for (var dot in dots) {
      dot.color = Color.lerp(dot.color, color ?? dot.color, Curves.decelerate.transform(t))!;
    }
  }

  @override
  void updateDotsPosition(
    PuzzleModel model, {
    Offset? focusPosition,
    double t = 1.0,
    bool pressed = false,
  }) {
    final factor = pressed ? 1.0 : 0.5;

    double delta = 1.5 * factor;
    double f = 0.05 * factor;
    double shimmer = 0.3 + factor;

    for (var dot in model.dots) {
      final currentPosition = Offset(dot.positionX, dot.positionY);
      final correctPosition = dot.getCurrentPosition(model.size, model.innerDots);
      Offset newPosition = correctPosition;

      double opacity = 1.0;
      if (focusPosition != null) {
        final distance = (focusPosition - currentPosition).distance;
        if (distance < delta) {
          final distancePercentage = distance / delta;
          final force = f * (1 - (distancePercentage));
          final x = correctPosition.dx - focusPosition.dx;
          final y = correctPosition.dy - focusPosition.dy;
          final angle = math.atan(y / x) - (correctPosition.dx < focusPosition.dx ? math.pi : 0.0);
          newPosition = correctPosition + Offset(math.cos(angle) * force, math.sin(angle) * force);

          if (distancePercentage < shimmer) {
            opacity = Curves.easeInOut.transform(MathUtils.map(distancePercentage, 0, shimmer, 0.0, 1.0));
          }
        }
      }

      dot.positionX = lerpDouble(currentPosition.dx, newPosition.dx, Curves.decelerate.transform(t))!;
      dot.positionY = lerpDouble(currentPosition.dy, newPosition.dy, Curves.decelerate.transform(t))!;
      dot.opacity = lerpDouble(dot.opacity, opacity, Curves.decelerate.transform(t))!;
    }
  }

  @override
  void convertToImage(PuzzleModel model) {
    model.imageMode = true;

    for (var dot in model.dots) {
      final x = (dot.correctTileX * model.innerDots) + dot.subX;
      final y = (dot.correctTileY * model.innerDots) + dot.subY;

      final color = _imageYellow[math.Point<int>(x, y)] ?? Colors.grey.shade400;
      dot.imageColor = color;
    }
  }

  @override
  void convertToNumbers(PuzzleModel model) {
    model.imageMode = false;
    // final size = model.size;
    // final innerDots = model.innerDots;
    // model.dots.sort((a, b) => a.getCurrentIndex(size, innerDots).compareTo(b.getCurrentIndex(size, innerDots)));
  }
}
