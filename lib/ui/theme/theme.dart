import 'package:flutter/material.dart';

ThemeData themeData() {
  return ThemeData(
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
      selectedItemColor: Color.fromRGBO(76, 175, 80, 1),
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
    primaryColor: Color.fromRGBO(76, 175, 80, 1),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(76, 175, 80, 1),
    ),
  );
}
