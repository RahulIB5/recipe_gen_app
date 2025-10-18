import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'ai_recipe_generator_screen.dart';
import 'image_recognition_screen.dart';
import 'profile_screen.dart';
import '../providers/theme_provider.dart';

// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AIRecipeGeneratorScreen(),
    const ImageRecognitionScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: 'AI Generator',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Image Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.small(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(themeProvider.isDarkMode),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniEndFloat,
        );
      },
    );
  }
}
