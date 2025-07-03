import 'package:flutter/material.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/theme/light_color_for.dart';

Color lightColorFor(String name) {
  final base = colorFor(name);
  return Color.lerp(base, Colors.white, 0.8) ?? base;
}
