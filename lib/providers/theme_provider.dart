import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    // Update system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    SystemChrome.setSystemUIOverlayStyle(
      _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
    notifyListeners();
  }

  // Light Theme
  static ThemeData get lightTheme {
    const Color customTextColor = Color(0xFFE91E63); // Pink color for text
    const Color customPrimaryColor = Color(
      0xFFE91E63,
    ); // Same pink for primary elements

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: customPrimaryColor, // Pink primary color instead of purple
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      cardColor: Colors.white,
      hintColor: Colors.grey[400],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: customTextColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: customPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: customTextColor),
        displayMedium: TextStyle(color: customTextColor),
        displaySmall: TextStyle(color: customTextColor),
        headlineLarge: TextStyle(color: customTextColor),
        headlineMedium: TextStyle(color: customTextColor),
        headlineSmall: TextStyle(color: customTextColor),
        titleLarge: TextStyle(color: customTextColor),
        titleMedium: TextStyle(color: customTextColor),
        titleSmall: TextStyle(color: customTextColor),
        bodyLarge: TextStyle(color: customTextColor),
        bodyMedium: TextStyle(color: customTextColor),
        bodySmall: TextStyle(color: customTextColor),
        labelLarge: TextStyle(color: customTextColor),
        labelMedium: TextStyle(color: customTextColor),
        labelSmall: TextStyle(color: customTextColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: customPrimaryColor, // Pink instead of purple
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    const Color customTextColor = Color(
      0xFFFF4081,
    ); // Lighter pink for dark mode
    const Color customPrimaryColor = Color(
      0xFFFF4081,
    ); // Same lighter pink for primary elements

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: customPrimaryColor, // Pink primary color instead of purple
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      hintColor: Colors.grey[400],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: customTextColor,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: customPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: customTextColor),
        displayMedium: TextStyle(color: customTextColor),
        displaySmall: TextStyle(color: customTextColor),
        headlineLarge: TextStyle(color: customTextColor),
        headlineMedium: TextStyle(color: customTextColor),
        headlineSmall: TextStyle(color: customTextColor),
        titleLarge: TextStyle(color: customTextColor),
        titleMedium: TextStyle(color: customTextColor),
        titleSmall: TextStyle(color: customTextColor),
        bodyLarge: TextStyle(color: customTextColor),
        bodyMedium: TextStyle(color: customTextColor),
        bodySmall: TextStyle(color: customTextColor),
        labelLarge: TextStyle(color: customTextColor),
        labelMedium: TextStyle(color: customTextColor),
        labelSmall: TextStyle(color: customTextColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: customPrimaryColor, // Pink instead of purple
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
