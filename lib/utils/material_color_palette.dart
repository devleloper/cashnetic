import 'package:flutter/material.dart';

class MaterialColorPalette {
  static List<Color> getColors(int count) {
    final base = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.yellow,
    ];
    if (count <= base.length) return base.sublist(0, count);
    return List.generate(count, (i) => base[i % base.length]);
  }
}
