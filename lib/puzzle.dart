import 'dart:async';
import 'dart:math' as math;

import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/painter.dart';
import 'package:dot_puzzle/puzzle_utils.dart';
import 'package:flutter/material.dart';

import 'model/point.dart';

class PuzzleWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Duration glowDuration;
  final Duration translateDuration;

  const PuzzleWidget({
    Key? key,
    required this.puzzle,
    this.glowDuration = const Duration(milliseconds: 300),
    this.translateDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> with TickerProviderStateMixin {
  final _animationControllers = <String, AnimationController>{};

  // late AnimationController _animationController;

  @override
  void initState() {
    // _animationController = AnimationController(vsync: this);
    // _animationController.addListener(() => setState(() {}));

    for (var point in widget.puzzle.points) {
      final animationController = AnimationController(vsync: this);
      animationController.addListener(() => setState(() {}));

      final position = PuzzleUtils.calculatePosition(point);
      final animationPosition = Tween<Offset>(begin: position, end: position).animate(animationController);
      point.updateAnimationPosition(animationPosition);
      _animationControllers[point.id] = animationController;
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationControllers.forEach((key, value) {
      value.dispose();
    });

    // _animationController.dispose();
    super.dispose();
  }

  bool _animating = false;

  _onTapDown(BoxConstraints constraints, Offset offset) async {
    if (_animating) {
      return;
    }

    _animating = true;

    const delta = 1.0;

    final touchPosition = Offset(
      offset.dx / constraints.maxWidth,
      offset.dy / constraints.maxHeight,
    );

    // Wave
    final nearPoints = <PuzzlePoint>[];
    for (var point in widget.puzzle.points) {
      final pointPosition = point.animationPosition!.value;
      final distance = (touchPosition - pointPosition).distance;

      if (distance < delta) {
        nearPoints.add(point);
        final force = 0.05 * (1 - (distance / delta));
        final x = pointPosition.dx - touchPosition.dx;
        final y = pointPosition.dy - touchPosition.dy;
        final angle = math.atan(y / x) - (pointPosition.dx < touchPosition.dx ? math.pi : 0.0);
        final newPosition = pointPosition + Offset(math.cos(angle) * force, math.sin(angle) * force);
        _animatePoint(point, newPosition, curve: Curves.easeIn, duration: widget.glowDuration);
      } else {
        _animatePoint(point, PuzzleUtils.calculatePosition(point));
      }
    }

    await Future.delayed(widget.glowDuration);

    // Restore waved points to their normal position
    for (var p in nearPoints) {
      _animatePoint(
        p,
        PuzzleUtils.calculatePosition(p),
        duration: widget.glowDuration,
      );
    }

    // Move to new position
    final touchTile = math.Point<int>(
      (touchPosition.dx * widget.puzzle.size).floor(),
      (touchPosition.dy * widget.puzzle.size).floor(),
    );

    final blank = widget.puzzle.blankPosition;

    if (!(blank == touchTile || (blank.x != touchTile.x && blank.y != touchTile.y))) {
      final horizontal = blank.y == touchTile.y;

      bool reverse = false;
      int tileCount = 0;
      int from = 0;
      int to = 0;
      int counter = 0;

      if (horizontal) {
        if (blank.x < touchTile.x) {
          reverse = true;
          tileCount = touchTile.x - blank.x;
          from = blank.x + 1;
          to = touchTile.x;
        } else {
          tileCount = blank.x - touchTile.x;
          from = touchTile.x;
          to = blank.x - 1;
        }
      } else {
        if (blank.y < touchTile.y) {
          reverse = true;
          tileCount = touchTile.y - blank.y;
          from = blank.y + 1;
          to = touchTile.y;
        } else {
          tileCount = blank.y - touchTile.y;
          from = touchTile.y;
          to = blank.y - 1;
        }
      }

      final d = (widget.translateDuration.inMilliseconds / (widget.puzzle.innerPoints)).floor();

      int inverseI = 0;
      for (int i = from; i <= to; i++) {
        int tileIndex = i;
        if (!reverse) {
          tileIndex = to - inverseI;
          inverseI++;
        }

        int inverseLine = 0;
        for (int line = 0; line < widget.puzzle.innerPoints; line++) {
          int lineIndex = line;
          if (!reverse) {
            lineIndex = widget.puzzle.innerPoints - inverseLine - 1;
            inverseLine++;
          }

          List<PuzzlePoint> linePoints;
          if (horizontal) {
            linePoints = widget.puzzle.points.where((e) => e.currentY == blank.y && e.currentX == tileIndex && e.subY == lineIndex).toList();
          } else {
            linePoints = widget.puzzle.points.where((e) => e.currentX == blank.x && e.currentY == tileIndex && e.subX == lineIndex).toList();
          }

          for (var p in linePoints) {
            final newX = p.currentX + (!horizontal ? 0 : (reverse ? -1 : 1));
            final newY = p.currentY + (horizontal ? 0 : (reverse ? -1 : 1));
            p.updateCurrentPosition(currentX: newX, currentY: newY);
            final newPosition = PuzzleUtils.calculatePosition(p, x: newX, y: newY);

            Future.delayed(Duration(milliseconds: (d * counter * 0.5).floor())).then((value) {
              _animatePoint(p, newPosition, duration: Duration(milliseconds: d));
            });
          }

          counter++;
        }
      }

      final blankPoints = widget.puzzle.points.where((e) => e.isBlank).toList();
      for (var p in blankPoints) {
        final newX = touchTile.x;
        final newY = touchTile.y;
        p.updateCurrentPosition(currentX: newX, currentY: newY);
        final newPosition = PuzzleUtils.calculatePosition(p, x: newX, y: newY);
        _animatePoint(p, newPosition);
      }

      await Future.delayed(Duration(milliseconds: (widget.translateDuration.inMilliseconds * tileCount * 0.5).floor()));
    }

    _animating = false;
  }

  _animatePoint(
    PuzzlePoint point,
    Offset position, {
    double start = 0.0,
    double end = 1.0,
    Curve curve = Curves.decelerate,
    Duration duration = Duration.zero,
  }) {
    final controller = _animationControllers[point.id];
    if (controller == null) return;

    final animation = point.animationPosition;
    if (animation == null) return;

    final newAnimation = Tween<Offset>(
      begin: animation.value,
      end: position,
    ).animate(CurvedAnimation(parent: controller, curve: Interval(start, end, curve: curve)));
    point.updateAnimationPosition(newAnimation);

    controller.reset();
    controller.duration = duration;
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return GestureDetector(
          onTapDown: (d) => _onTapDown(c, d.localPosition),
          child: CustomPaint(
            painter: DotPainter(points: widget.puzzle.points),
            child: Container(),
          ),
        );
      },
    );
  }
}
