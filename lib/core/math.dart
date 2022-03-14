class MathUtils {
  static double map(double x, double inMin, double inMax, double outMin, double outMax) {
    final div = (inMax - inMin);
    if (div == 0) return 0.0;
    return (x - inMin) * (outMax - outMin) / div + outMin;
  }
}
