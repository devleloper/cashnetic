import 'package:flutter/material.dart';

ThemeData themeData() {
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
