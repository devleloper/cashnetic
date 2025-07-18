import 'package:flutter/material.dart';

ThemeData lightThemeData() {
  return ThemeData(
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.green),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const CircleBorder(),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      highlightElevation: 0,
      backgroundColor: Colors.green,
    ),
    primaryColor: Colors.green,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
  );
}

ThemeData darkThemeData() {
  return ThemeData(
    brightness: Brightness.dark,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.green,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    scaffoldBackgroundColor: Color(0xFF181A20),
    cardColor: Color(0xFF23262F),
    dividerColor: Color(0xFF23262F),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      backgroundColor: Color(0xFF181A20),
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      disabledElevation: 0,
      highlightElevation: 0,
      backgroundColor: Colors.green,
    ),
    primaryColor: Colors.green,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
      background: Color(0xFF181A20),
      surface: Color(0xFF23262F),
      onBackground: Colors.white,
      onSurface: Colors.white,
      primary: Colors.green,
      secondary: Colors.greenAccent,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white70),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white60),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF23262F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF23262F),
      textStyle: TextStyle(color: Colors.white),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.green,
        side: const BorderSide(color: Colors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF23262F),
      selectedColor: Colors.green,
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.white70),
      brightness: Brightness.dark,
      disabledColor: Colors.grey.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF23262F),
      thickness: 1,
      space: 1,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF23262F),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.green,
      selectionColor: Colors.green,
      selectionHandleColor: Colors.greenAccent,
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
