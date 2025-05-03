import 'package:flutter/material.dart';
import 'package:umd_dining_refactor/config/themes/app_pallete.dart';

class AppTheme {
  static _border([Color color = AppPallete.borderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );
  static final darkThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
    ),
    // chipTheme: const ChipThemeData(
    //   color: WidgetStatePropertyAll(
    //     AppPallete.backgroundColor,
    //   ),
    //   side: BorderSide.none,
    // ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.gradient2),
      errorBorder: _border(AppPallete.errorColor),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontFamily: 'Helvetica',
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontFamily: 'Helvetica',
        color: Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Helvetica',
        color: Colors.black,
      ),
    ),
  );
}
