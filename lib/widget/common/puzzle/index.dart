import 'dart:developer';

import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/model/tile.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/widget/common/puzzle/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;

import 'painter.dart';

class Puzzle extends StatefulWidget {
  final PuzzleController? controller;

  const Puzzle({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  PuzzleState createState() => PuzzleState();
}

class PuzzleState extends State<Puzzle> with TickerProviderStateMixin {
  late PuzzleModel _model;
  late PuzzleController _controller;
  late AnimationController _animationController;
  late AnimationController _animationControllerColor;

  Offset? _touchPosition;
  DateTime? _touchStartAt;
  bool _animating = false;
  bool _pressed = false;

  Duration get _touchDownDuration => const Duration(milliseconds: 500);

  Duration get _moveDuration => const Duration(milliseconds: 500);

  Duration get _touchUpDuration => const Duration(milliseconds: 150);

  PuzzleService get _puzzleService => GetIt.I.get();

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    _animationControllerColor = AnimationController(vsync: this);

    _controller = widget.controller ?? PuzzleController();
    _controller.attach(this);

    final PuzzleService service = GetIt.I.get();
    _model = service.create(size: 4);
    _puzzleService.updateCorrectDotsColor(_model, _model.dots);

    super.initState();
  }

  @override
  void dispose() {
    _controller.attach(null);
    _animationController.dispose();
    _animationControllerColor.dispose();
    super.dispose();
  }

  _onPointerDown(Offset position, BoxConstraints constraints, {bool click = false}) {
    _pressed = click;
    _touchStartAt = DateTime.now();
    _touchPosition = position;

    _animateDotsPosition(
      focusPosition: Offset(
        _touchPosition!.dx / constraints.maxWidth,
        _touchPosition!.dy / constraints.maxHeight,
      ),
      duration: _touchDownDuration,
    );
  }

  _onPointerMove(Offset position, BoxConstraints constraints) {
    if (_touchPosition == null || _touchStartAt == null) return;

    _touchPosition = position;

    final millis = DateTime.now().millisecondsSinceEpoch - (_touchStartAt?.millisecondsSinceEpoch ?? 0);
    double t = 1.0;
    if (millis < _touchDownDuration.inMilliseconds) {
      t = millis / _touchDownDuration.inMilliseconds;
    }

    _jumpDotsPosition(
      focusPosition: Offset(
        _touchPosition!.dx / constraints.maxWidth,
        _touchPosition!.dy / constraints.maxHeight,
      ),
      t: t,
    );
  }

  _onPointerUp(BoxConstraints constraints, {bool click = false, bool hover = false}) async {
    if (_touchPosition == null || _touchStartAt == null) {
      log("Up. No touch position or touch start");
      return;
    }

    _pressed = false;

    if (!hover && click) {
      final microsecondsFromStart = DateTime.now().microsecondsSinceEpoch - (_touchStartAt?.microsecondsSinceEpoch ?? 0);
      if (microsecondsFromStart < _touchDownDuration.inMicroseconds) {
        await _animateDotsPosition(
          focusPosition: Offset(
            _touchPosition!.dx / constraints.maxWidth,
            _touchPosition!.dy / constraints.maxHeight,
          ),
          duration: _touchUpDuration,
        );
      }
    }

    final whiteTilePosition = _model.whiteTilePosition;
    final touchTilePosition = _touchTilePosition(constraints);

    final exitPosition = kIsWeb && !hover ? _touchPosition : null;

    // Exit
    if (hover || whiteTilePosition == null || touchTilePosition == null) {
      _animateDotsPosition(
        duration: _touchDownDuration,
        focusPosition: exitPosition == null
            ? null
            : Offset(
                exitPosition.dx / constraints.maxWidth,
                exitPosition.dy / constraints.maxHeight,
              ),
      );
      return;
    }

    bool shouldReorder = _model.canMove(touchTilePosition.x, touchTilePosition.y);
    bool horizontalReorder = whiteTilePosition.y == touchTilePosition.y;

    int deltaX = 0;
    int deltaY = 0;
    int from = 0;
    int to = 0;
    var movedTiles = <TileModel>[];
    var movedDots = <PuzzleDotModel>[];

    if (shouldReorder) {
      _animating = true;

      bool reverse = false;

      if (horizontalReorder) {
        if (whiteTilePosition.x < touchTilePosition.x) {
          reverse = true;
          from = whiteTilePosition.x + 1;
          to = touchTilePosition.x;
        } else {
          from = touchTilePosition.x;
          to = whiteTilePosition.x - 1;
        }
      } else {
        if (whiteTilePosition.y < touchTilePosition.y) {
          reverse = true;
          from = whiteTilePosition.y + 1;
          to = touchTilePosition.y;
        } else {
          from = touchTilePosition.y;
          to = whiteTilePosition.y - 1;
        }
      }

      deltaX = (!horizontalReorder ? 0 : (reverse ? -1 : 1));
      deltaY = (horizontalReorder ? 0 : (reverse ? -1 : 1));

      List<PuzzleDotModel> dots;
      if (horizontalReorder) {
        dots = _model.dots.where((e) => e.currentTileY == whiteTilePosition.y && e.currentTileX >= from && e.currentTileX <= to).toList();
      } else {
        dots = _model.dots.where((e) => e.currentTileX == whiteTilePosition.x && e.currentTileY >= from && e.currentTileY <= to).toList();
      }

      for (var dot in dots) {
        dot.currentTileX = dot.currentTileX + deltaX;
        dot.currentTileY = dot.currentTileY + deltaY;

        final tile = dot.getCurrentTile(_model.size);
        if (!movedTiles.any((e) => e == tile)) {
          movedTiles.add(tile);
        }
      }

      movedDots = dots;
    }

    final futures = <Future>[];

    // Animate colors
    if (shouldReorder && !_model.imageMode) {
      var changeColorDots = <PuzzleDotModel>[];
      for (var tile in movedTiles) {
        final fromTile = TileModel(
          x: tile.x - deltaX,
          y: tile.y - deltaY,
          index: tile.index,
        );

        final wasCorrect = fromTile.isInCorrectPosition(_model.size);
        final isCorrect = tile.isInCorrectPosition(_model.size);

        // Only animate colors if i move a tile from incorrect to a correct position and viceversa
        // If i move the tile from 2 incorrect positions, do nothing
        if (wasCorrect != isCorrect) {
          final dots = movedDots.where((e) => e.currentTileX == tile.x && e.currentTileY == tile.y).toList();
          changeColorDots.addAll(dots);
        }
      }

      if (changeColorDots.isNotEmpty) {
        final future = _animateToggleImage(changeColorDots);
        futures.add(future);
      }
    }

    // Restore positions
    futures.add(_animateDotsPosition(
      duration: _moveDuration,
      focusPosition: exitPosition == null
          ? null
          : Offset(
              exitPosition.dx / constraints.maxWidth,
              exitPosition.dy / constraints.maxHeight,
            ),
    ));

    await Future.wait(futures);
  }

  math.Point<int>? _touchTilePosition(BoxConstraints constraints) {
    if (_touchPosition == null) return null;
    final x = _touchPosition!.dx / constraints.maxWidth;
    final y = _touchPosition!.dy / constraints.maxHeight;
    return math.Point<int>((x * _model.size).floor(), (y * _model.size).floor());
  }

  _animateDotsPosition({
    Offset? focusPosition,
    required Duration duration,
  }) async {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    listener() {
      _puzzleService.updateDotsPosition(
        _model,
        focusPosition: focusPosition,
        t: _animationController.value,
        pressed: _pressed,
      );
      setState(() {});
    }

    _animationController.clearListeners();
    _animationController.addListener(listener);
    _animationController.duration = duration;
    await _animationController.forward(from: 0.0);
  }

  _jumpDotsPosition({
    Offset? focusPosition,
    double t = 1.0,
  }) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    _puzzleService.updateDotsPosition(
      _model,
      focusPosition: focusPosition,
      t: t,
      pressed: _pressed,
    );
    setState(() {});
  }

