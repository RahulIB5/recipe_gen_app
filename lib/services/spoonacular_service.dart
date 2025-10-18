import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../config/api_config.dart';

class SpoonacularService {
  static const String _baseUrl = ApiConfig.spoonacularBaseUrl;
  static const String _apiKey = ApiConfig.spoonacularApiKey;

  // Check if API key is configured
  static bool get isApiKeyConfigured =>
      _apiKey != 'YOUR_API_KEY_HERE' && _apiKey.isNotEmpty;

  // Search recipes by query
  static Future<List<Recipe>> searchRecipes({
    String query = '',
    String cuisine = '',
    String diet = '',
    String type = '',
    int number = 12,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'apiKey': _apiKey,
        'number': number.toString(),
        'offset': offset.toString(),
        'addRecipeInformation': 'true',
        'fillIngredients': 'true',
        'addRecipeNutrition': 'true',
      };

      if (query.isNotEmpty) queryParams['query'] = query;
      if (cuisine.isNotEmpty) queryParams['cuisine'] = cuisine;
      if (diet.isNotEmpty) queryParams['diet'] = diet;
      if (type.isNotEmpty) queryParams['type'] = type;

      final uri = Uri.parse(
        '$_baseUrl/recipes/complexSearch',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((json) => Recipe.fromSpoonacularJson(json)).toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackRecipes();
      }
    } catch (e) {
      print('Network Error: $e');
      return _getFallbackRecipes();
    }
  }

  // Get random recipes
  static Future<List<Recipe>> getRandomRecipes({
    int number = 12,
    String tags = '',
  }) async {
    try {
      final queryParams = <String, String>{
        'apiKey': _apiKey,
        'number': number.toString(),
        'include-nutrition': 'true',
      };

      if (tags.isNotEmpty) queryParams['tags'] = tags;

      final uri = Uri.parse(
        '$_baseUrl/recipes/random',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recipes = data['recipes'] as List;

        return recipes.map((json) => Recipe.fromSpoonacularJson(json)).toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackRecipes();
      }
    } catch (e) {
      print('Network Error: $e');
      return _getFallbackRecipes();
    }
  }

  // Get recipe by ID with full details
  static Future<Recipe?> getRecipeById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/recipes/$id/information').replace(
        queryParameters: {'apiKey': _apiKey, 'includeNutrition': 'true'},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Recipe.fromSpoonacularJson(data);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  // Search recipes by ingredients
  static Future<List<Recipe>> searchByIngredients({
    required List<String> ingredients,
    int number = 12,
    int ranking = 1,
  }) async {
    try {
      final queryParams = {
        'apiKey': _apiKey,
        'ingredients': ingredients.join(','),
        'number': number.toString(),
        'ranking': ranking.toString(),
        'ignorePantry': 'true',
      };

      final uri = Uri.parse(
        '$_baseUrl/recipes/findByIngredients',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;

        // Get detailed information for each recipe
        final List<Recipe> detailedRecipes = [];
        for (var result in results.take(number)) {
          final recipe = await getRecipeById(result['id'].toString());
          if (recipe != null) {
            detailedRecipes.add(recipe);
          }
        }

        return detailedRecipes;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackRecipes();
      }
    } catch (e) {
      print('Network Error: $e');
      return _getFallbackRecipes();
    }
  }

  // Get recipe suggestions based on image analysis
  static Future<List<Recipe>> analyzeImageForRecipes(String imagePath) async {
    try {
      // For demo purposes, return cuisine-based recipes
      // In a real implementation, you would upload the image to Spoonacular's image analysis endpoint
      return await getRandomRecipes(number: 6);
    } catch (e) {
      print('Image Analysis Error: $e');
      return _getFallbackRecipes();
    }
  }

  // Fallback recipes when API fails
  static List<Recipe> _getFallbackRecipes() {
    return [
      Recipe(
        id: 'fallback_1',
        title: 'Classic Spaghetti Carbonara',
        description:
            'A traditional Italian pasta dish with eggs, cheese, and pancetta.',
        imageUrl:
            'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
        ingredients: [
          '400g spaghetti',
          '200g pancetta',
          '4 large eggs',
          '100g Parmesan cheese',
          'Black pepper',
          'Salt',
        ],
        instructions: [
          'Cook spaghetti according to package instructions.',
          'Fry pancetta until crispy.',
          'Beat eggs with grated Parmesan.',
          'Combine hot pasta with pancetta.',
          'Add egg mixture off heat, stirring quickly.',
          'Season with black pepper and serve.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 580,
          protein: 28.0,
          carbs: 65.0,
          fat: 22.0,
          fiber: 3.0,
        ),
        cookingTime: 20,
        difficulty: 'Medium',
        tags: ['Italian', 'Pasta', 'Quick'],
      ),
      // Add a few more fallback recipes...
    ];
  }

  // Helper method to get cuisine-specific recipes
  static Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    return await searchRecipes(cuisine: cuisine, number: 12);
  }

  // Helper method to get diet-specific recipes
  static Future<List<Recipe>> getRecipesByDiet(String diet) async {
    return await searchRecipes(diet: diet, number: 12);
  }
}
