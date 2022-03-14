import 'package:dot_puzzle/model/puzzle.dart';
import 'package:flutter/material.dart';

import 'model/move_result.dart';

abstract class PuzzleService {
  Future<void> init();

  PuzzleModel create();

  PuzzleModel sort(PuzzleModel model);

  PuzzleModel reset(PuzzleModel model);

  PuzzleModel convertToImage(PuzzleModel model);

  PuzzleModel convertToNumbers(PuzzleModel model);

  PuzzleMoveResult move(PuzzleModel model, int x, int y);

  Map<int, Color> getNumberRepresentation(int number);
}
