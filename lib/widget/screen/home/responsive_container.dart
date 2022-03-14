import 'package:dot_puzzle/core/responsive.dart';
import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget puzzle;
  final Widget leftPanel;
  final Widget bottomPanel;
  final bool panelVisible;

  const ResponsiveContainer({
    Key? key,
    required this.puzzle,
    required this.leftPanel,
    required this.bottomPanel,
    this.panelVisible = true,
  }) : super(key: key);

  bool _leftPanelVisible(BoxConstraints constraints) {
    if (!panelVisible) return false;

    return ResponsiveUtils.calculate(
      constraints,
      small: (c) => false,
      medium: (c) => true,
      large: (c) => true,
      xl: (c) => true,
    );
  }

  bool _bottomPanelVisible(BoxConstraints constraints) {
    if (!panelVisible) return false;
    return !_leftPanelVisible(constraints);
  }

  double _leftPanelWidth(BoxConstraints constraints) {
    final val = constraints.maxWidth * 0.35;
    return val.clamp(200.0, 400.0);
  }

  double _bottomPanelHeight(BoxConstraints constraints) {
    final val = constraints.maxHeight * 0.2;
    return val.clamp(200.0, 400.0);
  }

  double _boardSize(BoxConstraints constraints) {
    final marginLeft = _leftPanelVisible(constraints) ? _leftPanelWidth(constraints) : 0.0;
    final marginBottom = _bottomPanelVisible(constraints) ? _bottomPanelHeight(constraints) : 0.0;
    final width = constraints.maxWidth - marginLeft;
    final height = constraints.maxHeight - marginBottom;
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
        final boardSize = _boardSize(constraints);
        final leftPanelVisible = _leftPanelVisible(constraints);
        final leftPanelWidth = leftPanelVisible ? _leftPanelWidth(constraints) : 0.0;
        final bottomPanelVisible = _bottomPanelVisible(constraints);
        final bottomPanelHeight = bottomPanelVisible ? _bottomPanelHeight(constraints) : 0.0;

        double boardLeft = leftPanelWidth + ((constraints.maxWidth - leftPanelWidth) - boardSize) * 0.5;
        double boardTop = (((constraints.maxHeight - bottomPanelHeight) - boardSize) * 0.5);

        return Stack(
          children: [
            // Left panel
            AnimatedPositioned(
              duration: d,
              left: leftPanelVisible ? 0.0 : -_leftPanelWidth(constraints),
              top: 0.0,
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
