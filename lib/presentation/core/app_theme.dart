import 'package:flutter/material.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1),
        onPrimary: Colors.white,
        secondary: Color(0xFF06B6D4),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1F2937),
        surfaceContainerHighest: Color(0xFFF3F4F6),
        onSurfaceVariant: Color(0xFF6B7280),
        error: Color(0xFFEF4444),
        onError: Colors.white,
        background: Color(0xFFFAFAFA),
        onBackground: Color(0xFF1F2937),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF3F4F6),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.onBackground),
        titleTextStyle: TextStyle(
          color: AppColors.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.surfaceVariant,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.onBackground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.onBackground,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.onBackground,
          fontSize: 14,
        ),
      ),
    );
  }
} 