import 'package:dot_puzzle/model/position.dart';
import 'package:dot_puzzle/model/puzzle_dot.dart';

import 'package:equatable/equatable.dart';

class PuzzleModel extends Equatable {
  final List<PuzzleDotModel> dots;
  final int size;
  final int innerDots;
  final bool imageMode;
  final int moves;

  const PuzzleModel({
    required this.dots,
    required this.size,
    required this.innerDots,
    required this.imageMode,
    required this.moves,
  });

  PuzzleModel copyWith({
    List<PuzzleDotModel>? dots,
    bool? imageMode,
    int? moves,
  }) {
    return PuzzleModel(
      dots: dots ?? this.dots,
      size: size,
      innerDots: innerDots,
      imageMode: imageMode ?? this.imageMode,
      moves: moves ?? this.moves,
    );
  }

  PositionModel<int>? get whiteTilePosition {
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        if (!dots.any((e) => e.currentTile.x == i && e.currentTile.y == j)) {
          return PositionModel(x: i, y: j);
        }
      }
    }

    return null;
  }

  bool isInCorrectPosition(int x, int y) {
    final firstDots = dots.where((e) => e.subTile.index == 0).toList();
    return firstDots.where((e) => e.currentTile.x == x && e.currentTile.y == y && e.isInCorrectPosition).isNotEmpty;
  }

  bool canMove(int x, int y) {
    final touchTilePosition = PositionModel<int>(x: x, y: y);
    final white = whiteTilePosition;
    if (white == null) return false;
    if (white == touchTilePosition) return false;
    return whiteTilePosition!.x == touchTilePosition.x || whiteTilePosition!.y == touchTilePosition.y;
  }

  List<PuzzleDotModel> getDots(int x, int y) {
    return dots.where((e) => e.currentTile.x == x && e.currentTile.y == y).toList();
  }

  bool get isCompleted {
    final firstDots = dots.where((e) => e.subTile.index == 0).toList();
    return !firstDots.any((e) => !e.isInCorrectPosition);
  }

  int get correctTileCount {
    int count = 0;
    for (int j = 0; j < size; j++) {
      for (int i = 0; i < size; i++) {
        if (isInCorrectPosition(i, j)) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  List<Object?> get props => [dots, size, innerDots, imageMode, moves];
}
