import 'dart:developer';
import 'dart:ui';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/core/math.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/service/puzzle/_interface.dart';
import 'package:dot_puzzle/widget/common/puzzle/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;

import 'painter.dart';

enum MoveDirection {
  up,
  down,
  left,
  right,
}

enum RoundedCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class Puzzle extends StatefulWidget {
  final PuzzleController? controller;
  final Function(int moves, int correct)? onChanged;

  const Puzzle({
    Key? key,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  PuzzleState createState() => PuzzleState();
}

class PuzzleState extends State<Puzzle> with TickerProviderStateMixin {
  late PuzzleModel _model;
  late Map<int, Color> _colors;
  late Map<int, Offset> _positions;
  late Map<int, double> _opacities;

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

  Duration get _hoverDuration => Duration(milliseconds: ((1 / 20) * 1000).floor());

  bool get imageMode => _model.imageMode;

  @override
  void initState() {
    _throttle = Throttle<Offset?>(_hoverDuration, initialValue: null);

    _animationControllerPosition = AnimationController(vsync: this);
    _animationControllerColor = AnimationController(vsync: this);

    _controller = widget.controller ?? PuzzleController();
    _controller.attach(this);

    final PuzzleService service = GetIt.I.get();
    _model = service.create();
    _colors = <int, Color>{};
    _positions = <int, Offset>{};
    _opacities = <int, double>{};
    _animateDotsPosition();
    _animateDotsColor();

    _throttle.values.listen((event) {
      if (event != null) {
        _onPointerMove(event);
      }
    });

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      widget.onChanged?.call(_model.moves, _model.correctTileCount);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.attach(null);
    _animationControllerPosition.dispose();
    super.dispose();
  }

  _onPointerMove(Offset position) {
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

  _onPointerExit() {
    _touchStartAt = null;
    _animateDotsPosition(duration: _moveDuration);
  }

  _onPointerUp({bool close = true}) async {
    log("Up start $close");

    if (_touchPosition == null || _touchStartAt == null) {
      log("Up. No touch position or touch start");
      return;
    }

    final focusPosition = Offset(
      _touchPosition!.dx / _constraints.maxWidth,
      _touchPosition!.dy / _constraints.maxHeight,
    );

    final millisecondsFromStart = DateTime.now().millisecondsSinceEpoch - (_touchStartAt?.millisecondsSinceEpoch ?? 0);
    if (millisecondsFromStart < 300) {
      log("Start fix click");
      _throttle.setValue(null);
      await Future.delayed(const Duration(milliseconds: 1));
      await _animateDotsPosition(
        focusPosition: focusPosition,
        duration: _touchUpDuration,
      );
      log("End fix click");
    }

    _touchStartAt = null;

    final whiteTilePosition = _model.whiteTilePosition;
    final touchTilePosition = _touchTilePosition();

    // Exit
    if (whiteTilePosition == null || touchTilePosition == null) {
      log("Exit. There is no white tile position or touch tile position");
      _animateDotsPosition(
        duration: _touchDownDuration,
        focusPosition: close ? null : focusPosition,
      );
      return;
    }

    bool shouldReorder = _model.canMove(touchTilePosition.x, touchTilePosition.y);
    bool horizontalReorder = whiteTilePosition.y == touchTilePosition.y;

    final size = _model.size;
    int deltaX = 0;
    int deltaY = 0;
    int from = 0;
    int to = 0;
    final changeColorDots = <PuzzleDotModel>[];
    MoveDirection moveDirection = MoveDirection.right;

    if (shouldReorder) {
      bool reverse = false;

      if (horizontalReorder) {
        if (whiteTilePosition.x < touchTilePosition.x) {
          moveDirection = MoveDirection.left;
          reverse = true;
          from = whiteTilePosition.x + 1;
          to = touchTilePosition.x;
        } else {
          moveDirection = MoveDirection.right;
          from = touchTilePosition.x;
          to = whiteTilePosition.x - 1;
        }
      } else {
        if (whiteTilePosition.y < touchTilePosition.y) {
          reverse = true;
          moveDirection = MoveDirection.up;
          from = whiteTilePosition.y + 1;
          to = touchTilePosition.y;
        } else {
          moveDirection = MoveDirection.down;
          from = touchTilePosition.y;
          to = whiteTilePosition.y - 1;
        }
      }

      deltaX = (!horizontalReorder ? 0 : (reverse ? -1 : 1));
      deltaY = (horizontalReorder ? 0 : (reverse ? -1 : 1));

      List<PuzzleDotModel> movedDots;
      if (horizontalReorder) {
        movedDots = _model.dots.where((e) => e.currentTile.y == whiteTilePosition.y && e.currentTile.x >= from && e.currentTile.x <= to).toList();
      } else {
        movedDots = _model.dots.where((e) => e.currentTile.x == whiteTilePosition.x && e.currentTile.y >= from && e.currentTile.y <= to).toList();
      }

      final editedDots = <int, PuzzleDotModel>{};

      for (var dot in movedDots) {
        final index = dot.globalCorrectTile.index;

        int currentTileX = dot.currentTile.x + deltaX;
        int currentTileY = dot.currentTile.y + deltaY;
        int newTileIndex = ListUtils.getIndex(currentTileX, currentTileY, size);

        final editedDot = dot.copyWith(currentTileIndex: newTileIndex);
        if (dot.isInCorrectPosition != editedDot.isInCorrectPosition) {
          changeColorDots.add(editedDot);
        }
        editedDots[index] = editedDot;
      }

      _model = _model.copyWith(
        dots: _model.dots.map((dot) {
          final index = dot.globalCorrectTile.index;
          return editedDots[index] ?? dot;
        }).toList(),
        moves: _model.moves + 1,
      );
      widget.onChanged?.call(_model.moves, _model.correctTileCount);
    }

    // Animate colors
    if (shouldReorder && !_model.imageMode && changeColorDots.isNotEmpty) {
      _animateDotsColor(
        duration: _colorDuration,
        moveDirection: moveDirection,
      );
    }

    // Restore positions
    _animateDotsPosition(
      duration: _moveDuration,
      focusPosition: close ? null : focusPosition,
    );
  }

  math.Point<int>? _touchTilePosition() {
    if (_touchPosition == null) return null;
    final x = _touchPosition!.dx / _constraints.maxWidth;
    final y = _touchPosition!.dy / _constraints.maxHeight;
    return math.Point<int>((x * _model.size).floor(), (y * _model.size).floor());
  }

  _animateDotsPosition({
    Offset? focusPosition,
    Duration duration = Duration.zero,
    double t = 1.0,
  }) async {
    listener() {
      final _t = duration == Duration.zero ? t : _animationControllerPosition.value;
      const delta = 1.5;
      const f = 0.1;
      const shimmer = 0.3;
      var white = _model.whiteTilePosition;

      for (var dot in _model.dots) {
        final index = dot.globalCorrectTile.index;
        final currentPosition = _positions[index] ?? Offset.zero;
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
            newPosition = newPosition + Offset(math.cos(angle) * force, math.sin(angle) * force);
            if (distancePercentage < shimmer) {
              opacity = Curves.easeInOut.transform(MathUtils.map(distancePercentage, 0, shimmer, 0.0, 1.0));
            }
          }
        }

        final roundedCorners = <RoundedCorner>[];
        if (dot.currentTile.x == 0 && dot.currentTile.y == 0) {
          roundedCorners.add(RoundedCorner.topLeft);
        }

        if (dot.currentTile.x == 0 && dot.currentTile.y == _model.size - 1) {
          roundedCorners.add(RoundedCorner.bottomLeft);
        }

        if (dot.currentTile.x == _model.size - 1 && dot.currentTile.y == 0) {
          roundedCorners.add(RoundedCorner.topRight);
        }

        if (dot.currentTile.x == _model.size - 1 && dot.currentTile.y == _model.size - 1) {
          roundedCorners.add(RoundedCorner.bottomRight);
        }

        if (white != null &&
            ((white.y == 0 && white.x == dot.currentTile.x + 1 && white.y == dot.currentTile.y) ||
                (white.x == _model.size - 1 && white.y == dot.currentTile.y - 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(RoundedCorner.topRight);
        }

        if (white != null &&
            ((white.y == 0 && white.x == dot.currentTile.x - 1 && white.y == dot.currentTile.y) ||
                (white.x == 0 && white.y == dot.currentTile.y - 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(RoundedCorner.topLeft);
        }

        if (white != null &&
            ((white.y == _model.size - 1 && white.x == dot.currentTile.x + 1 && white.y == dot.currentTile.y) ||
                (white.x == _model.size - 1 && white.y == dot.currentTile.y + 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(RoundedCorner.bottomRight);
        }

        if (white != null &&
            ((white.y == _model.size - 1 && white.x == dot.currentTile.x - 1 && white.y == dot.currentTile.y) ||
                (white.x == 0 && white.y == dot.currentTile.y + 1 && white.x == dot.currentTile.x))) {
          roundedCorners.add(RoundedCorner.bottomLeft);
        }

        if (roundedCorners.any((e) => e == RoundedCorner.topLeft)) {
          if (dot.subTile.x == 0 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 2 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 3 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == 2) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == 3) opacity = 0;
        }

        if (roundedCorners.any((e) => e == RoundedCorner.topRight)) {
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 2 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 3 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 4 && dot.subTile.y == 0) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 2 && dot.subTile.y == 1) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == 2) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == 3) opacity = 0;
        }

        if (roundedCorners.any((e) => e == RoundedCorner.bottomLeft)) {
          if (dot.subTile.x == 0 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == 2 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == 3 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == _model.innerDots - 2) opacity = 0;
          if (dot.subTile.x == 1 && dot.subTile.y == _model.innerDots - 2) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == _model.innerDots - 3) opacity = 0;
          if (dot.subTile.x == 0 && dot.subTile.y == _model.innerDots - 4) opacity = 0;
        }

        if (roundedCorners.any((e) => e == RoundedCorner.bottomRight)) {
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 2 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 3 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 4 && dot.subTile.y == _model.innerDots - 1) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == _model.innerDots - 2) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 2 && dot.subTile.y == _model.innerDots - 2) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == _model.innerDots - 3) opacity = 0;
          if (dot.subTile.x == _model.innerDots - 1 && dot.subTile.y == _model.innerDots - 4) opacity = 0;
        }

