import 'package:equatable/equatable.dart';

class TileModel extends Equatable {
  final int x;
  final int y;
  final int index;

  TileModel({
    required this.x,
    required this.y,
    required this.index,
  });

  bool isInCorrectPosition(int size) => index == (x + (y * size));

  @override
  List<Object?> get props => [x, y, index];
}
