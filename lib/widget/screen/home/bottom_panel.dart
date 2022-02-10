import 'package:dot_puzzle/core/responsive.dart';
import 'package:dot_puzzle/widget/common/animated_pixel_digit/index.dart';
import 'package:flutter/material.dart';

class ScreenHomeBottomPanel extends StatelessWidget {
  final Function()? onResetPressed;
  final int moves;
  final int correct;

  const ScreenHomeBottomPanel({
    Key? key,
    this.onResetPressed,
    this.moves = 0,
    this.correct = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movesDigit = moves.toString().padLeft(2, "0").split("").toList();
    final correctDigit = correct.toString().padLeft(2, "0").split("").toList();

    return LayoutBuilder(builder: (context, constraints) {
      final spacing = ResponsiveUtils.calculate(
        constraints,
        horizontal: false,
        small: (constraints) => 16.0,
        medium: (constraints) => 32.0,
        large: (constraints) => 64.0,
        xl: (constraints) => 128.0,
      );

      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...movesDigit
                  .map((e) => SizedBox(
                        width: constraints.maxHeight * 0.1,
                        height: constraints.maxHeight * 0.1,
                        child: AnimatedPixelDigit(digit: int.parse(e)),
                      ))
                  .toList(),
              const SizedBox(width: 8),
              const Text("MOVES"),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...correctDigit
                  .map((e) => SizedBox(
                        width: constraints.maxHeight * 0.1,
                        height: constraints.maxHeight * 0.1,
                        child: AnimatedPixelDigit(digit: int.parse(e)),
                      ))
                  .toList(),
              const SizedBox(width: 8),
              const Text("CORRECT"),
            ],
          ),
          SizedBox(height: spacing),
          RawMaterialButton(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            fillColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            onPressed: onResetPressed,
            child: Text(
              "RESET",
              style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
            ),
          )
        ],
      );
    });
  }
}
