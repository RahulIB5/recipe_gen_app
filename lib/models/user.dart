import 'recipe.dart';

// Model class for User data and preferences
class User {
  final String id;
  final String name;
  final String email;
  final List<String> dietaryPreferences;
  final List<String> favoriteRecipeIds;
  final List<String> recipeHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.dietaryPreferences,
    required this.favoriteRecipeIds,
    required this.recipeHistory,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      dietaryPreferences: List<String>.from(json['dietaryPreferences']),
      favoriteRecipeIds: List<String>.from(json['favoriteRecipeIds']),
      recipeHistory: List<String>.from(json['recipeHistory']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dietaryPreferences': dietaryPreferences,
      'favoriteRecipeIds': favoriteRecipeIds,
      'recipeHistory': recipeHistory,
    };
  }

  // Helper method to copy user with updated data
  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? dietaryPreferences,
    List<String>? favoriteRecipeIds,
    List<String>? recipeHistory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      favoriteRecipeIds: favoriteRecipeIds ?? this.favoriteRecipeIds,
      recipeHistory: recipeHistory ?? this.recipeHistory,
    );
  }
}

// Model for AI Recipe Generation Request
class RecipeGenerationRequest {
  final List<String> ingredients;
  final List<String> dietaryRestrictions;
  final String? cuisine;
  final int? cookingTime;

  RecipeGenerationRequest({
    required this.ingredients,
    this.dietaryRestrictions = const [],
    this.cuisine,
    this.cookingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients,
      'dietaryRestrictions': dietaryRestrictions,
      'cuisine': cuisine,
      'cookingTime': cookingTime,
    };
  }
}

// Model for Image Recognition Result
class ImageRecognitionResult {
  final String detectedDish;
  final double confidence;
  final Recipe? suggestedRecipe;
  final List<String> possibleIngredients;

  ImageRecognitionResult({
    required this.detectedDish,
    required this.confidence,
    this.suggestedRecipe,
    required this.possibleIngredients,
  });

  factory ImageRecognitionResult.fromJson(Map<String, dynamic> json) {
    return ImageRecognitionResult(
      detectedDish: json['detectedDish'],
      confidence: json['confidence'].toDouble(),
      suggestedRecipe: json['suggestedRecipe'] != null 
          ? Recipe.fromJson(json['suggestedRecipe'])
          : null,
      possibleIngredients: List<String>.from(json['possibleIngredients']),
    );
  }
}