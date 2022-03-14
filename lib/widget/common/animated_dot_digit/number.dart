import 'package:flutter/material.dart';

import 'index.dart';

class AnimatedDotNumber extends StatelessWidget {
  final int number;
  final int minLength;
  final double digitSize;

  const AnimatedDotNumber({
    Key? key,
    required this.number,
    this.minLength = 1,
    this.digitSize = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final digits = number.toString().padLeft(minLength, "0").split("").toList();

    return SizedBox(
      width: digitSize * minLength,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...digits
              .map((e) => SizedBox(
                    width: digitSize,
                    height: digitSize,
                    child: AnimatedDotDigit(digit: int.parse(e)),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