  // _animateFancyCorrectDotsColor({required List<PuzzleDotModel> dots}) async {
  //   if (_animationControllerColor.isAnimating) {
  //     _animationControllerColor.stop();
  //   }
  //
  //   final lineDuration = Duration(milliseconds: (((1 / 60) * 1000)).floor());
  //
  //   // final size = _model.size;
  //   // final innerDots = _model.innerDots;
  //   // final totalLines = size * innerDots;
  //   // final totalDiagonalLines = (totalLines + totalLines) - 1;
  //   // int delta = 2;
  //   //
  //   // final dotsBatch = <List<PuzzleDotModel>>[];
  //   // for (int diagonalLineIndex = 0; diagonalLineIndex < totalDiagonalLines; diagonalLineIndex += delta) {
  //   //   int from = diagonalLineIndex;
  //   //   int to = diagonalLineIndex + delta;
  //   //
  //   //   final batch = dots.where((e) => e.diagonalLine >= from && e.diagonalLine < to).toList();
  //   //   if (batch.isNotEmpty) {
  //   //     dotsBatch.add(batch);
  //   //   }
  //   // }
  //   //
  //   // for (var batch in dotsBatch) {
  //   //   _puzzleService.updateCorrectDotsColor(_model, batch);
  //   //   setState(() {});
  //   //
  //   //   await Future.delayed(lineDuration);
  //   // }
  // }

