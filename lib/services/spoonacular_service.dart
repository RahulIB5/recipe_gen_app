import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../config/api_config.dart';

/// Service for interacting with the Spoonacular API
class SpoonacularService {
  /// Search recipes using complex search with query text
  static Future<List<Recipe>> searchRecipes({
    required String query,
    int number = 12,
    String? cuisine,
    String? diet,
    String? type,
    int? maxReadyTime,
  }) async {
    try {
      final url = ApiConfig.buildComplexSearchUrl(
        query: query,
        number: number,
        cuisine: cuisine,
        diet: diet,
        type: type,
        maxReadyTime: maxReadyTime,
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw 'Spoonacular API error: ${response.statusCode}';
      }
      
      final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = jsonData['results'] as List<dynamic>? ?? [];
      
      if (results.isEmpty) {
        throw 'No recipes found for "$query".';
      }
      
      // Convert search results to Recipe objects
      final List<Recipe> recipes = [];
      for (final item in results) {
        if (item is Map<String, dynamic>) {
          try {
            final recipe = _convertSearchResult(item);
            recipes.add(recipe);
          } catch (e) {
            print('Error converting search result: $e');
          }
        }
      }
      
      return recipes;
    } catch (e) {
      rethrow;
    }
  }

  /// Find recipes by ingredients
  static Future<List<Recipe>> findRecipesByIngredients(List<String> ingredients) async {
    try {
      final url = ApiConfig.buildFindByIngredientsUrl(ingredients: ingredients);
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw 'Spoonacular API error: ${response.statusCode}';
      }
      
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      if (jsonList.isEmpty) {
        throw 'No recipes found for the selected ingredients.';
      }
      
      // Convert each recipe result and fetch detailed information
      final List<Recipe> recipes = [];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            // Get the recipe ID and fetch detailed information
            final recipeId = item['id'] as int?;
            if (recipeId != null) {
              // Fetch detailed recipe information
              final detailedRecipe = await getDetailedRecipe(recipeId);
              
              // Enhance with match percentage from basic data
              final int usedCount = item['usedIngredientCount'] ?? 0;
              final int missedCount = item['missedIngredientCount'] ?? 0;
              final int totalIngredients = usedCount + missedCount;
              final int matchPercentage = totalIngredients > 0 ? (usedCount * 100 ~/ totalIngredients) : 0;
              
              // Update description and tags with match information
              final enhancedRecipe = Recipe(
                id: detailedRecipe.id,
                title: detailedRecipe.title,
                description: 'Uses $usedCount of your ingredients ($matchPercentage% match). Missing $missedCount ingredients.\n\n${detailedRecipe.description}',
                imageUrl: detailedRecipe.imageUrl,
                ingredients: detailedRecipe.ingredients,
                instructions: detailedRecipe.instructions,
                nutritionInfo: detailedRecipe.nutritionInfo,
                cookingTime: detailedRecipe.cookingTime,
                difficulty: detailedRecipe.difficulty,
                tags: [...detailedRecipe.tags, '$matchPercentage% match'],
              );
              
              recipes.add(enhancedRecipe);
            } else {
              // Fallback to basic recipe if ID is missing
              recipes.add(_convertBasicRecipe(item, ingredients));
            }
          } catch (e) {
            // If detailed fetch fails, fallback to basic recipe
            print('Failed to fetch detailed recipe: $e');
            recipes.add(_convertBasicRecipe(item, ingredients));
          }
        }
      }
      
      return recipes;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get detailed recipe information including instructions and nutrition
  static Future<Recipe> getDetailedRecipe(int recipeId) async {
    try {
      final url = ApiConfig.buildRecipeInformationUrl(
        recipeId: recipeId,
        includeNutrition: true,
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw 'Spoonacular API error: ${response.statusCode}';
      }
      
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      return _convertDetailedRecipe(json);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Convert basic recipe data from findByIngredients endpoint
  static Recipe _convertBasicRecipe(Map<String, dynamic> data, List<String> searchIngredients) {
    // Gather ingredients (used + missed) as readable strings
    final List<String> ingredients = [];
    if (data['usedIngredients'] is List) {
      for (final u in data['usedIngredients']) {
        if (u is Map<String, dynamic> && u['original'] != null) {
          ingredients.add(u['original'] as String);
        }
      }
    }
    if (data['missedIngredients'] is List) {
      for (final m in data['missedIngredients']) {
        if (m is Map<String, dynamic> && m['original'] != null) {
          ingredients.add(m['original'] as String);
        }
      }
    }
    
    final int usedCount = data['usedIngredientCount'] ?? 0;
    final int missedCount = data['missedIngredientCount'] ?? 0;
    final int totalIngredients = usedCount + missedCount;
    final int matchPercentage = totalIngredients > 0 ? (usedCount * 100 ~/ totalIngredients) : 0;
    
    return Recipe(
      id: (data['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: data['title'] ?? 'Recipe',
      description: 'Uses $usedCount of your ingredients ($matchPercentage% match). Missing $missedCount ingredients.',
      imageUrl: data['image'] ?? '',
      ingredients: ingredients.isNotEmpty ? ingredients : searchIngredients,
      instructions: [
        'This is a basic recipe preview.',
        'Tap to load full instructions and nutrition information.',
        'Ingredients: ${ingredients.take(3).join(', ')}${ingredients.length > 3 ? '...' : ''}',
      ],
      nutritionInfo: NutritionInfo(
        calories: 0,
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
        fiber: 0.0,
      ),
      cookingTime: 30,
      difficulty: 'Medium',
      tags: ['Spoonacular', '$matchPercentage% match'],
    );
  }
  
  /// Convert detailed recipe data from recipe information endpoint
  static Recipe _convertDetailedRecipe(Map<String, dynamic> data) {
    // Extract ingredients
    final List<String> ingredients = [];
    if (data['extendedIngredients'] is List) {
      for (final ingredient in data['extendedIngredients']) {
        if (ingredient is Map<String, dynamic> && ingredient['original'] != null) {
          ingredients.add(ingredient['original'] as String);
        }
      }
    }
    
    // Extract instructions
    final List<String> instructions = [];
    if (data['analyzedInstructions'] is List && (data['analyzedInstructions'] as List).isNotEmpty) {
      final instructionData = (data['analyzedInstructions'] as List)[0];
      if (instructionData is Map<String, dynamic> && instructionData['steps'] is List) {
        for (final step in instructionData['steps']) {
          if (step is Map<String, dynamic> && step['step'] != null) {
            instructions.add(step['step'] as String);
          }
        }
      }
    }
    
    // If no structured instructions, try the summary
    if (instructions.isEmpty && data['instructions'] != null) {
      final String instructionText = data['instructions'] as String;
      // Simple split by periods for basic instruction parsing
      instructions.addAll(
        instructionText.split('.').where((s) => s.trim().isNotEmpty).map((s) => s.trim() + '.').toList()
      );
    }
    
    // Extract nutrition
    NutritionInfo nutrition = NutritionInfo(
      calories: 0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      fiber: 0.0,
    );
    
    if (data['nutrition'] is Map<String, dynamic>) {
      final nutritionData = data['nutrition'] as Map<String, dynamic>;
      if (nutritionData['nutrients'] is List) {
        final nutrients = nutritionData['nutrients'] as List;
        double calories = 0, protein = 0, carbs = 0, fat = 0, fiber = 0;
        
        for (final nutrient in nutrients) {
          if (nutrient is Map<String, dynamic>) {
            final name = nutrient['name'] as String?;
            final amount = (nutrient['amount'] as num?)?.toDouble() ?? 0.0;
            
            switch (name?.toLowerCase()) {
              case 'calories':
                calories = amount;
                break;
              case 'protein':
                protein = amount;
                break;
              case 'carbohydrates':
                carbs = amount;
                break;
              case 'fat':
                fat = amount;
                break;
              case 'fiber':
                fiber = amount;
                break;
            }
          }
        }
        
        nutrition = NutritionInfo(
          calories: calories.round(),
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
        );
      }
    }
    
    // Extract tags
    final List<String> tags = ['Spoonacular'];
    if (data['diets'] is List) {
      tags.addAll((data['diets'] as List).cast<String>());
    }
    if (data['dishTypes'] is List) {
      tags.addAll((data['dishTypes'] as List).cast<String>());
    }
    
    return Recipe(
      id: (data['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: data['title'] ?? 'Recipe',
      description: data['summary']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? 'Delicious recipe from Spoonacular',
      imageUrl: data['image'] ?? '',
      ingredients: ingredients,
      instructions: instructions.isNotEmpty ? instructions : ['Instructions not available'],
      nutritionInfo: nutrition,
      cookingTime: (data['readyInMinutes'] as int?) ?? 30,
      difficulty: _getDifficulty(data['readyInMinutes'] as int?),
      tags: tags,
    );
  }
  
  /// Determine difficulty based on cooking time
  static String _getDifficulty(int? cookingTime) {
    if (cookingTime == null) return 'Medium';
    if (cookingTime <= 15) return 'Easy';
    if (cookingTime <= 45) return 'Medium';
    return 'Hard';
  }
  
  /// Convert search result from complexSearch endpoint
  static Recipe _convertSearchResult(Map<String, dynamic> data) {
    // Extract ingredients
    final List<String> ingredients = [];
    if (data['extendedIngredients'] is List) {
      for (final ingredient in data['extendedIngredients']) {
        if (ingredient is Map<String, dynamic> && ingredient['original'] != null) {
          ingredients.add(ingredient['original'] as String);
        }
      }
    }
    
    // Extract instructions if available
    final List<String> instructions = [];
    if (data['analyzedInstructions'] is List && (data['analyzedInstructions'] as List).isNotEmpty) {
      final instructionData = (data['analyzedInstructions'] as List)[0];
      if (instructionData is Map<String, dynamic> && instructionData['steps'] is List) {
        for (final step in instructionData['steps']) {
          if (step is Map<String, dynamic> && step['step'] != null) {
            instructions.add(step['step'] as String);
          }
        }
      }
    }
    
    // If no instructions, add placeholder
    if (instructions.isEmpty) {
      instructions.add('Tap to load full recipe instructions and details...');
    }
    
    // Extract nutrition info if available
    NutritionInfo nutrition = NutritionInfo(
      calories: 0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      fiber: 0.0,
    );
    
    if (data['nutrition'] is Map<String, dynamic>) {
      final nutritionData = data['nutrition'] as Map<String, dynamic>;
      if (nutritionData['nutrients'] is List) {
        final nutrients = nutritionData['nutrients'] as List;
        double calories = 0, protein = 0, carbs = 0, fat = 0, fiber = 0;
        
        for (final nutrient in nutrients) {
          if (nutrient is Map<String, dynamic>) {
            final name = nutrient['name'] as String?;
            final amount = (nutrient['amount'] as num?)?.toDouble() ?? 0.0;
            
            switch (name?.toLowerCase()) {
              case 'calories':
                calories = amount;
                break;
              case 'protein':
                protein = amount;
                break;
              case 'carbohydrates':
                carbs = amount;
                break;
              case 'fat':
                fat = amount;
                break;
              case 'fiber':
                fiber = amount;
                break;
            }
          }
        }
        
        nutrition = NutritionInfo(
          calories: calories.round(),
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
        );
      }
    }
    
    // Extract tags
    final List<String> tags = ['Spoonacular'];
    if (data['diets'] is List) {
      tags.addAll((data['diets'] as List).cast<String>());
    }
    if (data['dishTypes'] is List) {
      tags.addAll((data['dishTypes'] as List).cast<String>());
    }
    if (data['cuisines'] is List) {
      tags.addAll((data['cuisines'] as List).cast<String>());
    }
    
    // Clean and truncate summary for description
    String description = 'Delicious recipe from Spoonacular';
    if (data['summary'] != null) {
      description = data['summary'].toString()
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
          .trim();
      
      // Truncate if too long
      if (description.length > 150) {
        description = '${description.substring(0, 147)}...';
      }
    }
    
    return Recipe(
      id: (data['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: data['title'] ?? 'Recipe',
      description: description,
      imageUrl: data['image'] ?? '',
      ingredients: ingredients.isNotEmpty ? ingredients : ['Ingredients will be loaded with full recipe details'],
      instructions: instructions,
      nutritionInfo: nutrition,
      cookingTime: (data['readyInMinutes'] as int?) ?? 30,
      difficulty: _getDifficulty(data['readyInMinutes'] as int?),
      tags: tags,
    );
  }
}