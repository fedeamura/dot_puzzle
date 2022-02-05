import 'dart:ui';

class ColorUtils {
  static Color? fromHexString(String value) {
    var hexColor = value.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }

    return null;
  }

  static String toHexString(Color color) {
    return '#${color.value.toRadixString(16)}'.toUpperCase();
  }
}
