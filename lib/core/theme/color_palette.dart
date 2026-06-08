import 'package:flutter/material.dart';

/// Central color system for the application.
/// Provides rich, premium modern colors (Indigo & Emerald scheme) for Light and Dark themes.
class ColorPalette {
  ColorPalette._();

  // Light Theme Colors
  static const Color primaryLight = Color(0xFF6366F1); // Vibrant Indigo
  static const Color secondaryLight = Color(0xFF10B981); // Vibrant Emerald
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color errorLight = Color(0xFFEF4444); // Red 500
  static const Color successLight = Color(0xFF10B981); // Emerald 500

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF818CF8); // Indigo 400
  static const Color secondaryDark = Color(0xFF34D399); // Emerald 400
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color errorDark = Color(0xFFF87171); // Red 400
  static const Color successDark = Color(0xFF34D399); // Emerald 400

  // General Neutrals
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);
}
