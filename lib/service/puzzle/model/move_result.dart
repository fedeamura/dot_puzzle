import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:dot_puzzle/service/puzzle/model/move_direction.dart';

class PuzzleMoveResult {
  final PuzzleModel model;
  final List<PuzzleDotModel> movedDots;
  final List<PuzzleDotModel> newCorrectDots;
  final List<PuzzleDotModel> newIncorrectDots;
  final PuzzleMoveDirection? moveDirection;

  PuzzleMoveResult({
    required this.model,
    this.movedDots = const [],
    this.newCorrectDots = const [],
    this.newIncorrectDots = const [],
    this.moveDirection,
  });
}
