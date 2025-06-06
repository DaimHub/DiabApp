import 'package:flutter/material.dart';

/// Color scheme for the DiabApp application
class AppColors {
  // Primary colors
  static const Color primaryIndigo = Color(0xFF464A7A);
  static const Color primaryBlue = Color(0xFF617AFA);
  static const Color primaryPurple = Color(0xFF5C5FC1);

  // Background colors
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  // Input field colors
  static const Color inputFieldLight = Color(0xFFF0F1F7);
  static const Color inputFieldDark = Color(0xFF2A2A2A);

  // Border colors
  static const Color borderLight = Color(0xFFDFE1E5);
  static const Color borderHighlightLight = Color(0xFFD0D1E0);
  static const Color borderDark = Color(0xFF3A3A3A);

  // Text colors
  static const Color textDarkLight = Color(0xFF303030);
  static const Color textLightLight = Color(0xFF6E6E6E);
  static const Color textDarkDark = Colors.white;
  static const Color textLightDark = Color(0xFFAAAAAA);
}

/// Light theme colors
class LightThemeColors {
  static const Color primary = AppColors.primaryBlue;
  static const Color secondary = AppColors.primaryPurple;
  static const Color background = AppColors.lightBackground;
  static const Color inputFieldBackground = AppColors.inputFieldLight;
  static const Color border = AppColors.borderLight;
  static const Color borderHighlight = AppColors.borderHighlightLight;
  static const Color textPrimary = AppColors.textDarkLight;
  static const Color textSecondary = AppColors.textLightLight;
  static const Color buttonText = Colors.white;
}

/// Dark theme colors
class DarkThemeColors {
  static const Color primary = AppColors.primaryBlue;
  static const Color secondary = AppColors.primaryPurple;
  static const Color background = AppColors.darkBackground;
  static const Color inputFieldBackground = AppColors.inputFieldDark;
  static const Color border = AppColors.borderDark;
  static const Color borderHighlight = AppColors.borderDark;
  static const Color textPrimary = AppColors.textDarkDark;
  static const Color textSecondary = AppColors.textLightDark;
  static const Color buttonText = Colors.white;
}