        final newX = lerpDouble(currentPosition.dx, newPosition.dx, Curves.decelerate.transform(_t))!;
        final newY = lerpDouble(currentPosition.dy, newPosition.dy, Curves.decelerate.transform(_t))!;
        _positions[index] = Offset(newX, newY);
        _opacities[index] = lerpDouble(_opacities[index] ?? 1.0, opacity, _t)!;
      }

      setState(() {});
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
    MoveDirection moveDirection = MoveDirection.right,
  }) async {
    Color getDotColor(PuzzleDotModel dot) {
      Color color;
      if (_model.imageMode) {
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

    final pendingPoints = _model.dots.where((d) {
      final index = d.globalCorrectTile.index;
      final c = _colors[index];
      final newColor = getDotColor(d);
      return c != newColor;
    }).toList();

    listener() {
      final _t = duration == Duration.zero ? t : _animationControllerColor.value;

      final dots = pendingPoints.where((dot) {
        switch (moveDirection) {
          case MoveDirection.up:
            final y = dot.subTile.y + math.cos(dot.subTile.x);
            final p = (y / _model.innerDots).clamp(0.0, 1.0);
            return (1 - p) <= _t;
          case MoveDirection.down:
            final y = dot.subTile.y + math.cos(dot.subTile.x);
            final p = (y / _model.innerDots).clamp(0.0, 1.0);
            return p <= _t;
          case MoveDirection.left:
            final x = dot.subTile.x + math.sin(dot.subTile.y);
            final p = (x / _model.innerDots).clamp(0.0, 1.0);
            return (1 - p) <= _t;
          case MoveDirection.right:
            final x = dot.subTile.x + math.sin(dot.subTile.y);
            final p = (x / _model.innerDots).clamp(0.0, 1.0);
            return p <= _t;
        }
      }).toList();

      for (var dot in dots) {
        final index = dot.globalCorrectTile.index;
        _colors[index] = getDotColor(dot);
      }
      setState(() {});
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
      if (_model.imageMode) {
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
      final center = Offset(
        (_model.size * _model.innerDots * 0.5),
        (_model.size * _model.innerDots * 0.5),
      );

      final dots = _model.dots.where((dot) {
        final x = dot.globalCurrentTile.x;
        final y = dot.globalCurrentTile.y;
        final p = Offset(x.toDouble(), y.toDouble());
        final distance = (p - center).distance;
        return (distance / (_model.size * _model.innerDots)) <= _t;
      }).toList();

      for (var dot in dots) {
        final index = dot.globalCorrectTile.index;
        _colors[index] = getDotColor(dot);
      }
      setState(() {});
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

  Future<void> sort() async {
    // if (_model.isCompleted) return;
    // final PuzzleService service = GetIt.I.get();
    // service.sort(_model);
    // service.updateCorrectDotsColor(_model, _model.dots);
    // await _animateDotsColor(duration: _moveDuration);
  }

  reset() {
    final PuzzleService service = GetIt.I.get();
    _model = service.reset(_model);
    widget.onChanged?.call(_model.moves, _model.correctTileCount);
    _animateDotsPosition(duration: _moveDuration);
    _animateDotsColor(duration: Duration.zero);
  }

  convertToImage() {
    if (_model.imageMode) return;
    final PuzzleService service = GetIt.I.get();
    _model = service.convertToImage(_model);
    _animateToggleMode(duration: _colorDuration);
  }

  convertToNumbers() {
    if (!_model.imageMode) return;
    final PuzzleService service = GetIt.I.get();
    _model = service.convertToNumbers(_model);
    _animateToggleMode(duration: _colorDuration);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _constraints = constraints;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (e) {
            if (kIsWeb) {
              _throttle.value = e.localPosition;
            }
          },
          onHover: (e) {
            if (kIsWeb) {
              _throttle.value = e.localPosition;
            }
          },
          onExit: (e) {
            if (kIsWeb) {
              _throttle.setValue(null);
              _onPointerExit();
            }
          },
          child: Listener(
            onPointerDown: (e) {
              _throttle.value = e.localPosition;
            },
            onPointerMove: (e) {
              _throttle.value = e.localPosition;
            },
            onPointerUp: (e) {
              _throttle.setValue(null);
              _onPointerUp(close: !kIsWeb);
            },
            child: CustomPaint(
              willChange: true,
              painter: PuzzleDotsPainter(
                puzzle: _model,
                colors: _colors,
                positions: _positions,
                opacities: _opacities,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),
        );
      },
    );
  }
}
