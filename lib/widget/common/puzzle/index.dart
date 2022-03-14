// ignore_for_file: invalid_use_of_protected_member

import 'dart:ui';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dot_puzzle/core/math.dart';
import 'package:dot_puzzle/model/position.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/service/puzzle/model/move_direction.dart';
import 'package:dot_puzzle/widget/common/puzzle/controller.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'dart:math' as math;

import 'painter.dart';

typedef OnPuzzleTap = Function({
  required PuzzleModel model,
  required PositionModel<int> position,
  required bool moved,
  required bool successMoved,
});

enum _PuzzleRoundedCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class Puzzle extends StatefulWidget {
  final PuzzleController? controller;
  final Function(PuzzleModel model)? onChanged;
  final OnPuzzleTap? onPuzzleTap;
  final FocusNode? focusNode;

  const Puzzle({
    Key? key,
    this.controller,
    this.onChanged,
    this.onPuzzleTap,
    this.focusNode,
  }) : super(key: key);

  @override
  PuzzleState createState() => PuzzleState();
}

class PuzzleState extends State<Puzzle> with TickerProviderStateMixin {
  final _model = ValueNotifier<PuzzleModel?>(null);
  final _dotData = ValueNotifier<Map<int, DotData>>(<int, DotData>{});

  late FocusNode _focusNode;
  late PuzzleController _controller;
  late AnimationController _animationControllerPosition;
  late AnimationController _animationControllerColor;

  late Throttle<Offset?> _throttle;

  Offset? _touchPosition;
  DateTime? _touchStartAt;
  late BoxConstraints _constraints;

  Duration get _touchDownDuration => const Duration(milliseconds: 500);

  Duration get _moveDuration => const Duration(milliseconds: 1000);

  Duration get _colorDuration => const Duration(milliseconds: 500);

  Duration get _touchUpDuration => const Duration(milliseconds: 150);

  late Duration _throttleDuration;

  bool get imageMode => _model.value!.imageMode;

  bool _throttleEnabled = false;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();

    if (kIsWeb) {
      _throttleDuration = Duration(milliseconds: ((1 / 10) * 1000).floor());
    } else {
      _throttleDuration = Duration(milliseconds: ((1 / 30) * 1000).floor());
    }

    _throttle = Throttle<Offset?>(_throttleDuration, initialValue: null);
    _throttle.values.listen((event) {
      if (!_throttleEnabled) {
        return;
      }

      if (event == null) {
        return;
      }

      _onMove(event);
    });

    _animationControllerPosition = AnimationController(vsync: this);
    _animationControllerColor = AnimationController(vsync: this);

    _controller = widget.controller ?? PuzzleController();
    _controller.attach(this);

