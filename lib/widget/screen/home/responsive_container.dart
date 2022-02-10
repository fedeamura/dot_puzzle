import 'package:dot_puzzle/core/responsive.dart';
import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget appbar;
  final Widget puzzle;
  final Widget leftPanel;
  final Widget bottomPanel;

  const ResponsiveContainer({
    Key? key,
    required this.puzzle,
    required this.appbar,
    required this.leftPanel,
    required this.bottomPanel,
  }) : super(key: key);

  double _appBarHeight(BoxConstraints constraints) {
    return ResponsiveUtils.calculate(
      constraints,
      horizontal: false,
      small: (c) => 50.0,
      medium: (c) => 70.0,
      large: (c) => 100.0,
      xl: (c) => 200.0,
    );
  }

  bool _leftPanelVisible(BoxConstraints constraints) {
    return ResponsiveUtils.calculate(
      constraints,
      small: (c) => false,
      medium: (c) => true,
      large: (c) => true,
      xl: (c) => true,
    );
  }

  double _leftPanelWidth(BoxConstraints constraints) {
    return constraints.maxWidth * 0.35;
  }

  double _bottomPanelHeight(BoxConstraints constraints) {
    return constraints.maxHeight * 0.2;
  }

  double _boardSize(BoxConstraints constraints) {
    final appBarHeight = _appBarHeight(constraints);
    final marginLeft = _leftPanelVisible(constraints) ? _leftPanelWidth(constraints) : 0.0;
    final marginBottom = !_leftPanelVisible(constraints) ? _bottomPanelHeight(constraints) : 0.0;
    final width = constraints.maxWidth - marginLeft;
    final height = constraints.maxHeight - appBarHeight - marginBottom;
    final horizontal = width > height;

    if (horizontal) {
      return height * 0.8;
    } else {
      return width * 0.8;
    }
  }

  @override
  Widget build(BuildContext context) {
    const d = Duration(milliseconds: 200);

    return LayoutBuilder(
      builder: (context, constraints) {
        final appBarHeight = _appBarHeight(constraints);
        final boardSize = _boardSize(constraints);
        final leftPanelVisible = _leftPanelVisible(constraints);
        final leftPanelWidth = leftPanelVisible ? _leftPanelWidth(constraints) : 0.0;
        final bottomPanelVisible = !_leftPanelVisible(constraints);
        final bottomPanelHeight = bottomPanelVisible ? _bottomPanelHeight(constraints) : 0.0;

        double boardLeft = leftPanelWidth + ((constraints.maxWidth - leftPanelWidth) - boardSize) * 0.5;
        double boardTop = appBarHeight + (((constraints.maxHeight - appBarHeight - bottomPanelHeight) - boardSize) * 0.5);

        return Stack(
          children: [
            // App bar
            AnimatedPositioned(
              duration: d,
              left: 0,
              right: 0,
              top: 0,
              height: appBarHeight,
              child: appbar,
            ),

            // Left panel
            AnimatedPositioned(
              duration: d,
              left: leftPanelVisible ? 0.0 : -_leftPanelWidth(constraints),
              top: appBarHeight,
              bottom: 0,
              width: _leftPanelWidth(constraints),
              child: leftPanel,
            ),

            // Bottom panel
            AnimatedPositioned(
              duration: d,
              left: 0,
              right: 0,
              bottom: bottomPanelVisible ? 0.0 : -_bottomPanelHeight(constraints),
              height: _bottomPanelHeight(constraints),
              child: bottomPanel,
            ),

            // Puzzle
            AnimatedPositioned(
              duration: d,
              left: boardLeft,
              top: boardTop,
              width: boardSize,
              height: boardSize,
              child: puzzle,
            ),
          ],
        );
      },
    );
  }
}
