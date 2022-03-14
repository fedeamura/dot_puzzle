import 'package:dot_puzzle/core/responsive.dart';
import 'package:dot_puzzle/widget/common/animated_dot_digit/index.dart';
import 'package:dot_puzzle/widget/common/button/index.dart';
import 'package:flutter/material.dart';

class ScreenHomePanel extends StatelessWidget {
  final Function()? onResetPressed;
  final Function()? onSortPressed;
  final Function()? onImagePressed;
  final bool imageMode;
  final int moves;
  final int correct;

  const ScreenHomePanel({
    Key? key,
    this.onResetPressed,
    this.moves = 0,
    this.correct = 0,
    this.onSortPressed,
    this.onImagePressed,
    this.imageMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movesDigit = moves.toString().padLeft(3, "0").split("").toList();
    final correctDigit = correct.toString().padLeft(2, "0").split("").toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = ResponsiveUtils.calculate(
          constraints,
          horizontal: false,
          small: (constraints) => 16.0,
          medium: (constraints) => 32.0,
          large: (constraints) => 64.0,
          xl: (constraints) => 128.0,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ...movesDigit
                          .map((e) => SizedBox(
                                width: 20,
                                height: 20,
                                child: AnimatedDotDigit(digit: int.parse(e)),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 80,
                  child: Text("MOVES"),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ...correctDigit
                          .map((e) => SizedBox(
                                width: 20,
                                height: 20,
                                child: AnimatedDotDigit(digit: int.parse(e)),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 80,
                  child: Text("TILES"),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: "RESET",
                      onPressed: onResetPressed,
                      textColor: Colors.white,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 16.0),
                    // CustomButton(
                    //   text: "SORT",
                    //   onPressed: onSortPressed,
                    //   textColor: Colors.white,
                    //   color: Colors.grey.shade800,
                    // ),
                    // const SizedBox(width: 16.0),
                    CustomButton(
                      text: "IMAGE",
                      onPressed: onImagePressed,
                      textColor: imageMode ? Colors.black : Colors.white,
                      color: imageMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