    final PuzzleService service = GetIt.I.get();
    _model.value = service.create();
    final dotData = <int, DotData>{};
    for (var dot in _model.value!.dots) {
      dotData[dot.globalCorrectTile.index] = const DotData(
        opacity: 1.0,
        position: Offset.zero,
        color: Colors.transparent,
      );
    }
    _dotData.value = dotData;
    _animateDotsPosition();
    _animateDotsColor();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) => widget.onChanged?.call(_model.value!));
    super.initState();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _controller.attach(null);
    _animationControllerPosition.dispose();
    super.dispose();
  }

  _onMove(Offset position) {
    _touchPosition = position;

    if (_touchStartAt == null) {
      _touchStartAt = DateTime.now();

      _animateDotsPosition(
        focusPosition: Offset(
          _touchPosition!.dx / _constraints.maxWidth,
          _touchPosition!.dy / _constraints.maxHeight,
        ),
        duration: _touchDownDuration,
      );
    } else {
      final millis = DateTime.now().millisecondsSinceEpoch - (_touchStartAt?.millisecondsSinceEpoch ?? 0);
      double t = 1.0;
      if (millis < _touchDownDuration.inMilliseconds) {
        t = millis / _touchDownDuration.inMilliseconds;
      }

      _animateDotsPosition(
        focusPosition: Offset(
          _touchPosition!.dx / _constraints.maxWidth,
          _touchPosition!.dy / _constraints.maxHeight,
        ),
        t: t,
      );
    }
  }

  _onTileClick(Offset offset) async {
    Offset? focusPosition;
    if (_touchPosition != null) {
      focusPosition = Offset(
        _touchPosition!.dx / _constraints.maxWidth,
        _touchPosition!.dy / _constraints.maxHeight,
      );
    }

    final millisecondsFromStart = DateTime.now().millisecondsSinceEpoch - (_touchStartAt?.millisecondsSinceEpoch ?? 0);
    if (millisecondsFromStart < 300) {
      await _animateDotsPosition(
        focusPosition: Offset(
          offset.dx / _constraints.maxWidth,
          offset.dy / _constraints.maxHeight,
        ),
        duration: _touchUpDuration,
      );
    }

    final whiteTilePosition = _model.value!.whiteTilePosition;
    final touchTilePosition = PositionModel<int>(
      x: ((offset.dx / _constraints.maxWidth) * _model.value!.size).floor(),
      y: ((offset.dy / _constraints.maxHeight) * _model.value!.size).floor(),
    );

    // Exit
    if (whiteTilePosition == null) {
      _animateDotsPosition(
        duration: _touchDownDuration,
        focusPosition: focusPosition,
      );

      widget.onPuzzleTap?.call(
        model: _model.value!,
        position: touchTilePosition,
        moved: false,
        successMoved: false,
      );
      return;
    }

    final PuzzleService service = GetIt.I.get();
    final moveResult = service.move(_model.value!, touchTilePosition.x, touchTilePosition.y);
    _model.value = moveResult.model;

    if (moveResult.newIncorrectDots.isNotEmpty || moveResult.newCorrectDots.isNotEmpty) {
      _animateDotsColor(
        duration: _colorDuration,
        moveDirection: moveResult.moveDirection ?? PuzzleMoveDirection.left,
      );
    }

    // Restore positions
    _animateDotsPosition(
      duration: _moveDuration,
      focusPosition: focusPosition,
    );

    widget.onPuzzleTap?.call(
      model: _model.value!,
      position: touchTilePosition,
      moved: moveResult.moveDirection != null,
      successMoved: moveResult.newCorrectDots.isNotEmpty,
    );

    widget.onChanged?.call(_model.value!);
  }

  _animateDotsPosition({
    Offset? focusPosition,
    Duration duration = Duration.zero,
    double t = 1.0,
  }) async {
    listener() {
      final _t = duration == Duration.zero ? t : _animationControllerPosition.value;
      const delta = 1.5;
      const f = 0.03;
      const shimmer = 0.2;
      final size = _model.value!.size;
      final innerDots = _model.value!.innerDots;
      var white = _model.value!.whiteTilePosition;

      final dotData = _dotData.value;

      for (var dot in _model.value!.dots) {
        final index = dot.globalCorrectTile.index;
        var data = dotData[index];
        final currentPosition = data?.position ?? Offset.zero;
        var newPosition = Offset(dot.currentPosition.x, dot.currentPosition.y);

        double opacity = 1.0;
        if (focusPosition != null) {
          final distance = (focusPosition - currentPosition).distance;
          if (distance < delta) {
            final distancePercentage = distance / delta;
            final force = f * (1 - (distancePercentage));
            final x = newPosition.dx - focusPosition.dx;
            final y = newPosition.dy - focusPosition.dy;
            final angle = math.atan(y / x) - (newPosition.dx < focusPosition.dx ? math.pi : 0.0);
            newPosition = newPosition + Offset((math.cos(angle) * force), math.sin(angle) * force);

            if (distancePercentage < shimmer) {
              opacity = Curves.easeInOut.transform(MathUtils.map(distancePercentage, 0, shimmer, 0.0, 1.0));
            }
          }
        }

        final roundedCorners = <_PuzzleRoundedCorner>[];
        if (dot.currentTile.x == 0 && dot.currentTile.y == 0) {
          roundedCorners.add(_PuzzleRoundedCorner.topLeft);
        }

        if (dot.currentTile.x == 0 && dot.currentTile.y == size - 1) {
          roundedCorners.add(_PuzzleRoundedCorner.bottomLeft);
        }

        if (dot.currentTile.x == size - 1 && dot.currentTile.y == 0) {
          roundedCorners.add(_PuzzleRoundedCorner.topRight);
        }

        if (dot.currentTile.x == size - 1 && dot.currentTile.y == size - 1) {
          roundedCorners.add(_PuzzleRoundedCorner.bottomRight);
        }

        if (white != null &&
            ((white.y == 0 && white.x == dot.currentTile.x + 1 && white.y == dot.currentTile.y) ||
                (white.x == size - 1 && white.y == dot.currentTile.y - 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(_PuzzleRoundedCorner.topRight);
        }

        if (white != null &&
            ((white.y == 0 && white.x == dot.currentTile.x - 1 && white.y == dot.currentTile.y) ||
                (white.x == 0 && white.y == dot.currentTile.y - 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(_PuzzleRoundedCorner.topLeft);
        }

        if (white != null &&
            ((white.y == size - 1 && white.x == dot.currentTile.x + 1 && white.y == dot.currentTile.y) ||
                (white.x == size - 1 && white.y == dot.currentTile.y + 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(_PuzzleRoundedCorner.bottomRight);
        }

        if (white != null &&
            ((white.y == size - 1 && white.x == dot.currentTile.x - 1 && white.y == dot.currentTile.y) ||
                (white.x == 0 && white.y == dot.currentTile.y + 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(_PuzzleRoundedCorner.bottomLeft);
        }

        if (roundedCorners.any((e) => e == _PuzzleRoundedCorner.topLeft)) {
          if (dot.subTile.x == 0 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 2 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 3 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == 2) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == 3) opacity = 0;
        }

        if (roundedCorners.any((e) => e == _PuzzleRoundedCorner.topRight)) {
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == innerDots - 2 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == innerDots - 3 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == innerDots - 4 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == innerDots - 2 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == 2) opacity = 0;
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == 3) opacity = 0;
        }

        if (roundedCorners.any((e) => e == _PuzzleRoundedCorner.bottomLeft)) {
          if (dot.subTile.x == 0 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == 2 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == 3 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == innerDots - 2) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == innerDots - 2) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == innerDots - 3) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == innerDots - 4) opacity = 0;
        }

        if (roundedCorners.any((e) => e == _PuzzleRoundedCorner.bottomRight)) {
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == innerDots - 2 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == innerDots - 3 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == innerDots - 4 && dot.subTile.y == innerDots - 1) opacity = 0;
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == innerDots - 2) opacity = 0;
          if (dot.subTile.x == innerDots - 2 && dot.subTile.y == innerDots - 2) opacity = 0;
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == innerDots - 3) opacity = 0;
          if (dot.subTile.x == innerDots - 1 && dot.subTile.y == innerDots - 4) opacity = 0;
        }

        final newX = lerpDouble(currentPosition.dx, newPosition.dx, _t)!;
        final newY = lerpDouble(currentPosition.dy, newPosition.dy, _t)!;

        if (data != null) {
          data = data.copyWith(
            position: Offset(newX, newY),
            opacity: lerpDouble(data.opacity, opacity, _t) ?? 1.0,
          );
          dotData[index] = data;
        }
      }

      _dotData.value = Map<int, DotData>.from(dotData);
    }

    _animationControllerPosition.stop();
    _animationControllerPosition.reset();
    _animationControllerPosition.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationControllerPosition.addListener(listener);
      _animationControllerPosition.duration = duration;
      await _animationControllerPosition.forward(from: 0.0);
    }
  }

  _animateDotsColor({
    Duration duration = Duration.zero,
    double t = 1.0,
    PuzzleMoveDirection moveDirection = PuzzleMoveDirection.right,
  }) async {
    Color getDotColor(PuzzleDotModel dot) {
      Color color;
      if (_model.value!.imageMode) {
        color = dot.imageColor;
      } else {
        if (dot.isNumber) {
          color = dot.numberColor;
        } else {
          if (dot.isInCorrectPosition) {
            color = dot.correctColor;
          } else {
            color = dot.incorrectColor;
          }
        }
      }
      return color;
    }

    final pendingPoints = _model.value!.dots.where((d) {
      final index = d.globalCorrectTile.index;
      final c = _dotData.value[index]?.color ?? Colors.transparent;
      final newColor = getDotColor(d);
      return c != newColor;
    }).toList();

    listener() {
      final _t = duration == Duration.zero ? t : _animationControllerColor.value;
      final innerDots = _model.value!.innerDots;

      final dots = pendingPoints.where((dot) {
        switch (moveDirection) {
          case PuzzleMoveDirection.up:
            final y = dot.subTile.y + math.cos(dot.subTile.x);
            final p = (y / innerDots).clamp(0.0, 1.0);
            return (1 - p) <= _t;
          case PuzzleMoveDirection.down:
            final y = dot.subTile.y + math.cos(dot.subTile.x);
            final p = (y / innerDots).clamp(0.0, 1.0);
            return p <= _t;
          case PuzzleMoveDirection.left:
            final x = dot.subTile.x + math.sin(dot.subTile.y);
            final p = (x / innerDots).clamp(0.0, 1.0);
            return (1 - p) <= _t;
          case PuzzleMoveDirection.right:
            final x = dot.subTile.x + math.sin(dot.subTile.y);
            final p = (x / innerDots).clamp(0.0, 1.0);
            return p <= _t;
        }
      }).toList();

      final dotData = _dotData.value;
      for (var dot in dots) {
        final index = dot.globalCorrectTile.index;

        if (dotData[index] != null) {
          dotData[index] = dotData[index]!.copyWith(
            color: getDotColor(dot),
          );
        }
      }

      _dotData.value = Map<int, DotData>.from(dotData);
    }

    _animationControllerColor.stop();
    _animationControllerColor.reset();
    _animationControllerColor.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationControllerColor.addListener(listener);
      _animationControllerColor.duration = duration;
      await _animationControllerColor.forward(from: 0.0);
    }
  }

  _animateToggleMode({
    Duration duration = Duration.zero,
    double t = 1.0,
  }) async {
    Color getDotColor(PuzzleDotModel dot) {
      Color color;
      if (_model.value!.imageMode) {
        color = dot.imageColor;
      } else {
        if (dot.isNumber) {
          color = dot.numberColor;
        } else {
          if (dot.isInCorrectPosition) {
            color = dot.correctColor;
          } else {
            color = dot.incorrectColor;
          }
        }
      }
      return color;
    }

    listener() {
      final _t = duration == Duration.zero ? t : _animationControllerColor.value;
      final size = _model.value!.size;
      final innerDots = _model.value!.innerDots;

      final center = Offset((size * innerDots * 0.5), (size * innerDots * 0.5));

      final dots = _model.value!.dots.where((dot) {
        final x = dot.globalCurrentTile.x;
        final y = dot.globalCurrentTile.y;
        final p = Offset(x.toDouble(), y.toDouble());
        final distance = (p - center).distance;
        return (distance / (size * innerDots)) <= _t;
      }).toList();

      final dotData = _dotData.value;
      for (var dot in dots) {
        final index = dot.globalCorrectTile.index;
        if (dotData[index] != null) {
          dotData[index] = dotData[index]!.copyWith(
            color: getDotColor(dot),
          );
        }
      }

      _dotData.value = Map<int, DotData>.from(dotData);
    }

    _animationControllerColor.stop();
    _animationControllerColor.reset();
    _animationControllerColor.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationControllerColor.addListener(listener);
      _animationControllerColor.duration = duration;
      await _animationControllerColor.forward(from: 0.0);
    }
  }

  Future<void> explode({
    Duration duration = Duration.zero,
  }) async {
    listener() {
      final _t = duration == Duration.zero ? 1.0 : _animationControllerPosition.value;
      const focusPosition = Offset(0.5, 0.5);

      var dotData = _dotData.value;

      for (var dot in _model.value!.dots) {
        final index = dot.globalCorrectTile.index;
        final data = dotData[index];
        final currentPosition = data?.position ?? Offset.zero;
        var newPosition = Offset(dot.currentPosition.x, dot.currentPosition.y);

        final x = newPosition.dx - focusPosition.dx;
        final y = newPosition.dy - focusPosition.dy;
        final angle = math.atan(y / x) - (newPosition.dx < focusPosition.dx ? math.pi : 0.0);
        newPosition = newPosition + Offset((math.cos(angle)), math.sin(angle));

        final newX = lerpDouble(currentPosition.dx, newPosition.dx, _t)!;
        final newY = lerpDouble(currentPosition.dy, newPosition.dy, _t)!;

        if (data != null) {
          dotData[index] = data.copyWith(
            position: Offset(newX, newY),
            opacity: lerpDouble(data.opacity, 0.0, _t) ?? 1.0,
          );
        }
      }

      _dotData.value = Map<int, DotData>.from(dotData);
    }

    _animationControllerPosition.stop();
    _animationControllerPosition.reset();
    _animationControllerPosition.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationControllerPosition.addListener(listener);
      _animationControllerPosition.duration = duration;
      await _animationControllerPosition.forward(from: 0.0);
    }
  }

  sort() async {
    final PuzzleService service = GetIt.I.get();
    _model.value = service.sort(_model.value!);
    widget.onChanged?.call(_model.value!);

    _animateDotsPosition(duration: _moveDuration);
    _animateDotsColor(duration: Duration.zero);
  }

  reset() {
    final PuzzleService service = GetIt.I.get();
    _model.value = service.reset(_model.value!);
    widget.onChanged?.call(_model.value!);

    _animateDotsPosition(duration: _moveDuration);
    _animateDotsColor(duration: Duration.zero);
  }

  convertToImage() {
    if (_model.value!.imageMode) return;

    final PuzzleService service = GetIt.I.get();
    _model.value = service.convertToImage(_model.value!);
    _animateToggleMode(duration: _colorDuration);
  }

  convertToNumbers() {
    if (!_model.value!.imageMode) return;

    final PuzzleService service = GetIt.I.get();
    _model.value = service.convertToNumbers(_model.value!);
    _animateToggleMode(duration: _colorDuration);
  }

  _onPointerDown(Offset localPosition) {
    _throttleEnabled = true;
    _throttle.notify(localPosition);

    EasyDebounce.cancel("fix");
  }

  _onPointerMove(Offset localPosition) {
    _throttleEnabled = true;
    _touchPosition = localPosition;
    _throttle.value = localPosition;

    EasyDebounce.debounce("fix", const Duration(milliseconds: 200), _fix);
  }

  _onPointerExit(Offset localPosition, {bool click = true}) async {
    EasyDebounce.cancel("fix");

    _touchPosition = null;

    _throttleEnabled = false;
    _throttle.notify(null);

    if (click) {
      _onTileClick(localPosition);
    } else {
      _animateDotsPosition(duration: _touchDownDuration);
    }

    _touchStartAt = null;
  }

  _fix() {
    _throttle.notify(null);
    _throttleEnabled = false;

    _animateDotsPosition(duration: _moveDuration);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (_model.value == null) return;
    if (_model.value!.isCompleted) return;

    if (event is RawKeyDownEvent) {
      final physicalKey = event.data.physicalKey;
      final white = _model.value?.whiteTilePosition;
      if (white == null) return;

      PositionModel<int>? pos;
      if (physicalKey == PhysicalKeyboardKey.arrowDown) {
        if (white.y == 0) return;
        pos = PositionModel(x: white.x, y: white.y - 1);
      } else if (physicalKey == PhysicalKeyboardKey.arrowUp) {
        if (white.y == _model.value!.size - 1) return;
        pos = PositionModel(x: white.x, y: white.y + 1);
      } else if (physicalKey == PhysicalKeyboardKey.arrowRight) {
        if (white.x == 0) return;
        pos = PositionModel(x: white.x - 1, y: white.y);
      } else if (physicalKey == PhysicalKeyboardKey.arrowLeft) {
        if (white.x == _model.value!.size - 1) return;
        pos = PositionModel(x: white.x + 1, y: white.y);
      }

      if (pos == null) return;

      _throttleEnabled = false;
      _throttle.notify(null);

      final PuzzleService service = GetIt.I.get();
      final moveResult = service.move(_model.value!, pos.x, pos.y);
      _model.value = moveResult.model;

      if (moveResult.newIncorrectDots.isNotEmpty || moveResult.newCorrectDots.isNotEmpty) {
        _animateDotsColor(
          duration: _colorDuration,
          moveDirection: moveResult.moveDirection ?? PuzzleMoveDirection.left,
        );
      }

      // Restore positions
      _animateDotsPosition(duration: _moveDuration);

      widget.onPuzzleTap?.call(
        model: _model.value!,
        position: pos,
        moved: moveResult.moveDirection != null,
        successMoved: moveResult.newCorrectDots.isNotEmpty,
      );

      widget.onChanged?.call(_model.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!_focusNode.hasFocus) {
            FocusScope.of(context).requestFocus(_focusNode);
          }

          _constraints = constraints;
          return Stack(
            children: [
              Positioned.fill(
                child: MultiValueListenableBuilder(
                  valueListenables: [_model, _dotData],
                  builder: (context, values, child) => CustomPaint(
                    willChange: true,
                    painter: PuzzleDotsPainter(
                      puzzle: _model.value!,
                      dotData: _dotData.value,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned.fill(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: !kIsWeb ? null : (e) => _onPointerDown(e.localPosition),
                  onHover: !kIsWeb ? null : (e) => _onPointerMove(e.localPosition),
                  onExit: !kIsWeb ? null : (e) => _onPointerExit(e.localPosition, click: false),
                  child: Listener(
                    onPointerDown: (e) => _onPointerDown(e.localPosition),
                    onPointerMove: (e) => _onPointerMove(e.localPosition),
                    onPointerUp: (e) => _onPointerExit(e.localPosition),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DotData extends Equatable {
  final double opacity;
  final Color color;
  final Offset position;

  const DotData({
    required this.opacity,
    required this.color,
    required this.position,
  });

  DotData copyWith({
    double? opacity,
    Offset? position,
    Color? color,
  }) {
    return DotData(
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [opacity, color, position];
}
