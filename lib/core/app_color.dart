import 'package:flutter/material.dart';

class AppColors {
  static const lightPrimary = Colors.blue;
  static const lightBackground = Colors.white;
  static const lightText = Colors.black;

  static const darkPrimary = Colors.teal;
  static const darkBackground = Colors.black;
  static const darkText = Colors.white;
  static const textFiled = Colors.blue;
}

class ThemeHelper {
  final ThemeMode themeMode;

  ThemeHelper(this.themeMode);

  Color get primaryColor => themeMode == ThemeMode.dark
      ? AppColors.darkPrimary
      : AppColors.lightPrimary;

  Color get backgroundColor => themeMode == ThemeMode.dark
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  Color get contactProfile => themeMode == ThemeMode.dark
      ? Colors.blue.withOpacity(0.2)
      : Colors.orange.withOpacity(0.4);

  Color get antiBackgroundColor => themeMode == ThemeMode.dark
      ? AppColors.lightBackground
      : AppColors.textFiled.withOpacity(0.1);

  Color get textColor =>
      themeMode == ThemeMode.dark ? AppColors.darkText : AppColors.lightText;
  Color get antiTextColor =>
      themeMode == ThemeMode.dark ? AppColors.lightText : AppColors.lightText;
  Color get antiCameraColor => themeMode == ThemeMode.dark
      ? AppColors.lightText
      : AppColors.lightBackground;
}
