import 'package:flutter/material.dart';

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

const List<Color> sectionColors = [
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Colors.teal,
  Color(0xFFfdd835), // bright yellow
  Color(0xFF8d6e63), // brown
  Color(0xFF64b5f6), // blue
];

String selectedIconFor(String title) => categoryIcons[title] ?? '💸';

Color colorFor(String title, [List<Color> palette = sectionColors]) {
  final idx = categoryIcons.keys.toList().indexOf(title);
  final i = idx < 0 ? 0 : idx;
  return palette[i % palette.length];
}
