import 'package:flutter/material.dart';

ThemeData lightThemeData({Color? primaryColor}) {
  final color = primaryColor ?? const Color(0xFF4CAF50); // Зеленый по умолчанию
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: color,
      unselectedItemColor: Colors.grey,
    ),
  );
}

ThemeData darkThemeData({Color? primaryColor}) {
  final color = primaryColor ?? const Color(0xFF4CAF50); // Зеленый по умолчанию
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: color,
      unselectedItemColor: Colors.grey,
    ),
  );
}

// Цвет фона секций (например, для хедеров, сумм, фильтров)
const Color kSectionBgLight = Color(0xFFE6F4EA);
const Color kSectionBgDark = Color(0xFF23262F);

Color sectionBackgroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? kSectionBgDark
      : kSectionBgLight;
}

Color sectionCardColor(BuildContext context) {
  // Можно использовать для карточек внутри секций
  return Theme.of(context).brightness == Brightness.dark
      ? Color(0xFF181A20)
      : Colors.white;
}

// Цвета для категорий (централизовано)
const List<Color> kCategoryColors = [
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
