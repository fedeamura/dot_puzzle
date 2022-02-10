import 'package:dot_puzzle/core/responsive.dart';
import 'package:flutter/material.dart';

class ScreenHomeLeftPanel extends StatelessWidget {
  final int moves;
  final int correct;
  final Function()? onResetPressed;

  const ScreenHomeLeftPanel({Key? key, required this.moves, required this.correct, this.onResetPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final spacing = ResponsiveUtils.calculate(
        constraints,
        horizontal: false,
        small: (constraints) => 16.0,
        medium: (constraints) => 32.0,
        large: (constraints) => 64.0,
        xl: (constraints) => 128.0,
      );

      return Container(
        padding: EdgeInsets.only(left: MediaQuery.of(context).padding.left),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    "$moves moves | $correct correct",
                    style: Theme.of(context).textTheme.headline5?.copyWith(fontSize: constraints.maxWidth * 0.08),
                  ),
                  SizedBox(height: spacing),
                  ElevatedButton(
                    onPressed: onResetPressed,
                    child: Text("Reset"),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
