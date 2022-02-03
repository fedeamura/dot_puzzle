import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final int size;

  BackgroundPainter({required this.size});

  @override
  void paint(Canvas canvas, Size _size) {
    final w = _size.width / size;
    final h = _size.height / size;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        bool drawBlack;
        if (i % 2 == 0) {
          drawBlack = j % 2 == 0;
        } else {
          drawBlack = j % 2 != 0;
        }

        final left = w * i;
        final top = h * j;
        canvas.drawRect(
          Rect.fromLTWH(left, top, w, h),
          Paint()..color = !drawBlack ? Colors.grey.shade100 : Colors.grey.shade200,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.size != size;
  }
}
