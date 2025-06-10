import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme provider for the DiabApp application
class AppTheme {
  /// Returns the light theme for the app
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LightThemeColors.primary,
        primary: LightThemeColors.primary,
        secondary: LightThemeColors.secondary,
        background: LightThemeColors.background,
        surface: Colors.white,
        surfaceVariant: Colors.white,
      ),
      scaffoldBackgroundColor: LightThemeColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: LightThemeColors.background,
        foregroundColor: LightThemeColors.textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: LightThemeColors.textPrimary),
        displayMedium: TextStyle(color: LightThemeColors.textPrimary),
        displaySmall: TextStyle(color: LightThemeColors.textPrimary),
        headlineLarge: TextStyle(color: LightThemeColors.textPrimary),
        headlineMedium: TextStyle(color: LightThemeColors.textPrimary),
        headlineSmall: TextStyle(color: LightThemeColors.textPrimary),
        titleLarge: TextStyle(color: LightThemeColors.textPrimary),
        titleMedium: TextStyle(color: LightThemeColors.textPrimary),
        titleSmall: TextStyle(color: LightThemeColors.textPrimary),
        bodyLarge: TextStyle(color: LightThemeColors.textPrimary),
        bodyMedium: TextStyle(color: LightThemeColors.textPrimary),
        bodySmall: TextStyle(color: LightThemeColors.textSecondary),
        labelLarge: TextStyle(color: LightThemeColors.textPrimary),
        labelMedium: TextStyle(color: LightThemeColors.textPrimary),
        labelSmall: TextStyle(color: LightThemeColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightThemeColors.inputFieldBackground,
        hintStyle: const TextStyle(
          color: LightThemeColors.secondary,
          fontSize: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: LightThemeColors.borderHighlight,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightThemeColors.primary,
          foregroundColor: LightThemeColors.buttonText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: LightThemeColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// Returns the dark theme for the app
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DarkThemeColors.primary,
        primary: DarkThemeColors.primary,
        secondary: DarkThemeColors.secondary,
        background: DarkThemeColors.background,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: DarkThemeColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkThemeColors.background,
        foregroundColor: DarkThemeColors.textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: DarkThemeColors.textPrimary),
        displayMedium: TextStyle(color: DarkThemeColors.textPrimary),
        displaySmall: TextStyle(color: DarkThemeColors.textPrimary),
        headlineLarge: TextStyle(color: DarkThemeColors.textPrimary),
        headlineMedium: TextStyle(color: DarkThemeColors.textPrimary),
        headlineSmall: TextStyle(color: DarkThemeColors.textPrimary),
        titleLarge: TextStyle(color: DarkThemeColors.textPrimary),
        titleMedium: TextStyle(color: DarkThemeColors.textPrimary),
        titleSmall: TextStyle(color: DarkThemeColors.textPrimary),
        bodyLarge: TextStyle(color: DarkThemeColors.textPrimary),
        bodyMedium: TextStyle(color: DarkThemeColors.textPrimary),
        bodySmall: TextStyle(color: DarkThemeColors.textSecondary),
        labelLarge: TextStyle(color: DarkThemeColors.textPrimary),
        labelMedium: TextStyle(color: DarkThemeColors.textPrimary),
        labelSmall: TextStyle(color: DarkThemeColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.inputFieldBackground,
        hintStyle: const TextStyle(
          color: DarkThemeColors.secondary,
          fontSize: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: DarkThemeColors.borderHighlight,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkThemeColors.primary,
          foregroundColor: DarkThemeColors.buttonText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: DarkThemeColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
