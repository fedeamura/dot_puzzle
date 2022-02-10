import 'package:dot_puzzle/widget/common/animated_count_down/index.dart';
import 'package:dot_puzzle/widget/common/puzzle/controller.dart';
import 'package:dot_puzzle/widget/common/puzzle/index.dart';
import 'package:dot_puzzle/widget/screen/home/bottom_panel.dart';
import 'package:dot_puzzle/widget/screen/home/left_panel.dart';
import 'package:dot_puzzle/widget/screen/home/responsive_container.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final _key = GlobalKey();
  final _puzzleController = PuzzleController();
  int _moves = 0;
  int _correct = 0;

  _onButtonSortPressed() {
    _puzzleController.sort();
  }

  _onButtonShufflePressed() {
    _puzzleController.shuffle();
  }

  _onButtonTogglePressed() {
    if (_puzzleController.imageMode) {
      _puzzleController.convertToNumbers();
    } else {
      _puzzleController.convertToImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom,
          top: MediaQuery.of(context).padding.top,
        ),
        child: ResponsiveContainer(
          appbar: ScreenHomeAppBar(
            onTogglePressed: _onButtonTogglePressed,
          ),
          puzzle: Puzzle(
            controller: _puzzleController,
            key: _key,
            onChanged: (moves, correct) {
              setState(() {
                _moves = moves;
                _correct = correct;
              });
            },
          ),
          leftPanel: ScreenHomeLeftPanel(
            moves: _moves,
            correct: _correct,
            onResetPressed: _onButtonShufflePressed,
          ),
          bottomPanel: ScreenHomeBottomPanel(
            moves: _moves,
            correct: _correct,
            onResetPressed: _onButtonShufflePressed,
          ),
        ),
      ),
    );
  }
}
