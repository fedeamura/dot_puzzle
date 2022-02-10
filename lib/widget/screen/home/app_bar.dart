import 'package:dot_puzzle/core/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/animated_count_down/index.dart';

class ScreenHomeAppBar extends StatelessWidget {
  final Function()? onTogglePressed;

  const ScreenHomeAppBar({Key? key, this.onTogglePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final horizontalPadding = ResponsiveUtils.calculate(
        constraints,
        small: (constraints) => 32.0,
        medium: (constraints) => 32.0,
        large: (constraints) => 32.0,
        xl: (constraints) => 64.0,
      );

      final iconMargin = ResponsiveUtils.calculate(
        constraints,
        small: (constraints) => 8.0,
        medium: (constraints) => 16.0,
        large: (constraints) => 32.0,
        xl: (constraints) => 32.0,
      );
      return Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            Container(
              width: constraints.maxHeight * 0.7,
              height: constraints.maxHeight * 0.7,
              color: Colors.red,
            ),
            SizedBox(width: iconMargin),
            Expanded(
              child: Text(
                "Dot Puzzle",
                style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: constraints.maxHeight * 0.4),
              ),
            ),
            ElevatedButton(
              onPressed: onTogglePressed,
              child: const Text("TOGGLE"),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       CupertinoPageRoute(
            //         builder: (context) => ScreenCountDown(
            //           onReady: () {
            //             Navigator.of(context).pop();
            //           },
            //         ),
            //       ),
            //     );
            //   },
            //   child: const Text("COUNTDOWN"),
            // )
          ],
        ),
      );
    });
  }
}

class ScreenCountDown extends StatelessWidget {
  final Function()? onReady;

  const ScreenCountDown({Key? key, this.onReady}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedPixelCountDown(
          onReady: onReady,
        ),
      ),
    );
  }
}
