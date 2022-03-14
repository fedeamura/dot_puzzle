import 'package:dot_puzzle/model/position.dart';
import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/service/audio/_interface.dart';
import 'package:dot_puzzle/service/vibration/_interface.dart';
import 'package:dot_puzzle/widget/common/animated_dot_count_down/index.dart';
import 'package:dot_puzzle/widget/common/animated_fade_visibility/index.dart';
import 'package:dot_puzzle/widget/common/puzzle/controller.dart';
import 'package:dot_puzzle/widget/common/puzzle/index.dart';
import 'package:dot_puzzle/widget/screen/home/completed.dart';
import 'package:dot_puzzle/widget/screen/home/panel.dart';
import 'package:dot_puzzle/widget/screen/home/responsive_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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

  bool _counting = true;
  bool _countDownVisible = true;
  bool _puzzleCompletedVisible = false;
  final _countDownKey = GlobalKey<AnimatedDotCountDownState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _onButtonShufflePressed();
    });
  }

  _onButtonSortPressed() {
    _puzzleController.sort();
  }

  _onButtonPlayAgainPressed() {
    _puzzleController.shuffle();
    _onButtonShufflePressed();
  }

  _onButtonShufflePressed() {
    setState(() {
      _puzzleCompletedVisible = false;
      _counting = true;
      _countDownVisible = true;
    });

    _countDownKey.currentState?.start(
      3,
      onTick: (v) {
        final VibrationService vibrationService = GetIt.I.get();
        vibrationService.vibrate(duration: const Duration(milliseconds: 100), amplitude: 10);

        final AudioService audioService = GetIt.I.get();
        audioService.playAsset("assets/audio/tile_move.mp3");

        _puzzleController.shuffle();
      },
      onReady: () {
        setState(() {
          _counting = false;
          _countDownVisible = false;
        });
      },
    );
  }

  _onButtonTogglePressed() {
    if (_puzzleController.imageMode) {
      _puzzleController.convertToNumbers();
    } else {
      _puzzleController.convertToImage();
    }
    setState(() {});
  }

  _onPuzzleTap({
    required PuzzleModel model,
    required PositionModel<int> position,
    required bool moved,
    required bool successMoved,
  }) {
    final VibrationService vibrationService = GetIt.I.get();
    vibrationService.vibrate(duration: const Duration(milliseconds: 100), amplitude: 10);

    if (moved) {
      final AudioService audioService = GetIt.I.get();
      audioService.playAsset("assets/audio/tile_move.mp3");
    }
  }

  _onPuzzleChanged(PuzzleModel model) async {
    setState(() {
      _moves = model.moves;
      _correct = model.correctTilesLeft;
    });

    if (model.isCompleted) {
      await Future.delayed(const Duration(milliseconds: 500));
      _puzzleController.explode(duration: const Duration(milliseconds: 1500));
      setState(() {
        _puzzleCompletedVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Puzzle and panels
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _countDownVisible || _puzzleCompletedVisible,
                child: ResponsiveContainer(
                  puzzle: Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Puzzle(
                            controller: _puzzleController,
                            key: _key,
                            onChanged: _onPuzzleChanged,
                            onPuzzleTap: _onPuzzleTap,
                          ),
                        ),
                      ),
                    ],
                  ),
                  panelVisible: !_counting && !_puzzleCompletedVisible,
                  leftPanel: ScreenHomePanel(
                    moves: _moves,
                    correct: _correct,
                    imageMode: _puzzleController.imageMode,
                    onResetPressed: _onButtonShufflePressed,
                    onSortPressed: _onButtonSortPressed,
                    onImagePressed: _onButtonTogglePressed,
                  ),
                  bottomPanel: ScreenHomePanel(
                    moves: _moves,
                    correct: _correct,
                    imageMode: _puzzleController.imageMode,
                    onResetPressed: _onButtonShufflePressed,
                    onSortPressed: _onButtonSortPressed,
                    onImagePressed: _onButtonTogglePressed,
                  ),
                ),
              ),
            ),

            // Countdown
            Positioned.fill(
              child: AnimatedFadeVisibility(
                visible: _countDownVisible,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withOpacity(1.0),
                          Colors.black.withOpacity(0.0),
                        ],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(64),
                      child: AnimatedDotCountDown(key: _countDownKey),
                    ),
                  ),
                ),
              ),
            ),

            // Puzzle completed
            Positioned.fill(
              child: PuzzleCompleted(
                visible: _puzzleCompletedVisible,
                moves: _moves,
                onPlayAgainPressed: _onButtonPlayAgainPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
