import 'dart:ui';

import 'package:dot_puzzle/core/list.dart';
import 'package:equatable/equatable.dart';

class TileModel extends Equatable {
  final int _size;
  final int index;
  final int x;
  final int y;

  TileModel({
    required int size,
    required this.index,
  })  : _size = size,
        x = ListUtils.getX(index, size),
        y = ListUtils.getY(index, size);

  TileModel copyWith({int? index}) => TileModel(
        size: _size,
        index: index ?? this.index,
      );

  @override
  List<Object?> get props => [
        _size,
        index,
      ];

  Offset toOffset() => Offset(x.toDouble(), y.toDouble());
}
