import 'dart:ui';

import 'package:equatable/equatable.dart';

class PositionModel<T> extends Equatable {
  final T x;
  final T y;

  const PositionModel({
    required this.x,
    required this.y,
  });

  PositionModel copyWith({T? x, T? y}) {
    return PositionModel(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  List<Object?> get props => [x, y];
}
