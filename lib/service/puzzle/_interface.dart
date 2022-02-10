import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:flutter/material.dart';

abstract class PuzzleService {
  Future<void> init();

  PuzzleModel create();

  PuzzleModel sort(PuzzleModel model);

  PuzzleModel reset(PuzzleModel model);

  PuzzleModel convertToImage(PuzzleModel model);

  PuzzleModel convertToNumbers(PuzzleModel model);

  Map<int, Color> getNumberRepresentation(int number);
}
