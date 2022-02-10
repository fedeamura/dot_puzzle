import 'dart:developer';

import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/model/tile.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/widget/common/puzzle/painter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;

class AnimatedPixelCountDown extends StatefulWidget {
  final int from;
  final Function()? onReady;

  const AnimatedPixelCountDown({
    Key? key,
    this.from = 3,
    this.onReady,
  }) : super(key: key);

  @override
  _AnimatedPixelCountDownState createState() => _AnimatedPixelCountDownState();
}

class _AnimatedPixelCountDownState extends State<AnimatedPixelCountDown> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PuzzleModel _puzzle;
  var _colors = <int, Color>{};
  var _positions = <int, Offset>{};
  var _opacities = <int, double>{};

  late int _count;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    _count = widget.from;

    final PuzzleService service = GetIt.I.get();
    final number = service.getNumberRepresentation(widget.from);

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

        _colors[subIndex] = number[subIndex] ?? Colors.transparent;
        _positions[subIndex] = Offset(dot.currentPosition.x, dot.currentPosition.y);
        _opacities[subIndex] = 1.0;
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

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _wait();
    });
  }

  _wait() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    _count--;
    if (_count <= 0) {
      widget.onReady?.call();
      return;
    }

    final PuzzleService service = GetIt.I.get();
    final number = service.getNumberRepresentation(_count);

    await _animateCollapse();
    _colors = <int, Color>{};
    for (var dot in _puzzle.dots) {
      final index = dot.subTile.index;
      _colors[index] = number[index] ?? Colors.transparent;
    }
    setState(() {});
    await _animateExpand();
    _wait();
  }

  _animateCollapse() async {
    listener() {
      const center = Offset(0.5, 0.5);
      final t = _animationController.value;
      for (var dot in _puzzle.dots) {
        final index = dot.subTile.index;
        final current = _positions[index] ?? Offset.zero;

        final x = current.dx - center.dx;
        final y = current.dy - center.dx;
        final angle = math.atan(x / y) - (current.dx < center.dx ? math.pi : 0.0);
        // if (index == 0) {
        //   log("angle $angle");
        // }
        // final newPosition = current + Offset(math.cos(angle) * 1, math.sin(angle) * 1);

        // var newPosition = current + Offset(math.cos(angle), math.sin(angle));
        const newPosition = const Offset(0.5, 0.5);

        _positions[index] = Offset.lerp(current, newPosition, t)!;
      }
      _positions = Map<int, Offset>.from(_positions);
      setState(() {});
    }

    _animationController.stop();
    _animationController.duration = const Duration(milliseconds: 1000);
    _animationController.clearListeners();
    _animationController.addListener(listener);
    await _animationController.forward(from: 0.0);
  }

  _animateExpand() async {
    listener() {
      final t = _animationController.value;
      for (var dot in _puzzle.dots) {
        final index = dot.subTile.index;
        final current = _positions[index] ?? Offset.zero;
        final newPosition = Offset(dot.currentPosition.x, dot.currentPosition.y);
        _positions[index] = Offset.lerp(current, newPosition, t)!;
      }
      _positions = Map<int, Offset>.from(_positions);
      setState(() {});
    }

    _animationController.stop();
    _animationController.duration = const Duration(milliseconds: 3000);
    _animationController.clearListeners();
    _animationController.addListener(listener);
    await _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: PuzzleDotsPainter(
          puzzle: _puzzle,
          colors: _colors,
          positions: _positions,
          opacities: _opacities,
        ),
        child: Container(),
      ),
    );
  }
}
