// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF00BCD4);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color surface = Color(0xFF1E2A3A);
  static const Color surfaceLight = Color(0xFF263547);
  static const Color background = Color(0xFF0F1923);
  static const Color onBackground = Color(0xFFECF0F1);
  static const Color onSurface = Color(0xFFB0BEC5);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onBackground,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onBackground,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurface, fontFamily: 'Cairo'),
        hintStyle:
            TextStyle(color: onSurface.withOpacity(0.5), fontFamily: 'Cairo'),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : onSurface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected)
                  ? primary.withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: surfaceLight,
        overlayColor: Color(0x291A73E8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
            color: onBackground, fontWeight: FontWeight.w800, fontSize: 24),
        titleLarge: TextStyle(
            color: onBackground, fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(
            color: onBackground, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: onBackground, fontSize: 15),
        bodyMedium: TextStyle(color: onSurface, fontSize: 14),
        labelLarge: TextStyle(
            color: primary, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      dividerColor: Colors.white.withOpacity(0.08),
    );
  }
}
