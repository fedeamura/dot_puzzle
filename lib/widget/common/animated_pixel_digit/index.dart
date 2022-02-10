import 'package:dot_puzzle/core/list.dart';
import 'package:flutter/material.dart';

import 'painter.dart';

class AnimatedPixelDigit extends StatefulWidget {
  final int digit;
  final Duration duration;

  const AnimatedPixelDigit({
    Key? key,
    required this.digit,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  _AnimatedPixelDigitState createState() => _AnimatedPixelDigitState();
}

class _AnimatedPixelDigitState extends State<AnimatedPixelDigit> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _colors = <int, Color>{};
  final _positions = <int, Offset>{};
  final int _size = 7;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);

    for (int j = 0; j < _size; j++) {
      for (int i = 0; i < _size; i++) {
        final index = ListUtils.getIndex(i, j, _size);
        _colors[index] = Colors.white;
        _positions[index] = Offset(i / _size, j / _size);
      }
    }
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _animate(duration: Duration.zero);
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedPixelDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      _animate(duration: widget.duration);
    }
  }

  _animate({
    Duration duration = Duration.zero,
  }) async {
    listener() {
      final t = duration == Duration.zero ? 1.0 : _animationController.value;

      switch (widget.digit) {
        case 0:
          {
            // line 0
            _updateDot(x: 0, y: 0, newX: 1, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, newX: 4, t: t);
            _updateDot(x: 6, y: 0, newX: 4, t: t);

            // line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // line 3
            _updateDot(x: 0, y: 2, t: t);
            _updateDot(x: 1, y: 2, t: t);
            _updateDot(x: 2, y: 2, newX: 1, t: t);
            _updateDot(x: 3, y: 2, newX: 4, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, t: t);
            _updateDot(x: 6, y: 2, newX: 5, t: t);

            // line 4
            _updateDot(x: 0, y: 3, t: t);
            _updateDot(x: 1, y: 3, t: t);
            _updateDot(x: 2, y: 3, newX: 1, t: t);
            _updateDot(x: 3, y: 3, newX: 4, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, t: t);
            _updateDot(x: 6, y: 3, newX: 5, t: t);

            // line 5
            _updateDot(x: 0, y: 4, t: t);
            _updateDot(x: 1, y: 4, t: t);
            _updateDot(x: 2, y: 4, newX: 1, t: t);
            _updateDot(x: 3, y: 4, newX: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // line 6
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // line 7
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;

        case 1:
          {
            // line 0
            _updateDot(x: 0, y: 0, newX: 2, t: t);
            _updateDot(x: 1, y: 0, newX: 2, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, newX: 3, t: t);
            _updateDot(x: 5, y: 0, newX: 3, t: t);
            _updateDot(x: 6, y: 0, newX: 3, t: t);

            // line 1
            _updateDot(x: 0, y: 1, newX: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, t: t);
            _updateDot(x: 3, y: 1, t: t);
            _updateDot(x: 4, y: 1, newX: 3, t: t);
            _updateDot(x: 5, y: 1, newX: 3, t: t);
            _updateDot(x: 6, y: 1, newX: 3, t: t);

            // line 2
            _updateDot(x: 0, y: 2, newX: 2, t: t);
            _updateDot(x: 1, y: 2, newX: 2, t: t);
            _updateDot(x: 2, y: 2, t: t);
            _updateDot(x: 3, y: 2, t: t);
            _updateDot(x: 4, y: 2, newX: 3, t: t);
            _updateDot(x: 5, y: 2, newX: 3, t: t);
            _updateDot(x: 6, y: 2, newX: 3, t: t);

            // line 3
            _updateDot(x: 0, y: 3, newX: 2, t: t);
            _updateDot(x: 1, y: 3, newX: 2, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, newX: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 3, t: t);
            _updateDot(x: 6, y: 3, newX: 3, t: t);

            // line 4
            _updateDot(x: 0, y: 4, newX: 2, t: t);
            _updateDot(x: 1, y: 4, newX: 2, t: t);
            _updateDot(x: 2, y: 4, t: t);
            _updateDot(x: 3, y: 4, t: t);
            _updateDot(x: 4, y: 4, newX: 3, t: t);
            _updateDot(x: 5, y: 4, newX: 3, t: t);
            _updateDot(x: 6, y: 4, newX: 3, t: t);

            // line 5
            _updateDot(x: 0, y: 5, newX: 2, t: t);
            _updateDot(x: 1, y: 5, newX: 2, t: t);
            _updateDot(x: 2, y: 5, t: t);
            _updateDot(x: 3, y: 5, t: t);
            _updateDot(x: 4, y: 5, newX: 3, t: t);
            _updateDot(x: 5, y: 5, newX: 3, t: t);
            _updateDot(x: 6, y: 5, newX: 3, t: t);

            // line 6
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;

        case 2:
          {
            // Line 0
            _updateDot(x: 0, y: 0, newX: 1, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, newX: 4, t: t);
            _updateDot(x: 6, y: 0, newX: 4, t: t);

            // Line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // Line 3
            _updateDot(x: 0, y: 2, newX: 4, t: t);
            _updateDot(x: 1, y: 2, newX: 4, t: t);
            _updateDot(x: 2, y: 2, newX: 4, t: t);
            _updateDot(x: 3, y: 2, newX: 4, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, t: t);
            _updateDot(x: 6, y: 2, newX: 5, t: t);

            // Line 4
            _updateDot(x: 0, y: 3, newX: 2, t: t);
            _updateDot(x: 1, y: 3, newX: 2, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 4, t: t);
            _updateDot(x: 6, y: 3, newX: 4, t: t);

            // Line 5
            _updateDot(x: 0, y: 4, newX: 1, t: t);
            _updateDot(x: 1, y: 4, t: t);
            _updateDot(x: 2, y: 4, t: t);
            _updateDot(x: 3, y: 4, newX: 2, t: t);
            _updateDot(x: 4, y: 4, newX: 2, t: t);
            _updateDot(x: 5, y: 4, newX: 2, t: t);
            _updateDot(x: 6, y: 4, newX: 2, t: t);

            // Line 6
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 1, t: t);
            _updateDot(x: 4, y: 5, newX: 1, t: t);
            _updateDot(x: 5, y: 5, newX: 1, t: t);
            _updateDot(x: 6, y: 5, newX: 1, t: t);

            // Line 7
            _updateDot(x: 0, y: 6, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, t: t);
            _updateDot(x: 6, y: 6, newX: 5, t: t);
          }
          break;

        case 3:
          {
            // Line 0
            _updateDot(x: 0, y: 0, newX: 1, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, newX: 4, t: t);
            _updateDot(x: 6, y: 0, newX: 4, t: t);

            // Line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // Line 2
            _updateDot(x: 0, y: 2, newX: 4, t: t);
            _updateDot(x: 1, y: 2, newX: 4, t: t);
            _updateDot(x: 2, y: 2, newX: 4, t: t);
            _updateDot(x: 3, y: 2, newX: 4, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, t: t);
            _updateDot(x: 6, y: 2, newX: 5, t: t);

            // Line 3
            _updateDot(x: 0, y: 3, newX: 2, t: t);
            _updateDot(x: 1, y: 3, newX: 2, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 4, t: t);
            _updateDot(x: 6, y: 3, newX: 4, t: t);

            // Line 4
            _updateDot(x: 0, y: 4, newX: 4, t: t);
            _updateDot(x: 1, y: 4, newX: 4, t: t);
            _updateDot(x: 2, y: 4, newX: 4, t: t);
            _updateDot(x: 3, y: 4, newX: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // Line 5
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // Line 6
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;

        case 4:
          {
            // Line 0
            _updateDot(x: 0, y: 0, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, newX: 1, t: t);
            _updateDot(x: 3, y: 0, newX: 4, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, t: t);
            _updateDot(x: 6, y: 0, newX: 5, t: t);

            // Line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // Line 2
            _updateDot(x: 0, y: 2, t: t);
            _updateDot(x: 1, y: 2, t: t);
            _updateDot(x: 2, y: 2, newX: 1, t: t);
            _updateDot(x: 3, y: 2, newX: 4, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, t: t);
            _updateDot(x: 6, y: 2, newX: 5, t: t);

            // Line 3
            _updateDot(x: 0, y: 3, t: t);
            _updateDot(x: 1, y: 3, t: t);
            _updateDot(x: 2, y: 3, newX: 1, t: t);
            _updateDot(x: 3, y: 3, newX: 4, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, t: t);
            _updateDot(x: 6, y: 3, newX: 5, t: t);

            // Line 4
            _updateDot(x: 0, y: 4, newX: 1, t: t);
            _updateDot(x: 1, y: 4, t: t);
            _updateDot(x: 2, y: 4, t: t);
            _updateDot(x: 3, y: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // Line 5
            _updateDot(x: 0, y: 5, newX: 4, t: t);
            _updateDot(x: 1, y: 5, newX: 4, t: t);
            _updateDot(x: 2, y: 5, newX: 4, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // Line 5
            _updateDot(x: 0, y: 6, newX: 4, t: t);
            _updateDot(x: 1, y: 6, newX: 4, t: t);
            _updateDot(x: 2, y: 6, newX: 4, t: t);
            _updateDot(x: 3, y: 6, newX: 4, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, t: t);
            _updateDot(x: 6, y: 6, newX: 5, t: t);
          }
          break;

        case 5:
          {
            //line 0
            _updateDot(x: 0, y: 0, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, t: t);
            _updateDot(x: 6, y: 0, newX: 5, t: t);

            //line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 1, t: t);
            _updateDot(x: 4, y: 1, newX: 1, t: t);
            _updateDot(x: 5, y: 1, newX: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 1, t: t);

            //line 2
            _updateDot(x: 0, y: 2, t: t);
            _updateDot(x: 1, y: 2, t: t);
            _updateDot(x: 2, y: 2, t: t);
            _updateDot(x: 3, y: 2, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, newX: 4, t: t);
            _updateDot(x: 6, y: 2, newX: 4, t: t);

            //line 3
            _updateDot(x: 0, y: 3, newX: 4, t: t);
            _updateDot(x: 1, y: 3, newX: 4, t: t);
            _updateDot(x: 2, y: 3, newX: 4, t: t);
            _updateDot(x: 3, y: 3, newX: 4, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, t: t);
            _updateDot(x: 6, y: 3, newX: 5, t: t);

            //line 4
            _updateDot(x: 0, y: 4, newX: 4, t: t);
            _updateDot(x: 1, y: 4, newX: 4, t: t);
            _updateDot(x: 2, y: 4, newX: 4, t: t);
            _updateDot(x: 3, y: 4, newX: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // Line 5
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // Line 6
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;

        case 6:
          {
            //line 0
            _updateDot(x: 0, y: 0, newX: 1, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, newX: 4, t: t);
            _updateDot(x: 6, y: 0, newX: 4, t: t);

            // Line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // Line 2
            _updateDot(x: 0, y: 2, t: t);
            _updateDot(x: 1, y: 2, t: t);
            _updateDot(x: 2, y: 2, newX: 1, t: t);
            _updateDot(x: 3, y: 2, newX: 1, t: t);
            _updateDot(x: 4, y: 2, newX: 1, t: t);
            _updateDot(x: 5, y: 2, newX: 1, t: t);
            _updateDot(x: 6, y: 2, newX: 1, t: t);

            // Line 3
            _updateDot(x: 0, y: 3, t: t);
            _updateDot(x: 1, y: 3, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 4, t: t);
            _updateDot(x: 6, y: 3, newX: 4, t: t);

            // Line 4
            _updateDot(x: 0, y: 4, t: t);
            _updateDot(x: 1, y: 4, t: t);
            _updateDot(x: 2, y: 4, newX: 1, t: t);
            _updateDot(x: 3, y: 4, newX: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // Line 5
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // Line 6
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;

        case 7:
          {
            //line 0
            _updateDot(x: 0, y: 0, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, t: t);
            _updateDot(x: 6, y: 0, newX: 5, t: t);

            //line 1
            _updateDot(x: 0, y: 1, newX: 4, t: t);
            _updateDot(x: 1, y: 1, newX: 4, t: t);
            _updateDot(x: 2, y: 1, newX: 4, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            //line 2
            _updateDot(x: 0, y: 2, newX: 3, t: t);
            _updateDot(x: 1, y: 2, newX: 3, t: t);
            _updateDot(x: 2, y: 2, newX: 3, t: t);
            _updateDot(x: 3, y: 2, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, newX: 4, t: t);
            _updateDot(x: 6, y: 2, newX: 4, t: t);

            // line 3
            _updateDot(x: 0, y: 3, newX: 2, t: t);
            _updateDot(x: 1, y: 3, newX: 2, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, newX: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 3, t: t);
            _updateDot(x: 6, y: 3, newX: 3, t: t);

            // line 4
            _updateDot(x: 0, y: 4, newX: 2, t: t);
            _updateDot(x: 1, y: 4, newX: 2, t: t);
            _updateDot(x: 2, y: 4, t: t);
            _updateDot(x: 3, y: 4, t: t);
            _updateDot(x: 4, y: 4, newX: 3, t: t);
            _updateDot(x: 5, y: 4, newX: 3, t: t);
            _updateDot(x: 6, y: 4, newX: 3, t: t);

            // line 5
            _updateDot(x: 0, y: 5, newX: 2, t: t);
            _updateDot(x: 1, y: 5, newX: 2, t: t);
            _updateDot(x: 2, y: 5, t: t);
            _updateDot(x: 3, y: 5, t: t);
            _updateDot(x: 4, y: 5, newX: 3, t: t);
            _updateDot(x: 5, y: 5, newX: 3, t: t);
            _updateDot(x: 6, y: 5, newX: 3, t: t);

            // line 6
            _updateDot(x: 0, y: 6, newX: 2, t: t);
            _updateDot(x: 1, y: 6, newX: 2, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, newX: 3, t: t);
            _updateDot(x: 5, y: 6, newX: 3, t: t);
            _updateDot(x: 6, y: 6, newX: 3, t: t);
          }
          break;

        case 8:
          {
            //line 0
            _updateDot(x: 0, y: 0, newX: 1, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, newX: 4, t: t);
            _updateDot(x: 6, y: 0, newX: 4, t: t);

            // Line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // Line 2
            _updateDot(x: 0, y: 2, t: t);
            _updateDot(x: 1, y: 2, t: t);
            _updateDot(x: 2, y: 2, newX: 1, t: t);
            _updateDot(x: 3, y: 2, newX: 4, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, t: t);
            _updateDot(x: 6, y: 2, newX: 5, t: t);

            // Line 3
            _updateDot(x: 0, y: 3, newX: 1, t: t);
            _updateDot(x: 1, y: 3, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 4, t: t);
            _updateDot(x: 6, y: 3, newX: 4, t: t);

            // line 4
            _updateDot(x: 0, y: 4, t: t);
            _updateDot(x: 1, y: 4, t: t);
            _updateDot(x: 2, y: 4, newX: 1, t: t);
            _updateDot(x: 3, y: 4, newX: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // line 5
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // line 6
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;

        case 9:
          {
            //line 0
            _updateDot(x: 0, y: 0, newX: 1, t: t);
            _updateDot(x: 1, y: 0, t: t);
            _updateDot(x: 2, y: 0, t: t);
            _updateDot(x: 3, y: 0, t: t);
            _updateDot(x: 4, y: 0, t: t);
            _updateDot(x: 5, y: 0, newX: 4, t: t);
            _updateDot(x: 6, y: 0, newX: 4, t: t);

            // Line 1
            _updateDot(x: 0, y: 1, t: t);
            _updateDot(x: 1, y: 1, t: t);
            _updateDot(x: 2, y: 1, newX: 1, t: t);
            _updateDot(x: 3, y: 1, newX: 4, t: t);
            _updateDot(x: 4, y: 1, t: t);
            _updateDot(x: 5, y: 1, t: t);
            _updateDot(x: 6, y: 1, newX: 5, t: t);

            // Line 2
            _updateDot(x: 0, y: 2, t: t);
            _updateDot(x: 1, y: 2, t: t);
            _updateDot(x: 2, y: 2, newX: 1, t: t);
            _updateDot(x: 3, y: 2, newX: 4, t: t);
            _updateDot(x: 4, y: 2, t: t);
            _updateDot(x: 5, y: 2, t: t);
            _updateDot(x: 6, y: 2, newX: 5, t: t);

            // Line 3
            _updateDot(x: 0, y: 3, newX: 1, t: t);
            _updateDot(x: 1, y: 3, t: t);
            _updateDot(x: 2, y: 3, t: t);
            _updateDot(x: 3, y: 3, t: t);
            _updateDot(x: 4, y: 3, t: t);
            _updateDot(x: 5, y: 3, newX: 4, t: t);
            _updateDot(x: 6, y: 3, newX: 4, t: t);

            // line 4
            _updateDot(x: 0, y: 4, newX: 4, t: t);
            _updateDot(x: 1, y: 4, newX: 4, t: t);
            _updateDot(x: 2, y: 4, newX: 4, t: t);
            _updateDot(x: 3, y: 4, newX: 4, t: t);
            _updateDot(x: 4, y: 4, t: t);
            _updateDot(x: 5, y: 4, t: t);
            _updateDot(x: 6, y: 4, newX: 5, t: t);

            // line 5
            _updateDot(x: 0, y: 5, t: t);
            _updateDot(x: 1, y: 5, t: t);
            _updateDot(x: 2, y: 5, newX: 1, t: t);
            _updateDot(x: 3, y: 5, newX: 4, t: t);
            _updateDot(x: 4, y: 5, t: t);
            _updateDot(x: 5, y: 5, t: t);
            _updateDot(x: 6, y: 5, newX: 5, t: t);

            // line 6
            _updateDot(x: 0, y: 6, newX: 1, t: t);
            _updateDot(x: 1, y: 6, t: t);
            _updateDot(x: 2, y: 6, t: t);
            _updateDot(x: 3, y: 6, t: t);
            _updateDot(x: 4, y: 6, t: t);
            _updateDot(x: 5, y: 6, newX: 4, t: t);
            _updateDot(x: 6, y: 6, newX: 4, t: t);
          }
          break;
      }
      setState(() {});
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

  _updateDot({
    required int x,
    required int y,
    int? newX,
    int? newY,
    Color? color,
    double t = 1.0,
  }) {
    final index = ListUtils.getIndex(x, y, _size);

    final oldColor = _colors[index] ?? Colors.transparent;
    final newColor = color ?? _colors[index] ?? Colors.transparent;
    _colors[index] = Color.lerp(oldColor, newColor, t)!;

    final oldOffset = _positions[index] ?? Offset.zero;
    final newPosition = Offset((newX ?? x) / _size, (newY ?? y) / _size);
    _positions[index] = Offset.lerp(oldOffset, newPosition, t)!;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: true,
      painter: AnimatedPixelDigitPainter(
        colors: _colors,
        positions: _positions,
        size: _size,
      ),
      child: Container(),
    );
  }
}
