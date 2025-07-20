import 'package:flutter/material.dart';
import 'package:cashnetic/utils/category_utils.dart';

Color lightColorFor(BuildContext context, String name) {
  final base = colorFor(name);
  return Color.lerp(base, Theme.of(context).colorScheme.onPrimary, 0.8) ?? base;
}
