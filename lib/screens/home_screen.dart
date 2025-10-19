import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../data/recipe_repository.dart';
import '../widgets/recipe_card.dart';
import '../models/recipe.dart';
import '../providers/theme_provider.dart';

// Home screen with recipe discovery carousel
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _selectedCategory = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentOffset = 0;
  final int _recipesPerPage = 20;
  bool _hasMoreRecipes = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _error = null;
          _currentOffset = 0;
          _hasMoreRecipes = true;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      final recipes = await RecipeRepository.getAllRecipes(
        offset: loadMore ? _currentOffset : 0,
        limit: _recipesPerPage,
        forceRefresh: !loadMore,
      );

      setState(() {
        if (loadMore) {
          _allRecipes.addAll(recipes);
          _filteredRecipes.addAll(recipes);
          _currentOffset += _recipesPerPage;
          _hasMoreRecipes = recipes.length == _recipesPerPage;
          _isLoadingMore = false;
        } else {
          _allRecipes = recipes;
          _filteredRecipes = recipes;
          _currentOffset = _recipesPerPage;
          _hasMoreRecipes = recipes.length == _recipesPerPage;
          _isLoading = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load recipes: $e';
        if (loadMore) {
          _isLoadingMore = false;
        } else {
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _filterRecipes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredRecipes = _allRecipes;
        _hasMoreRecipes = _allRecipes.length >= _recipesPerPage;
      });
    } else {
      try {
        final searchResults = await RecipeRepository.searchRecipes(query);
        setState(() {
          _filteredRecipes = searchResults;
          _hasMoreRecipes =
              false; // Search results don't support pagination yet
        });
      } catch (e) {
        // Fallback to local filtering
        setState(() {
          _filteredRecipes = _allRecipes.where((recipe) {
            return recipe.title.toLowerCase().contains(query.toLowerCase()) ||
                recipe.ingredients.any(
                  (ingredient) =>
                      ingredient.toLowerCase().contains(query.toLowerCase()),
                ) ||
                recipe.tags.any(
                  (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                );
          }).toList();
          _hasMoreRecipes = false;
        });
      }
    }
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _currentOffset = 0;
      _hasMoreRecipes = true;
    });

    if (category.isEmpty) {
      setState(() {
        _filteredRecipes = _allRecipes;
      });
    } else {
      try {
        final categoryResults = await RecipeRepository.getRecipesByCuisine(
          category,
        );
        setState(() {
          _filteredRecipes = categoryResults;
          _hasMoreRecipes =
              false; // Category filtering doesn't support pagination yet
        });
      } catch (e) {
        // Fallback to local filtering
        setState(() {
          _filteredRecipes = _allRecipes.where((recipe) {
            return recipe.tags.any(
              (tag) => tag.toLowerCase().contains(category.toLowerCase()),
            );
          }).toList();
          _hasMoreRecipes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayRecipes = _filteredRecipes;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadRecipes,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(12.0), // Reduced from 16.0
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SmartChef',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(
                                            0xFFB794F6,
                                          ) // Lighter purple for dark mode
                                        : Theme.of(
                                            context,
                                          ).primaryColor, // Original purple for light mode
                                  ),
                            ),
                            Text(
                              'Discover amazing recipes',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Dark Mode Toggle Button
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return IconButton(
                                  onPressed: () {
                                    themeProvider.toggleTheme();
                                  },
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      themeProvider.isDarkMode
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      key: ValueKey(themeProvider.isDarkMode),
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(
                                              0xFFB794F6,
                                            ) // Lighter purple for dark mode
                                          : Theme.of(
                                              context,
                                            ).primaryColor, // Original purple for light mode
                                    ),
                                  ),
                                  tooltip: themeProvider.isDarkMode
                                      ? 'Switch to Light Mode'
                                      : 'Switch to Dark Mode',
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFB794F6).withOpacity(
                                        0.15,
                                      ) // Lighter opacity for dark mode background
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(
                                        0.1,
                                      ), // Original for light mode
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(
                                        0xFFB794F6,
                                      ) // Lighter purple for dark mode
                                    : Theme.of(
                                        context,
                                      ).primaryColor, // Original purple for light mode
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ), // Reduced from 16.0
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ), // Reduced from 16
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search recipes, ingredients...',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).hintColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterRecipes('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => _filterRecipes(value),
                    onSubmitted: (value) => _filterRecipes(value),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Main Recipe Carousel - All 50 Recipes
              if (displayRecipes.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discover Recipes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${displayRecipes.length} recipes',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CarouselSlider.builder(
                  itemCount: displayRecipes.length, // Show ALL recipes
                  itemBuilder: (context, index, realIndex) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: EnhancedRecipeCard(recipe: displayRecipes[index]),
                    );
                  },
                  options: CarouselOptions(
                    height: 300, // Slightly taller for better visibility
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 1000,
                    ),
                    autoPlayCurve: Curves.easeInOutCubic,
                    viewportFraction: 0.8,
                    enableInfiniteScroll: true,
                    scrollDirection: Axis.horizontal,
                    enlargeFactor: 0.25,
                    padEnds: false,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick Categories Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Categories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory.isEmpty
                              ? 'All Categories'
                              : _selectedCategory,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).primaryColor,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue == 'All Categories') {
                              _filterByCategory('');
                            } else {
                              _filterByCategory(newValue ?? '');
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All Categories',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('All Categories'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Breakfast',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.free_breakfast,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Breakfast'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Lunch',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lunch_dining,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Lunch'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Dinner',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.dinner_dining,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Dinner'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Dessert',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cake,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Dessert'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Healthy',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Healthy'),
                                ],
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Quick',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Quick'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8), // Further reduced from 12
              // All Recipes Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory.isEmpty
                          ? 'All Recipes'
                          : '$_selectedCategory Recipes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${displayRecipes.length} recipes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4), // Further reduced from 8
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                ), // Reduced padding for more space
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns for smaller cards
                    childAspectRatio: 1.0, // Square cards (1:1 ratio)
                    crossAxisSpacing: 3, // Very minimal spacing
                    mainAxisSpacing: 3, // Very minimal spacing
                  ),
                  itemCount:
                      displayRecipes.length, // Show all available recipes
                  itemBuilder: (context, index) {
                    return RecipeCard(
                      recipe:
                          displayRecipes[index], // Show all recipes from index 0
                      isLarge: false,
                    );
                  },
                ),
              ),

              // Load More Button
              if (_hasMoreRecipes &&
                  !_isLoading &&
                  _selectedCategory.isEmpty &&
                  _searchController.text.isEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingMore
                          ? null
                          : () => _loadRecipes(loadMore: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoadingMore
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Loading more recipes...',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.expand_more,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Load More Recipes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
