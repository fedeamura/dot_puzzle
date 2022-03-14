import 'package:confetti/confetti.dart';
import 'package:dot_puzzle/widget/common/animated_dot_digit/number.dart';
import 'package:dot_puzzle/widget/common/animated_fade_visibility/index.dart';
import 'package:dot_puzzle/widget/common/dot_button/index.dart';
import 'package:flutter/material.dart';

class PuzzleCompleted extends StatefulWidget {
  final int moves;
  final Function()? onPlayAgainPressed;
  final bool visible;

  const PuzzleCompleted({Key? key, this.moves = 0, this.onPlayAgainPressed, this.visible = false}) : super(key: key);

  @override
  State<PuzzleCompleted> createState() => _PuzzleCompletedState();
}

class _PuzzleCompletedState extends State<PuzzleCompleted> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (widget.visible) {
        _start();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(PuzzleCompleted oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _start();
    } else {
      _stop();
    }
  }

  _start() {
    _confettiController.play();
  }

  _stop() {
    _confettiController.stop();
  }

  @override
  Widget build(BuildContext context) {
    const emissionFrequency = 0.2;

    return AnimatedFadeVisibility(
      visible: widget.visible,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: const Offset(-20, -20),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 0.785398,
                emissionFrequency: emissionFrequency,
                gravity: 0.3,
                shouldLoop: true,
                maxBlastForce: 10,
                minBlastForce: 9,
                numberOfParticles: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(20, -20),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708,
                emissionFrequency: emissionFrequency,
                gravity: 0.3,
                shouldLoop: true,
                maxBlastForce: 10,
                minBlastForce: 9,
                numberOfParticles: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: const Offset(20, -20),
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 2.35619,
                emissionFrequency: emissionFrequency,
                gravity: 0.3,
                shouldLoop: true,
                maxBlastForce: 10,
                minBlastForce: 9,
                numberOfParticles: 1,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Puzzle completed",
                  style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      alignment: Alignment.centerRight,
                      child: AnimatedDotNumber(
                        minLength: 3,
                        number: widget.moves,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        "MOVES",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                DotButton(
                  width: 180,
                  height: 40,
                  child: const Text("PLAY AGAIN"),
                  onPressed: widget.onPlayAgainPressed,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
