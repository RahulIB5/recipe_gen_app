import '../models/recipe.dart';
import '../services/spoonacular_service.dart';

class RecipeRepository {
  static List<Recipe> _cachedRecipes = [];
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  // Get all recipes from Spoonacular API
  static Future<List<Recipe>> getAllRecipes({
    bool forceRefresh = false,
    int offset = 0,
    int limit = 20,
  }) async {
    // Check cache validity for first page only
    if (!forceRefresh &&
        offset == 0 &&
        _cachedRecipes.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return _cachedRecipes.take(limit).toList();
    }

    try {
      List<Recipe> recipes;

      if (offset == 0) {
        // For first load, get trending/popular recipes
        recipes = await SpoonacularService.getTrendingRecipes(number: limit);
        _cachedRecipes = recipes;
        _lastFetchTime = DateTime.now();
      } else {
        // For pagination, get more recipes using search
        recipes = await SpoonacularService.searchRecipes(
          number: limit,
          offset: offset,
        );
        _cachedRecipes.addAll(recipes);
      }

      return recipes;
    } catch (e) {
      print('Failed to fetch recipes from API: $e');
      // Return empty list instead of fallback data
      return [];
    }
  }

  // Search recipes with query
  static Future<List<Recipe>> searchRecipes(String query) async {
    try {
      return await SpoonacularService.searchRecipes(query: query, number: 20);
    } catch (e) {
      print('Failed to search recipes: $e');
      return [];
    }
  }

  // Get recipes by cuisine
  static Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    try {
      return await SpoonacularService.getRecipesByCuisine(cuisine);
    } catch (e) {
      print('Failed to get recipes by cuisine: $e');
      return [];
    }
  }

  // Get recipes by dietary preferences
  static Future<List<Recipe>> getRecipesByDiet(String diet) async {
    try {
      return await SpoonacularService.getRecipesByDiet(diet);
    } catch (e) {
      print('Failed to get recipes by diet: $e');
      return [];
    }
  }

  // Get recipes by ingredients
  static Future<List<Recipe>> getRecipesByIngredients(
    List<String> ingredients,
  ) async {
    try {
      return await SpoonacularService.searchByIngredients(
        ingredients: ingredients,
        number: 20,
      );
    } catch (e) {
      print('Failed to get recipes by ingredients: $e');
      return [];
    }
  }

  // Get random recipes
  static Future<List<Recipe>> getRandomRecipes({int count = 20}) async {
    try {
      return await SpoonacularService.getRandomRecipes(number: count);
    } catch (e) {
      print('Failed to get random recipes: $e');
      return [];
    }
  }

  // Get recipe by ID
  static Future<Recipe?> getRecipeById(String id) async {
    // Check cache first
    var cached = _cachedRecipes.where((r) => r.id == id).firstOrNull;
    if (cached != null) return cached;

    try {
      return await SpoonacularService.getRecipeById(id);
    } catch (e) {
      print('Failed to get recipe by ID: $e');
      return null;
    }
  }

  // Utility methods
  static void clearCache() {
    _cachedRecipes.clear();
    _lastFetchTime = null;
  }

  static bool get hasCache => _cachedRecipes.isNotEmpty;

  static bool get isCacheValid =>
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
}
