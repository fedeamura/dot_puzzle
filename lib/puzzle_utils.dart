import 'dart:math' as m;

import 'package:dot_puzzle/model/point.dart';
import 'package:flutter/material.dart';

import 'model/puzzle.dart';

class PuzzleUtils {
  static Puzzle create() {
    final puzzle = Puzzle(points: [], size: 4, innerPoints: 9);

    final points = <PuzzlePoint>[];
    for (int j = 0; j < puzzle.size; j++) {
      for (int i = 0; i < puzzle.size; i++) {
        final index = i + (j * puzzle.size);
        final isBlank = index == puzzle.size * puzzle.size - 1;

        for (int _j = 0; _j < puzzle.innerPoints; _j++) {
          for (int _i = 0; _i < puzzle.innerPoints; _i++) {
            final point = PuzzlePoint(
              puzzle: puzzle,
              currentX: i,
              currentY: j,
              correctX: i,
              correctY: j,
              subX: _i,
              subY: _j,
              isBlank: isBlank,
              isNumber: PuzzleUtils.isNumber(index + 1, _j, _i),
            );
            points.add(point);
          }
        }
      }
    }
    puzzle.updatePoints(points);
    return puzzle;
  }

  static getNumber(
    int number, {
    m.Point<int> offset = const m.Point<int>(0, 0),
  }) {
    final p = <m.Point<int>>[];

    switch (number) {
      case 0:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(0, 3));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;
      case 1:
        {
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(1, 1));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(1, 3));
          p.add(const m.Point<int>(1, 4));
        }
        break;

      case 2:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(0, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;

      case 3:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;

      case 4:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(2, 4));
        }
        break;

      case 5:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;

      case 6:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(0, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;

      case 7:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(1, 3));
          p.add(const m.Point<int>(1, 4));
        }
        break;

      case 8:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(0, 3));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;

      case 9:
        {
          p.add(const m.Point<int>(0, 0));
          p.add(const m.Point<int>(1, 0));
          p.add(const m.Point<int>(2, 0));
          p.add(const m.Point<int>(0, 1));
          p.add(const m.Point<int>(2, 1));
          p.add(const m.Point<int>(0, 2));
          p.add(const m.Point<int>(1, 2));
          p.add(const m.Point<int>(2, 2));
          p.add(const m.Point<int>(2, 3));
          p.add(const m.Point<int>(0, 4));
          p.add(const m.Point<int>(1, 4));
          p.add(const m.Point<int>(2, 4));
        }
        break;
    }

    return p.map((e) {
      return e + offset;
    }).toList();
  }

  static bool isNumber(int number, int x, int y) {
    var p = <m.Point<int>>[];

    const pSingle = m.Point<int>(3, 2);
    const pDouble1 = m.Point<int>(1, 2);
    const pDouble2 = m.Point<int>(5, 2);

    switch (number) {
      case 1:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 2:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 3:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 4:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 5:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 6:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 7:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 8:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 9:
        {
          p = getNumber(number, offset: pSingle);
        }
        break;

      case 10:
        {
          p.addAll(getNumber(1, offset: pDouble1));
          p.addAll(getNumber(0, offset: pDouble2));
        }
        break;

      case 11:
        {
          p.addAll(getNumber(1, offset: pDouble1));
          p.addAll(getNumber(1, offset: pDouble2));
        }
        break;

      case 12:
        {
          p.addAll(getNumber(1, offset: pDouble1));
          p.addAll(getNumber(2, offset: pDouble2));
        }
        break;

      case 13:
        {
          p.addAll(getNumber(1, offset: pDouble1));
          p.addAll(getNumber(3, offset: pDouble2));
        }
        break;

      case 14:
        {
          p.addAll(getNumber(1, offset: pDouble1));
          p.addAll(getNumber(4, offset: pDouble2));
        }
        break;

      case 15:
        {
          p.addAll(getNumber(1, offset: pDouble1));
          p.addAll(getNumber(5, offset: pDouble2));
        }
        break;
    }

    return p.any((e) => e.x == x && e.y == y);
  }

  static Offset calculatePosition(PuzzlePoint point, {int? x, int? y}) => _calculatePosition(
        size: point.puzzle.size,
        innerPoints: point.puzzle.innerPoints,
        x: x ?? point.currentX,
        y: y ?? point.currentY,
        subY: point.subX,
        subX: point.subY,
      );

  static Offset _calculatePosition({
    required int size,
    required int innerPoints,
    required int x,
    required int y,
    required int subX,
    required int subY,
  }) {
    final pos = Offset(x / size, y / size);
    return Offset(
      pos.dx + (subX / (innerPoints * size)) + (1 / (innerPoints * size * 2)),
      pos.dy + (subY / (innerPoints * size)) + (1 / (innerPoints * size * 2)),
    );
  }
}