  _animateToggleImage(List<PuzzleDotModel> dots) async {
    if (_animationControllerColor.isAnimating) {
      _animationControllerColor.stop();
    }

    final lineDuration = Duration(milliseconds: (((1 / 60) * 1000)).floor());

    final size = _model.size;
    final innerDots = _model.innerDots;
    int length = dots.length;
    int batchSize = (length * 0.05).floor();

    dots.sort((a, b) {
      final val1 = a.getCurrentIndex(size, innerDots);
      final val2 = b.getCurrentIndex(size, innerDots);
      return val1.compareTo(val2);
    });

    final availablePoints = List.from(dots);
    do {
      final dots = <PuzzleDotModel>[];
      for (int batchIndex = 0; batchIndex < batchSize; batchIndex++) {
        final dot = availablePoints.removeRandom();
        if (dot != null) {
          dots.add(dot);
        }
      }

      _puzzleService.updateCorrectDotsColor(_model, dots);
      setState(() {});
      await Future.delayed(lineDuration);
    } while (availablePoints.isNotEmpty);
  }

  Future<void> sort() async {
    if (_animating) return;
    if (_model.isCompleted) return;

    final PuzzleService service = GetIt.I.get();
    service.sort(_model);

    _animating = true;
    service.updateCorrectDotsColor(_model, _model.dots);
    await _animateDotsPosition(duration: _moveDuration);
    _animating = false;
  }

  Future<void> shuffle() async {
    if (_animating) return;

    final PuzzleService service = GetIt.I.get();
    service.shuffle(_model);

    _animating = true;
    service.updateCorrectDotsColor(_model, _model.dots);
    await _animateDotsPosition(duration: _moveDuration);
    _animating = false;
  }

  Future<void> convertToImage() async {
    if (_animating) return;
    if (_model.imageMode) return;

    final PuzzleService service = GetIt.I.get();
    service.convertToImage(_model);

    _animating = true;
    await _animateToggleImage(_model.dots);
    _animating = false;
  }

  Future<void> convertToNumbers() async {
    if (_animating) return;
    if (!_model.imageMode) return;

    final PuzzleService service = GetIt.I.get();
    service.convertToNumbers(_model);

    _animating = true;
    await _animateToggleImage(_model.dots);
    _animating = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (e) => _onPointerDown(e.localPosition, constraints),
        onHover: (e) => _onPointerMove(e.localPosition, constraints),
        onExit: (e) => _onPointerUp(constraints, hover: true),
        child: Listener(
          onPointerDown: (e) => _onPointerDown(e.localPosition, constraints, click: true),
          onPointerMove: (e) => _onPointerMove(e.localPosition, constraints),
          onPointerUp: (e) => _onPointerUp(constraints, click: true),
          child: CustomPaint(
            willChange: true,
            painter: PuzzleDotsPainter(puzzle: _model),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}
