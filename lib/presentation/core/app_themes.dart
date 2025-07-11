import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  dark,
  light,
  white,
  pinkLight,
  midnightBlack,
  oledDark
}

class AppThemes {
  // Dark Theme (Original)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6750A4),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF625B71),
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFF7D5260),
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFFB3261E),
        onError: Color(0xFFFFFFFF),
        surface: Color(0xFF1C1B1F),
        onSurface: Color(0xFFE6E1E5),
        surfaceVariant: Color(0xFF49454F),
        onSurfaceVariant: Color(0xFFCAC4D0),
        outline: Color(0xFF938F99),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1B1F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1B1F),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFE6E1E5)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE6E1E5),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1C1B1F),
        indicatorColor: const Color(0xFF49454F),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFFE6E1E5),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFE6E1E5),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFFE6E1E5),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFE6E1E5),
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF49454F),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6750A4),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Light Theme (Enhanced)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1),
        onPrimary: Colors.white,
        secondary: Color(0xFF06B6D4),
        onSecondary: Colors.white,
        tertiary: Color(0xFF8B5CF6),
        onTertiary: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        surface: Color(0xFFF8FAFC),
        onSurface: Color(0xFF1E293B),
        surfaceVariant: Color(0xFFF1F5F9),
        onSurfaceVariant: Color(0xFF64748B),
        outline: Color(0xFFCBD5E1),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF1F5F9),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF475569),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Pure White Theme
  static ThemeData get whiteTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        onPrimary: Colors.white,
        secondary: Color(0xFF10B981),
        onSecondary: Colors.white,
        tertiary: Color(0xFF8B5CF6),
        onTertiary: Colors.white,
        error: Color(0xFFDC2626),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF111827),
        surfaceVariant: Color(0xFFFAFAFA),
        onSurfaceVariant: Color(0xFF6B7280),
        outline: Color(0xFFE5E7EB),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        shadowColor: Color(0x1A000000),
        iconTheme: IconThemeData(color: Color(0xFF111827)),
        titleTextStyle: TextStyle(
          color: Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF3F4F6),
        elevation: 8,
        shadowColor: const Color(0x1A000000),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF111827),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Color(0x0A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  // Pink Light Theme  
  static ThemeData get pinkLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFEC4899), // Pink primary
        onPrimary: Colors.white,
        secondary: Color(0xFFF97316), // Orange secondary
        onSecondary: Colors.white,
        tertiary: Color(0xFFA855F7), // Purple tertiary
        onTertiary: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        background: Color(0xFFFDF2F8), // Very light pink background
        onBackground: Color(0xFF831843), // Dark pink text
        surface: Color(0xFFFCE7F3), // Light pink surface
        onSurface: Color(0xFF831843),
        surfaceVariant: Color(0xFFFBBCDE), // Soft pink variant
        onSurfaceVariant: Color(0xFF9D174D),
        outline: Color(0xFFEC4899),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: const Color(0xFFFDF2F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFDF2F8),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF831843)),
        titleTextStyle: TextStyle(
          color: Color(0xFF831843),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFFCE7F3),
        indicatorColor: const Color(0xFFFBBCDE),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF831843),
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF831843),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF831843),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF9D174D),
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFBE185D),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFCE7F3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC4899),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFEC4899),
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFBBCDE),
        selectedColor: const Color(0xFFEC4899),
        labelStyle: const TextStyle(color: Color(0xFF831843)),
        side: const BorderSide(color: Color(0xFFEC4899)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFCE7F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEC4899)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFBBCDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
        ),
      ),
    );
  }

  // Midnight Black Theme - Pure black with blue accents
  static ThemeData get midnightBlackTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6), // Bright blue
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFF1D4ED8), // Deep blue
        onSecondary: Color(0xFFFFFFFF),
        tertiary: Color(0xFF6366F1), // Indigo
        onTertiary: Color(0xFFFFFFFF),
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
        background: Color(0xFF000000), // Pure black
        onBackground: Color(0xFFE5E7EB),
        surface: Color(0xFF111111), // Very dark gray
        onSurface: Color(0xFFE5E7EB),
        surfaceVariant: Color(0xFF1F1F1F),
        onSurfaceVariant: Color(0xFFD1D5DB),
        outline: Color(0xFF6B7280),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFE5E7EB)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF000000),
        indicatorColor: const Color(0xFF1F1F1F),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF111111),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // OLED Dark Theme - True black optimized for OLED displays
  static ThemeData get oledDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FF88), // Neon green
        onPrimary: Color(0xFF000000),
        secondary: Color(0xFF00E5FF), // Cyan
        onSecondary: Color(0xFF000000),
        tertiary: Color(0xFFFF00FF), // Magenta
        onTertiary: Color(0xFF000000),
        error: Color(0xFFFF3030),
        onError: Color(0xFF000000),
        background: Color(0xFF000000), // Pure black for OLED
        onBackground: Color(0xFFFFFFFF),
        surface: Color(0xFF000000), // Pure black surface
        onSurface: Color(0xFFFFFFFF),
        surfaceVariant: Color(0xFF0A0A0A), // Slightly gray for differentiation
        onSurfaceVariant: Color(0xFFE0E0E0),
        outline: Color(0xFF808080),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF000000),
        indicatorColor: const Color(0xFF0A0A0A),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFC0C0C0),
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 0, // No shadow on OLED
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFF303030), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FF88),
          foregroundColor: Colors.black,
          elevation: 0, // No shadow for OLED
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Get theme by mode
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.white:
        return whiteTheme;
      case AppThemeMode.pinkLight:
        return pinkLightTheme;
      case AppThemeMode.midnightBlack:
        return midnightBlackTheme;
      case AppThemeMode.oledDark:
        return oledDarkTheme;
    }
  }

  // Get theme name
  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.white:
        return 'White';
      case AppThemeMode.pinkLight:
        return 'Pink Light';
      case AppThemeMode.midnightBlack:
        return 'Midnight Black';
      case AppThemeMode.oledDark:
        return 'OLED Dark';
    }
  }

  // Get theme icon
  static IconData getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.white:
        return Icons.brightness_7;
      case AppThemeMode.pinkLight:
        return Icons.favorite;
      case AppThemeMode.midnightBlack:
        return Icons.nightlight;
      case AppThemeMode.oledDark:
        return Icons.brightness_2;
    }
  }
} 