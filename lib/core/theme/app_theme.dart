import 'package:flutter/material.dart';
import 'color_palette.dart';

/// AppTheme configuration for the application.
/// Sets up a modern premium layout using Google-like Material 3.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: ColorPalette.primaryLight,
        secondary: ColorPalette.secondaryLight,
        surface: ColorPalette.surfaceLight,
        error: ColorPalette.errorLight,
      ),
      scaffoldBackgroundColor: ColorPalette.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.surfaceLight,
        foregroundColor: ColorPalette.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ColorPalette.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorPalette.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: ColorPalette.textSecondaryLight),
        hintStyle: const TextStyle(color: ColorPalette.grey400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.errorLight, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColorPalette.textPrimaryLight, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: ColorPalette.textPrimaryLight),
        bodyMedium: TextStyle(color: ColorPalette.textSecondaryLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: ColorPalette.primaryDark,
        secondary: ColorPalette.secondaryDark,
        surface: ColorPalette.surfaceDark,
        error: ColorPalette.errorDark,
      ),
      scaffoldBackgroundColor: ColorPalette.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.surfaceDark,
        foregroundColor: ColorPalette.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ColorPalette.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorPalette.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.borderDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: ColorPalette.textSecondaryDark),
        hintStyle: const TextStyle(color: ColorPalette.grey500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.errorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.errorDark, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryDark,
          foregroundColor: ColorPalette.grey900,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColorPalette.textPrimaryDark, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: ColorPalette.textPrimaryDark),
        bodyMedium: TextStyle(color: ColorPalette.textSecondaryDark),
      ),
    );
  }
}
