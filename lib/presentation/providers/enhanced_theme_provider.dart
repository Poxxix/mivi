import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/presentation/core/app_themes.dart';

class EnhancedThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selectedTheme';
  AppThemeMode _currentTheme = AppThemeMode.dark; // Default theme

  AppThemeMode get currentTheme => _currentTheme;
  
  ThemeData get themeData => AppThemes.getTheme(_currentTheme);
  
  String get themeName => AppThemes.getThemeName(_currentTheme);
  
  IconData get themeIcon => AppThemes.getThemeIcon(_currentTheme);

  // Compatibility với old theme provider
  bool get isDarkMode => _currentTheme == AppThemeMode.dark;
  
  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
      case AppThemeMode.white:
      case AppThemeMode.pinkLight:
        return ThemeMode.light;
    }
  }

  EnhancedThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = AppThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    // Cycle through themes: dark -> light -> white -> pink -> dark
    final currentIndex = _currentTheme.index;
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    await setTheme(AppThemeMode.values[nextIndex]);
  }

  // Compatibility methods với old theme provider
  Future<void> setDarkMode(bool value) async {
    if (value) {
      await setTheme(AppThemeMode.dark);
    } else {
      await setTheme(AppThemeMode.light);
    }
  }

  // Get all available themes
  List<AppThemeMode> get availableThemes => AppThemeMode.values;

  // Check if theme is dark
  bool get isCurrentThemeDark => _currentTheme == AppThemeMode.dark;

  // Get theme preview colors
  Color get primaryColor {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return const Color(0xFF6750A4);
      case AppThemeMode.light:
        return const Color(0xFF6366F1);
      case AppThemeMode.white:
        return const Color(0xFF2563EB);
      case AppThemeMode.pinkLight:
        return const Color(0xFFEC4899);
    }
  }

  Color get backgroundColor {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return const Color(0xFF1C1B1F);
      case AppThemeMode.light:
        return const Color(0xFFF8FAFC);
      case AppThemeMode.white:
        return Colors.white;
      case AppThemeMode.pinkLight:
        return const Color(0xFFFDF2F8);
    }
  }

  Color get surfaceColor {
    switch (_currentTheme) {
      case AppThemeMode.dark:
        return const Color(0xFF49454F);
      case AppThemeMode.light:
        return Colors.white;
      case AppThemeMode.white:
        return Colors.white;
      case AppThemeMode.pinkLight:
        return const Color(0xFFFCE7F3);
    }
  }

  // Theme descriptions
  String getThemeDescription(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.dark:
        return 'Perfect for low-light environments';
      case AppThemeMode.light:
        return 'Clean and modern light theme';
      case AppThemeMode.white:
        return 'Pure white minimalist design';
      case AppThemeMode.pinkLight:
        return 'Soft pink theme with warm tones';
    }
  }
} 