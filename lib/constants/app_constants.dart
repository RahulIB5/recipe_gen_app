import 'package:flutter/material.dart';

// App-wide constants and configurations
class AppConstants {
  // App Information
  static const String appName = 'SmartChef';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.smartchef.com';
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com';
  
  // Asset Paths
  static const String imagePlaceholder = 'assets/images/placeholder.png';
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Spacing Constants
  static const double smallSpacing = 8.0;
  static const double normalSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  
  // Border Radius
  static const double smallRadius = 8.0;
  static const double normalRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double circularRadius = 20.0;
  
  // Colors
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color secondaryPurple = Color(0xFF9333EA);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color successGreen = Color(0xFF059669);
  static const Color warningYellow = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFDC2626);
  
  // Text Styles
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}

// App-wide styling configurations
class AppThemes {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.normalRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.normalRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.normalSpacing,
          vertical: AppConstants.smallSpacing,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.normalRadius),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Please check your internet connection and try again.';
  static const String serverError = 'Server is currently unavailable. Please try again later.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String noDataFound = 'No data found. Please try different search criteria.';
  static const String permissionDenied = 'Permission denied. Please grant required permissions.';
  static const String invalidInput = 'Please check your input and try again.';
}

// Success Messages
class SuccessMessages {
  static const String recipeSaved = 'Recipe saved to favorites!';
  static const String recipeRemoved = 'Recipe removed from favorites!';
  static const String preferencesUpdated = 'Preferences updated successfully!';
  static const String imageAnalyzed = 'Image analyzed successfully!';
  static const String recipeGenerated = 'Recipe generated successfully!';
}

// Validation Rules
class ValidationRules {
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 20;
  static const int minIngredientsCount = 1;
  static const int maxIngredientsCount = 15;
  
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }
  
  static String? validateIngredients(List<String> ingredients) {
    if (ingredients.isEmpty) {
      return 'At least one ingredient is required';
    }
    if (ingredients.length > maxIngredientsCount) {
      return 'Maximum $maxIngredientsCount ingredients allowed';
    }
    return null;
  }
}