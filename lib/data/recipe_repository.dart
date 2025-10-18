import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import '../config/api_config.dart';
import 'dummy_data.dart';

enum DataSource { api, local, hybrid }

class RecipeRepository {
  static DataSource _dataSource = ApiConfig.useFallbackData
      ? DataSource.local
      : DataSource.hybrid;
  static List<Recipe> _cachedRecipes = [];
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  // Set data source preference
  static void setDataSource(DataSource source) {
    _dataSource = source;
  }

  // Get all recipes with smart fallback
  static Future<List<Recipe>> getAllRecipes({bool forceRefresh = false}) async {
    // Check cache validity
    if (!forceRefresh &&
        _cachedRecipes.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return _cachedRecipes;
    }

    switch (_dataSource) {
      case DataSource.api:
        return await _getApiRecipes();
      case DataSource.local:
        return _getLocalRecipes();
      case DataSource.hybrid:
        return await _getHybridRecipes();
    }
  }

  // Search recipes with query
  static Future<List<Recipe>> searchRecipes(String query) async {
    switch (_dataSource) {
      case DataSource.api:
        return await SpoonacularService.searchRecipes(query: query);
      case DataSource.local:
        return _searchLocalRecipes(query);
      case DataSource.hybrid:
        try {
          var apiResults = await SpoonacularService.searchRecipes(query: query);
          if (apiResults.isNotEmpty) return apiResults;
        } catch (e) {
          print('API search failed, falling back to local: $e');
        }
        return _searchLocalRecipes(query);
    }
  }

