import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration for external API services
/// API keys are now loaded from environment variables for security
class ApiConfig {
  // Spoonacular API configuration
  static String get spoonacularApiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  static String get spoonacularBaseUrl => dotenv.env['SPOONACULAR_BASE_URL'] ?? 'https://api.spoonacular.com';
  
  // API endpoints
  static const String findByIngredientsEndpoint = '/recipes/findByIngredients';
  static const String recipeInformationEndpoint = '/recipes';
  static const String complexSearchEndpoint = '/recipes/complexSearch';
  
  /// Build URL for finding recipes by ingredients
  static Uri buildFindByIngredientsUrl({
    required List<String> ingredients,
    int number = 10,
  }) {
    final ingredientsParam = ingredients.map((s) => Uri.encodeComponent(s)).join(',');
    return Uri.parse(
      '$spoonacularBaseUrl$findByIngredientsEndpoint?ingredients=$ingredientsParam&number=$number&apiKey=$spoonacularApiKey'
    );
  }
  
  /// Build URL for getting detailed recipe information
  static Uri buildRecipeInformationUrl({
    required int recipeId,
    bool includeNutrition = true,
    bool addWinePairing = false,
    bool addTasteData = false,
  }) {
    final params = <String, String>{
      'apiKey': spoonacularApiKey,
      'includeNutrition': includeNutrition.toString(),
    };
    
    if (addWinePairing) params['addWinePairing'] = 'true';
    if (addTasteData) params['addTasteData'] = 'true';
    
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return Uri.parse('$spoonacularBaseUrl$recipeInformationEndpoint/$recipeId/information?$query');
  }
  
  /// Build URL for complex recipe search
  static Uri buildComplexSearchUrl({
    required String query,
    int number = 12,
    String? cuisine,
    String? diet,
    String? type,
    int? maxReadyTime,
  }) {
    final params = <String, String>{
      'apiKey': spoonacularApiKey,
      'query': Uri.encodeComponent(query),
      'number': number.toString(),
      'addRecipeInformation': 'true',
      'fillIngredients': 'true',
    };
    
    if (cuisine != null) params['cuisine'] = Uri.encodeComponent(cuisine);
    if (diet != null) params['diet'] = Uri.encodeComponent(diet);
    if (type != null) params['type'] = Uri.encodeComponent(type);
    if (maxReadyTime != null) params['maxReadyTime'] = maxReadyTime.toString();
    
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return Uri.parse('$spoonacularBaseUrl$complexSearchEndpoint?$queryString');
  }
}