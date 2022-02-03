import 'package:dot_puzzle/puzzle.dart';
import 'package:dot_puzzle/puzzle_utils.dart';
import 'package:flutter/material.dart';

import 'model/puzzle.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  late Puzzle _puzzle;

  @override
  void initState() {
    _puzzle = PuzzleUtils.create();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: PuzzleWidget(
              puzzle: _puzzle,
              translateDuration: const Duration(milliseconds: 1000),
              glowDuration: const Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
  }
}
