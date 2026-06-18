import 'package:flutter/material.dart';

class FitMateTheme {
  // Brand Colors
  static const colorPrimary = Color(0xFF0066FF);
  static const colorPrimaryHover = Color(0xFF005EEB);
  static const colorPositive = Color(0xFF00BF40);
  static const colorDanger = Color(0xFFFF4242);
  static const colorWarning = Color(0xFFFF9200);

  // Light Mode Colors
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xffffffff),
    cardColor: const Color(0xFFF7F7F8),
    dividerColor: const Color(0xFFF4F4F5),
    colorScheme: const ColorScheme.light(
      primary: colorPrimary,
      secondary: Color(0xFFEAF2FE), // color-primary-subtle
      surface: Color(0xFFFFFFFF), // bg-elevated
      onPrimary: Colors.white,
      onSurface: Color(0xFF171719), // fg-primary
      onSecondary: Color(0xFF37383C), // fg-secondary
      outline: Color(0xFF70737C), // fg-tertiary
      outlineVariant: Color(0xFFAEB0B6), // fg-quaternary
    ),
  );

  // Dark Mode Colors
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF171719),
    cardColor: const Color(0xFF1B1C1E),
    dividerColor: const Color(0xFF212225),
    colorScheme: const ColorScheme.dark(
      primary: colorPrimary,
      secondary: Color(0xff142237), // color-primary-subtle (dark)
      surface: Color(0xFF292A2D), // bg-elevated
      onPrimary: Colors.white,
      onSurface: Color(0xFFF7F7F8), // fg-primary
      onSecondary: Color(0xFFDBDCDF), // fg-secondary
      outline: Color(0xFF70737C), // fg-tertiary
      outlineVariant: Color(0xFF46474C), // fg-quaternary
    ),
  );

  // Spacing & Radius Tokens
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
}