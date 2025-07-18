import 'package:flutter/material.dart';
import 'package:cashnetic/presentation/theme/theme.dart';

const Map<String, String> categoryIcons = {
  'Ремонт': '🏠',
  'Одежда': '👗',
  'Продукты': '🛒',
  'Электроника': '📱',
  'Развлечения': '🎉',
  'Образование': '🎓',
  'Услуги связи': '📞',
  'Дом': '🏡',
  'Животные': '🐶',
  'Здоровье': '💊',
  'Подарки': '🎁',
};

String selectedIconFor(String title) => categoryIcons[title] ?? '��';

Color colorFor(String title, [List<Color> palette = kCategoryColors]) {
  final idx = categoryIcons.keys.toList().indexOf(title);
  final i = idx < 0 ? 0 : idx;
  return palette[i % palette.length];
}
