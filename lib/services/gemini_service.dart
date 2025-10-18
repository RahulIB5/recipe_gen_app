import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';
import '../models/recipe.dart';
import 'dart:convert';
import 'dart:typed_data';

class GeminiService {
  static GenerativeModel? _model;
  static GenerativeModel? _visionModel;

  // Initialize Gemini AI models
  static void initialize() {
    if (ApiConfig.geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiConfig.geminiApiKey,
      );

      _visionModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiConfig.geminiApiKey,
      );
    }
  }

  // Generate recipe suggestions based on ingredients
  static Future<List<Recipe>> generateRecipeFromIngredients(
    List<String> ingredients,
  ) async {
    try {
      if (_model == null) {
        throw Exception('Gemini API key not configured');
      }

      final prompt =
          '''
Generate 3 creative and practical recipes using these ingredients: ${ingredients.join(', ')}.

For each recipe, provide the response in this exact JSON format:
{
  "recipes": [
    {
      "title": "Recipe Name",
      "description": "Brief description of the dish",
      "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400",
      "cookingTime": 30,
      "difficulty": "Easy",
      "ingredients": [
        "2 cups flour",
        "1 tsp salt",
        "3 eggs"
      ],
      "instructions": [
        "Step 1: Detailed instruction",
        "Step 2: Detailed instruction",
        "Step 3: Detailed instruction"
      ],
      "tags": ["main course", "quick meal"]
    }
  ]
}

Make the recipes practical, delicious, and use the provided ingredients as primary components. Include cooking times and step-by-step instructions.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text != null) {
        return _parseGeminiRecipeResponse(response.text!);
      } else {
        throw Exception('No response from Gemini API');
      }
    } catch (e) {
      print('Error generating recipe from ingredients: $e');
      return _getFallbackRecipes(ingredients);
    }
  }

  // Generate recipe from image using Gemini Vision
  static Future<Recipe?> generateRecipeFromImage(List<int> imageBytes) async {
    try {
      if (_visionModel == null) {
        throw Exception('Gemini Vision API key not configured');
      }

      final prompt = '''
Analyze this food image and identify the dish. Then generate a complete recipe for this dish.

Provide the response in this exact JSON format:
{
  "title": "Dish Name",
  "description": "Description of what you see in the image and the dish",
  "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400",
  "cookingTime": 45,
  "difficulty": "Medium",
  "ingredients": [
    "1 cup flour",
    "2 eggs",
    "1 tsp salt"
  ],
  "instructions": [
    "Step 1: Detailed cooking instruction",
    "Step 2: Detailed cooking instruction",
    "Step 3: Detailed cooking instruction"
  ],
  "tags": ["main course", "comfort food"]
}

Be specific about the dish you identify and provide authentic cooking instructions.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ]),
      ];

      final response = await _visionModel!.generateContent(content);

      if (response.text != null) {
        final recipes = _parseGeminiRecipeResponse(response.text!);
        return recipes.isNotEmpty ? recipes.first : null;
      } else {
        throw Exception('No response from Gemini Vision API');
      }
    } catch (e) {
      print('Error generating recipe from image: $e');
      return _getFallbackImageRecipe();
    }
  }

  // Parse Gemini API response into Recipe objects
  static List<Recipe> _parseGeminiRecipeResponse(String response) {
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }

      final data = json.decode(cleanResponse);
      final List<Recipe> recipes = [];

      if (data['recipes'] != null) {
        for (final recipeData in data['recipes']) {
          recipes.add(_createRecipeFromGeminiData(recipeData));
        }
      } else {
        // Single recipe format
        recipes.add(_createRecipeFromGeminiData(data));
      }

      return recipes;
    } catch (e) {
      print('Error parsing Gemini response: $e');
      return [];
    }
  }

  // Create Recipe object from Gemini data
  static Recipe _createRecipeFromGeminiData(Map<String, dynamic> data) {
    // Extract ingredients
    List<String> ingredients = [];
    if (data['ingredients'] != null) {
      ingredients = List<String>.from(data['ingredients']);
    }

    // Extract instructions
    List<String> instructions = [];
    if (data['instructions'] != null) {
      instructions = List<String>.from(data['instructions']);
    }

    // Extract tags
    List<String> tags = [];
    if (data['tags'] != null) {
      tags = List<String>.from(data['tags']);
    }

    // Create nutrition info
    NutritionInfo nutritionInfo = NutritionInfo(
      calories: 300,
      protein: 15.0,
      carbs: 30.0,
      fat: 10.0,
      fiber: 5.0,
    );

    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'AI Generated Recipe',
      description: data['description'] ?? 'Generated by AI',
      imageUrl:
          data['imageUrl'] ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      ingredients: ingredients,
      instructions: instructions,
      nutritionInfo: nutritionInfo,
      cookingTime: data['cookingTime'] ?? 30,
      difficulty: data['difficulty'] ?? 'Medium',
      tags: tags,
    );
  }

  // Fallback recipes when AI is unavailable
  static List<Recipe> _getFallbackRecipes(List<String> ingredients) {
    return [
      Recipe(
        id: '999001',
        title: 'Simple ${ingredients.first} Dish',
        description:
            'A simple dish using ${ingredients.join(', ')}. AI service temporarily unavailable.',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        ingredients: ingredients,
        instructions: [
          'Prepare all ingredients',
          'Combine ingredients as desired',
          'Cook until done',
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 12.0,
          carbs: 25.0,
          fat: 8.0,
          fiber: 3.0,
        ),
        cookingTime: 25,
        difficulty: 'Easy',
        tags: ['quick meal', 'simple'],
      ),
    ];
  }

  // Fallback recipe for image recognition
  static Recipe _getFallbackImageRecipe() {
    return Recipe(
      id: '999002',
      title: 'Dish Recognition Unavailable',
      description:
          'AI image recognition temporarily unavailable. Please try again later.',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      ingredients: ['Various ingredients as needed'],
      instructions: ['Please upload image again when service is available'],
      nutritionInfo: NutritionInfo(
        calories: 300,
        protein: 15.0,
        carbs: 30.0,
        fat: 10.0,
        fiber: 5.0,
      ),
      cookingTime: 30,
      difficulty: 'Medium',
      tags: ['placeholder'],
    );
  }

  // Check if Gemini services are available
  static bool get isAvailable => _model != null;
  static bool get isVisionAvailable => _visionModel != null;
}
