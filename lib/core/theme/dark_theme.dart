
import 'package:flutter/material.dart';
import 'package:itqan_gym/core/theme/text_theme.dart';
import 'colors.dart';

class DarkTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: ColorsManager.primaryColor,
    scaffoldBackgroundColor: ColorsManager.darkColor,
    primaryColorDark: ColorsManager.defaultSurface,
    cardColor: ColorsManager.secondaryDarkColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorsManager.primaryColor,
      brightness: Brightness.dark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: ColorsManager.primaryColor,
      unselectedItemColor: Colors.grey[500],
      backgroundColor: Colors.black87,
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.black,
      surfaceTintColor: Colors.black,
    ),
    textTheme: AppTextTheme.darkTextTheme,
  );
}
