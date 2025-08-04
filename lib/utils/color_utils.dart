import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String toHex(Color color, {bool leadingHashSign = true}) {
    final int a = ((color.a * 255.0).round()) & 0xff;
    final int r = ((color.r * 255.0).round()) & 0xff;
    final int g = ((color.g * 255.0).round()) & 0xff;
    final int b = ((color.b * 255.0).round()) & 0xff;

    return '${leadingHashSign ? '#' : ''}'
           '${a.toRadixString(16).padLeft(2, '0')}'
           '${r.toRadixString(16).padLeft(2, '0')}'
           '${g.toRadixString(16).padLeft(2, '0')}'
           '${b.toRadixString(16).padLeft(2, '0')}'
           .toUpperCase();
  }
}