import 'dart:math';

class ListUtils {
  static T? removeRandom<T>(List<T> list) {
    if (list.isEmpty) return null;
    final index = Random().nextInt(list.length);
    return list.removeAt(index);
  }

  static int getIndex(int x, int y, int size) {
    return x + (y * size);
  }

  static int getX(int index, int size) {
    return index % size;
  }

  static int getY(int index, int size) {
    return (index / size).floor();
  }
}

extension ListExtension<T> on List<T> {
  T? removeRandom() {
    return ListUtils.removeRandom<T>(this);
  }
}
