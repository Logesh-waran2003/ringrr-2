import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0D0E16);
  static const surface = Color(0xFF14161F);
  static const surfaceElevated = Color(0xFF1B1E2C);
  static const border = Color(0xFF262838);
  static const primary = Color(0xFF00C9C8);
  static const positive = Color(0xFF10B981);
  static const negative = Color(0xFFF97316);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFC7C9DA);
  static const textMuted = Color(0xFF9496AC);
  static const personal = Color(0xFF8B5CF6);
  static const work = Color(0xFF3B82F6);
  static const health = Color(0xFF10B981);
  static const social = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.negative,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 11),
      labelSmall: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.2),
    ),
  );
}
