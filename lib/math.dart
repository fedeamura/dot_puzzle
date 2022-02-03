class CustomMathUtils {
  static double map(double x, double in_min, double in_max, double out_min, double out_max) {
    final div = (in_max - in_min);
    if (div == 0) return 0.0;
    return (x - in_min) * (out_max - out_min) / div + out_min;
  }
}
