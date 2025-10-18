import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/gemini_service.dart';
import 'providers/theme_provider.dart';

void main() {
  // Initialize Gemini AI services
  GeminiService.initialize();

  runApp(const SmartChefApp());
}

class SmartChefApp extends StatelessWidget {
  const SmartChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SmartChef',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
