import 'dart:developer';

import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';

class CustomBackgroundPainter extends CustomPainter {
  final PerlinNoise perlinNoise;
  final double offset;
  static const _max = 0.5; // maximum noise value
  static const _min = -_max; // minimum noise value

  CustomBackgroundPainter({
    required this.perlinNoise,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    int xCount = 10;
    double radius = ((1 / (xCount)) * 0.5) * size.width;
    int yCount = (size.height / (radius * 2)).floor();

    for (int j = 0; j < yCount; j++) {
      for (int i = 0; i < yCount; i++) {
        final noise = perlinNoise.getPerlin2(
          i.toDouble() + offset,
          j.toDouble(),
        );

        var percentage = ((noise - _min) / (_max - _min)).clamp(0.0, 1.0);

        final c = HSVColor.fromAHSV(1.0, (percentage * 360) % 360, 1.0, 1.0).toColor();

        canvas.drawCircle(
          Offset(
            ((i / xCount) * size.width) + radius,
            ((j / yCount) * size.height) + radius,
          ),
          radius,
          Paint()..color = c,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomBackgroundPainter oldDelegate) {
    return true;
  }
}
