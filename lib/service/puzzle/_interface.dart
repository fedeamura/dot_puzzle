import 'package:dot_puzzle/model/puzzle.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';
import 'package:flutter/material.dart';

abstract class PuzzleService {
  Future<void> init();

  PuzzleModel create({required int size});

  void sort(PuzzleModel model);

  void shuffle(PuzzleModel model);

  void updateCorrectDotsColor(PuzzleModel model, List<PuzzleDotModel> dots, {double t = 1.0});

  void updateDotsColor(PuzzleModel model, List<PuzzleDotModel> dots, {Color? color, double t = 1.0});

  void updateDotsPosition(
    PuzzleModel model, {
    Offset? focusPosition,
    double t = 1.0,
    bool pressed = false,
  });

  void convertToImage(PuzzleModel model);

  void convertToNumbers(PuzzleModel model);
}
