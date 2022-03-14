// ignore_for_file: invalid_use_of_protected_member

import 'dart:ui';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dot_puzzle/core/list.dart';
import 'package:dot_puzzle/core/math.dart';
import 'package:dot_puzzle/service/vibration/_interface.dart';
import 'package:dot_puzzle/widget/common/dot_button/painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;

class DotButton extends StatefulWidget {
  final FocusNode? focusNode;
  final Color? color;
  final double width;
  final double height;
  final Function()? onPressed;
  final Widget child;
  final double force;

  final bool vibrate;

  const DotButton({
    Key? key,
    this.focusNode,
    this.color,
    required this.width,
    required this.height,
    this.onPressed,
    required this.child,
    this.force = 0.05,
    this.vibrate = true,
  }) : super(key: key);

  @override
  _DotButtonState createState() => _DotButtonState();
}

class _DotButtonState extends State<DotButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late int _xCount;
  late int _yCount;

  var _positions = <int, Offset>{};
  var _opacities = <int, double>{};

  late Throttle<Offset?> _throttle;
  Offset? _touchPosition;
  DateTime? _touchStartAt;

  Duration get _touchDownDuration => const Duration(milliseconds: 500);

  Duration get _touchUpDuration => const Duration(milliseconds: 150);

  Duration get _hoverDuration => Duration(milliseconds: ((1 / 20) * 1000).floor());

  @override
  void initState() {
    _throttle = Throttle<Offset?>(_hoverDuration, initialValue: null);
    _throttle.values.listen((event) {
      if (event != null) {
        _onPointerMove(event);
      }
    });

    _animationController = AnimationController(vsync: this);

    _xCount = (widget.width / 5).floor();
    _yCount = (widget.height / 5).floor();

    for (int j = 0; j < _yCount; j++) {
      for (int i = 0; i < _xCount; i++) {
        final index = ListUtils.getIndex(i, j, _xCount);
        _positions[index] = Offset(i / _xCount, j / _yCount);
      }
    }

    _animateDotsPosition();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _onPointerMove(Offset position) {
    _touchPosition = position;

    if (_touchStartAt == null) {
      _touchStartAt = DateTime.now();

      _animateDotsPosition(
        focusPosition: Offset(_touchPosition!.dx / widget.width, _touchPosition!.dy / widget.height),
        duration: _touchDownDuration,
      );
    } else {
      final millis = DateTime.now().millisecondsSinceEpoch - (_touchStartAt?.millisecondsSinceEpoch ?? 0);
      double t = 1.0;
      if (millis < _touchDownDuration.inMilliseconds) {
        t = millis / _touchDownDuration.inMilliseconds;
      }

      _animateDotsPosition(
        focusPosition: Offset(_touchPosition!.dx / widget.width, _touchPosition!.dy / widget.height),
        t: t,
      );
    }
  }

  _onPointerExit() {
    _touchStartAt = null;
    _animateDotsPosition(duration: _touchDownDuration);
  }

  _onPointerUp({bool close = true}) async {
    if (_touchPosition == null || _touchStartAt == null) {
      return;
    }

    final focusPosition = Offset(_touchPosition!.dx / widget.width, _touchPosition!.dy / widget.height);
    final millisecondsFromStart = DateTime.now().millisecondsSinceEpoch - (_touchStartAt?.millisecondsSinceEpoch ?? 0);
    if (millisecondsFromStart < 300) {
      await _animateDotsPosition(
        focusPosition: focusPosition,
        duration: _touchUpDuration,
      );
    }

    _touchStartAt = null;

    _animateDotsPosition(
      duration: _touchDownDuration,
      focusPosition: close ? null : focusPosition,
    );
  }

  _animateDotsPosition({
    Offset? focusPosition,
    Duration duration = Duration.zero,
    double t = 1.0,
  }) async {
    listener() {
      final _t = duration == Duration.zero ? t : _animationController.value;
      const delta = 1.5;
      var f = widget.force;
      const shimmer = 0.3;
      var ar = widget.width / widget.height;

      for (int j = 0; j < _yCount; j++) {
        for (int i = 0; i < _xCount; i++) {
          final index = ListUtils.getIndex(i, j, _xCount);

          final currentPosition = _positions[index] ?? Offset.zero;
          var newPosition = Offset(i / _xCount, j / _yCount);

          double opacity = 1.0;
          if (focusPosition != null) {
            final distance = (focusPosition - currentPosition).distance;
            if (distance < delta) {
              final distancePercentage = distance / delta;
              final force = f * (1 - (distancePercentage));
              final x = (newPosition.dx - focusPosition.dx);
              final y = (newPosition.dy - focusPosition.dy) / ar;
              final angle = math.atan(y / x) - (newPosition.dx < focusPosition.dx ? math.pi : 0.0);
              newPosition = newPosition + Offset(math.cos(angle) * force, math.sin(angle) * force);

              if (distancePercentage < shimmer) {
                opacity = Curves.easeInOut.transform(MathUtils.map(distancePercentage, 0, shimmer, 0.0, 1.0));
              }
            }
          }

          _positions[index] = Offset.lerp(currentPosition, newPosition, _t)!;
          _opacities[index] = lerpDouble(_opacities[index] ?? 1.0, opacity, _t)!;
        }
      }

      _positions = Map<int, Offset>.from(_positions);
      _opacities = Map<int, double>.from(_opacities);
      setState(() {});
    }

    _animationController.stop();
    _animationController.reset();
    _animationController.clearListeners();

    if (duration == Duration.zero) {
      listener();
    } else {
      _animationController.addListener(listener);
      _animationController.duration = duration;
      await _animationController.forward(from: 0.0);
    }
  }

  _onPressed() async {
    final VibrationService vibrationService = GetIt.I.get();
    vibrationService.vibrate(duration: const Duration(milliseconds: 100), amplitude: 10);

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: DotButtonPainter(
          color: widget.color ?? Colors.grey.shade800,
          positions: _positions,
          length: _xCount,
          opacities: _opacities,
        ),
        child: MouseRegion(
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
            child: RawMaterialButton(
              padding: EdgeInsets.zero,
              focusNode: widget.focusNode,
              hoverColor: Colors.transparent,
              fillColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              elevation: 0,
              disabledElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              hoverElevation: 0,
              onPressed: _onPressed,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
