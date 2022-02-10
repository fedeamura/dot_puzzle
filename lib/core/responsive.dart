import 'package:flutter/cupertino.dart';

class ResponsiveUtils {
  static T calculate<T>(
    BoxConstraints constraints, {
    bool horizontal = true,
    required T Function(BoxConstraints constraints) small,
    required T Function(BoxConstraints constraints) medium,
    required T Function(BoxConstraints constraints) large,
    required T Function(BoxConstraints constraints) xl,
  }) {
    final max = horizontal ? constraints.maxWidth : constraints.maxHeight;

    if (max < 768) {
      return small(constraints);
    }

    if (max < 1024) {
      return medium(constraints);
    }

    if (max < 1440) {
      return large(constraints);
    }

    return xl(constraints);
  }
}
