import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/recipe.dart';
import '../data/dummy_data.dart';
import '../widgets/recipe_card.dart';
import '../providers/theme_provider.dart';

// Profile screen with user preferences, favorites, and history
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  User _currentUser = DummyData.currentUser;
  List<String> _selectedPreferences = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedPreferences = List.from(_currentUser.dietaryPreferences);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
  }

  void _savePreferences() {
    setState(() {
      _currentUser = _currentUser.copyWith(
        dietaryPreferences: _selectedPreferences,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Recipe> _getFavoriteRecipes() {
    return DummyData.recipes
        .where((recipe) => _currentUser.favoriteRecipeIds.contains(recipe.id))
        .toList();
  }

  List<Recipe> _getHistoryRecipes() {
    return DummyData.recipes
        .where((recipe) => _currentUser.recipeHistory.contains(recipe.id))
        .toList();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings, color: Colors.purple),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Dark Mode',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Version',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'SmartChef v1.0.0',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _currentUser.email,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showSettingsDialog();
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Favorites',
                        '${_getFavoriteRecipes().length}',
                      ),
                      _buildStatCard(
                        'Cooked',
                        '${_getHistoryRecipes().length}',
                      ),
                      _buildStatCard(
                        'Preferences',
                        '${_selectedPreferences.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Favorites'),
                  Tab(text: 'History'),
                  Tab(text: 'Preferences'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesTab(),
                  _buildHistoryTab(),
                  _buildPreferencesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteRecipes = _getFavoriteRecipes();

    if (favoriteRecipes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: 'No Favorites Yet',
        subtitle: 'Start exploring recipes and mark your favorites!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteRecipes.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          child: RecipeCard(recipe: favoriteRecipes[index], isLarge: true),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final historyRecipes = _getHistoryRecipes();

    if (historyRecipes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Cooking History',
        subtitle: 'Your cooking adventures will appear here!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyRecipes.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          child: RecipeCard(recipe: historyRecipes[index], isLarge: true),
        );
      },
    );
  }

  Widget _buildPreferencesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Preferences',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your dietary preferences to get personalized recipe recommendations.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: DummyData.dietaryOptions.length,
              itemBuilder: (context, index) {
                final preference = DummyData.dietaryOptions[index];
                final isSelected = _selectedPreferences.contains(preference);

                return GestureDetector(
                  onTap: () => _togglePreference(preference),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        if (isSelected) const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            preference,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Preferences'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