  // Get recipes by cuisine
  static Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    switch (_dataSource) {
      case DataSource.api:
        return await SpoonacularService.getRecipesByCuisine(cuisine);
      case DataSource.local:
        return _filterLocalRecipesByCuisine(cuisine);
      case DataSource.hybrid:
        try {
          var apiResults = await SpoonacularService.getRecipesByCuisine(
            cuisine,
          );
          if (apiResults.isNotEmpty) return apiResults;
        } catch (e) {
          print('API cuisine search failed, falling back to local: $e');
        }
        return _filterLocalRecipesByCuisine(cuisine);
    }
  }

  // Get recipes by dietary preferences
  static Future<List<Recipe>> getRecipesByDiet(String diet) async {
    switch (_dataSource) {
      case DataSource.api:
        return await SpoonacularService.getRecipesByDiet(diet);
      case DataSource.local:
        return _filterLocalRecipesByDiet(diet);
      case DataSource.hybrid:
        try {
          var apiResults = await SpoonacularService.getRecipesByDiet(diet);
          if (apiResults.isNotEmpty) return apiResults;
        } catch (e) {
          print('API diet search failed, falling back to local: $e');
        }
        return _filterLocalRecipesByDiet(diet);
    }
  }

  // Get recipes by ingredients
  static Future<List<Recipe>> getRecipesByIngredients(
    List<String> ingredients,
  ) async {
    switch (_dataSource) {
      case DataSource.api:
        return await SpoonacularService.searchByIngredients(
          ingredients: ingredients,
        );
      case DataSource.local:
        return _searchLocalRecipesByIngredients(ingredients);
      case DataSource.hybrid:
        try {
          var apiResults = await SpoonacularService.searchByIngredients(
            ingredients: ingredients,
          );
          if (apiResults.isNotEmpty) return apiResults;
        } catch (e) {
          print('API ingredient search failed, falling back to local: $e');
        }
        return _searchLocalRecipesByIngredients(ingredients);
    }
  }

  // Get random recipes
  static Future<List<Recipe>> getRandomRecipes({int count = 12}) async {
    switch (_dataSource) {
      case DataSource.api:
        return await SpoonacularService.getRandomRecipes(number: count);
      case DataSource.local:
        var local = _getLocalRecipes();
        local.shuffle();
        return local.take(count).toList();
      case DataSource.hybrid:
        try {
          var apiResults = await SpoonacularService.getRandomRecipes(
            number: count,
          );
          if (apiResults.isNotEmpty) return apiResults;
        } catch (e) {
          print('API random recipes failed, falling back to local: $e');
        }
        var local = _getLocalRecipes();
        local.shuffle();
        return local.take(count).toList();
    }
  }

  // Get recipe by ID
  static Future<Recipe?> getRecipeById(String id) async {
    // Check cache first
    var cached = _cachedRecipes.where((r) => r.id == id).firstOrNull;
    if (cached != null) return cached;

    switch (_dataSource) {
      case DataSource.api:
        return await SpoonacularService.getRecipeById(id);
      case DataSource.local:
        return _getLocalRecipes().where((r) => r.id == id).firstOrNull;
      case DataSource.hybrid:
        try {
          var apiResult = await SpoonacularService.getRecipeById(id);
          if (apiResult != null) return apiResult;
        } catch (e) {
          print('API recipe fetch failed, falling back to local: $e');
        }
        return _getLocalRecipes().where((r) => r.id == id).firstOrNull;
    }
  }

  // Private helper methods
  static Future<List<Recipe>> _getApiRecipes() async {
    try {
      var recipes = await SpoonacularService.getRandomRecipes(
        number: 24,
      ); // Increased from 15 to 24
      _cachedRecipes = recipes;
      _lastFetchTime = DateTime.now();
      return recipes;
    } catch (e) {
      print('Failed to fetch API recipes: $e');
      return _getLocalRecipes();
    }
  }

  static List<Recipe> _getLocalRecipes() {
    return DummyData.recipes;
  }

  static Future<List<Recipe>> _getHybridRecipes() async {
    try {
      // Try API first
      var apiRecipes = await SpoonacularService.getRandomRecipes(
        number: 20,
      ); // Increased from 10 to 20
      var localRecipes = _getLocalRecipes();

      // Combine API and local recipes
      var combined = [...apiRecipes, ...localRecipes];

      // Remove duplicates based on title similarity
      var unique = <Recipe>[];
      for (var recipe in combined) {
        bool isDuplicate = unique.any(
          (existing) =>
              existing.title.toLowerCase() == recipe.title.toLowerCase(),
        );
        if (!isDuplicate) {
          unique.add(recipe);
        }
      }

      _cachedRecipes = unique;
      _lastFetchTime = DateTime.now();
      return unique;
    } catch (e) {
      print('Hybrid fetch failed, using local only: $e');
      return _getLocalRecipes();
    }
  }

  static List<Recipe> _searchLocalRecipes(String query) {
    var local = _getLocalRecipes();
    if (query.isEmpty) return local;

    return local
        .where(
          (recipe) =>
              recipe.title.toLowerCase().contains(query.toLowerCase()) ||
              recipe.description.toLowerCase().contains(query.toLowerCase()) ||
              recipe.ingredients.any(
                (ingredient) =>
                    ingredient.toLowerCase().contains(query.toLowerCase()),
              ) ||
              recipe.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }

  static List<Recipe> _filterLocalRecipesByCuisine(String cuisine) {
    return _getLocalRecipes()
        .where(
          (recipe) => recipe.tags.any(
            (tag) => tag.toLowerCase().contains(cuisine.toLowerCase()),
          ),
        )
        .toList();
  }

  static List<Recipe> _filterLocalRecipesByDiet(String diet) {
    return _getLocalRecipes()
        .where(
          (recipe) => recipe.tags.any(
            (tag) => tag.toLowerCase().contains(diet.toLowerCase()),
          ),
        )
        .toList();
  }

  static List<Recipe> _searchLocalRecipesByIngredients(
    List<String> ingredients,
  ) {
    return _getLocalRecipes().where((recipe) {
      return ingredients.any(
        (searchIngredient) => recipe.ingredients.any(
          (recipeIngredient) => recipeIngredient.toLowerCase().contains(
            searchIngredient.toLowerCase(),
          ),
        ),
      );
    }).toList();
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
