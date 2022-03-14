// ignore_for_file: invalid_use_of_protected_member

import 'dart:ui';

import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/model/tile.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/widget/common/puzzle/index.dart';
import 'package:dot_puzzle/widget/common/puzzle/painter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;

class AnimatedDotCountDown extends StatefulWidget {
  const AnimatedDotCountDown({Key? key}) : super(key: key);

  @override
  AnimatedDotCountDownState createState() => AnimatedDotCountDownState();
}

class AnimatedDotCountDownState extends State<AnimatedDotCountDown> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PuzzleModel _puzzle;
  var _dotData = <int, DotData>{};

  late int _count;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);

    final dots = <PuzzleDotModel>[];
    for (int j = 0; j < 19; j++) {
      for (int i = 0; i < 19; i++) {
        final subIndex = ListUtils.getIndex(i, j, 19);
        final dot = PuzzleDotModel(
          size: 1,
          innerDots: 19,
          incorrectColor: Colors.transparent,
          correctColor: Colors.transparent,
          numberColor: Colors.transparent,
          imageColor: Colors.transparent,
          currentTile: TileModel(size: 1, index: 0),
          correctTile: TileModel(size: 1, index: 0),
          subTile: TileModel(size: 19, index: subIndex),
        );

        final data = DotData(
          opacity: 0.0,
          position: Offset(dot.currentPosition.x, dot.currentPosition.y),
          color: Colors.transparent,
        );
        _dotData[dot.subTile.index] = data;
        dots.add(dot);
      }
    }

    _puzzle = PuzzleModel(
      dots: dots,
      size: 1,
      innerDots: 19,
      imageMode: false,
      moves: 0,
    );

    super.initState();
  }

  start(
    int count, {
    Function(int value)? onTick,
    Function()? onReady,
  }) async {
    _count = count;
    _wait(
      onTick: onTick,
      onReady: onReady,
    );
  }

  _wait({
    Function(int value)? onTick,
    Function()? onReady,
  }) async {
    _changeDigit(_count);
    await Future.delayed(const Duration(milliseconds: 100));
    await _enter(duration: const Duration(milliseconds: 200));

    await Future.delayed(const Duration(milliseconds: 500));
    onTick?.call(_count);

    if (!mounted) return;
    await _explode(duration: const Duration(milliseconds: 300));
    _count--;
    if (_count <= 0) {
      onReady?.call();
      return;
    }

    _wait(
      onTick: onTick,
      onReady: onReady,
    );
  }

  _changeDigit(int digit) {
    final PuzzleService service = GetIt.I.get();
    final number = service.getNumberRepresentation(digit);

    final dotData = Map<int, DotData>.from(_dotData);
    for (var dot in _puzzle.dots) {
      final index = dot.subTile.index;
      final data = dotData[index];
      if (data != null) {
        dotData[index] = data.copyWith(
          color: number[index] ?? Colors.transparent,
        );
      }
    }

    setState(() {
      _dotData = dotData;
    });
  }

  _enter({Duration duration = Duration.zero}) async {
    listener() {
      final t = _animationController.value;
      final dotData = Map<int, DotData>.from(_dotData);
      for (var dot in _puzzle.dots) {
        final index = dot.subTile.index;
        final data = dotData[index];
        final newPosition = Offset(dot.currentPosition.x, dot.currentPosition.y);
        if (data != null) {
          dotData[index] = data.copyWith(
            position: Offset.lerp(newPosition, newPosition, t)!,
            opacity: lerpDouble(0.0, t, t)!,
          );
        }
      }

      setState(() {
        _dotData = dotData;
      });
    }

    _animationController.stop();
    _animationController.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationController.duration = duration;
      _animationController.addListener(listener);
      await _animationController.forward(from: 0.0);
    }
  }

  _explode({Duration duration = Duration.zero}) async {
    listener() {
      var center = const Offset(0.5, 0.5);
      final t = _animationController.value;
      final dotData = Map<int, DotData>.from(_dotData);
      for (var dot in _puzzle.dots) {
        final index = dot.subTile.index;
        var data = dotData[index];
        final current = Offset(
          dot.currentPosition.x,
          dot.currentPosition.y,
        );

        final x = current.dx - center.dx;
        final y = current.dy - center.dy;
        final angle = math.atan(y / x) - (current.dx < center.dx ? math.pi : 0.0);
        var newX = math.cos(angle) * 0.5;
        var newY = math.sin(angle) * 0.5;
        if (newX.isNaN || newY.isNaN) {
          newX = 0;
          newY = 0.5;
        }

        final newPosition = current + Offset(newX, newY);
        if (data != null) {
          dotData[index] = data.copyWith(
            position: Offset.lerp(current, newPosition, t)!,
            opacity: 1 - t,
          );
        }
      }

      setState(() {
        _dotData = dotData;
      });
    }

    _animationController.stop();
    _animationController.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationController.duration = duration;
      _animationController.addListener(listener);
      await _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: PuzzleDotsPainter(
          puzzle: _puzzle,
          dotData: _dotData,
        ),
        child: Container(),
      ),
    );
  }
}
