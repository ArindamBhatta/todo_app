import 'package:flutter/material.dart';
import 'package:todo/core/theme/app_color_schemes.dart';

class AppTheme {
  static final ThemeData lightTheme = _buildTheme(
    colorScheme: AppColorSchemes.light,
    useMaterial3: true,
  );

  static final ThemeData darkTheme = _buildTheme(
    colorScheme: AppColorSchemes.dark,
    useMaterial3: true,
  );

  static final ThemeData bibleReaderLightTheme = _buildTheme(
    colorScheme: AppColorSchemes.light,
    useMaterial3: false,
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required bool useMaterial3,
  }) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: useMaterial3,
      scaffoldBackgroundColor: colorScheme.surface,
      tabBarTheme: const TabBarThemeData(),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onSurface),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        fillColor: Colors.transparent,
        filled: true,
      ),
    );
  }
}
