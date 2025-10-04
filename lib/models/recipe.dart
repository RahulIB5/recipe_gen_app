// Model class for Recipe data
class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final NutritionInfo nutritionInfo;
  final int cookingTime; // in minutes
  final String difficulty; // Easy, Medium, Hard
  final List<String> tags; // vegan, keto, etc.

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.nutritionInfo,
    required this.cookingTime,
    required this.difficulty,
    required this.tags,
  });

  // Convert from JSON (for future API integration)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      nutritionInfo: NutritionInfo.fromJson(json['nutritionInfo']),
      cookingTime: json['cookingTime'],
      difficulty: json['difficulty'],
      tags: List<String>.from(json['tags']),
    );
  }

  // Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'nutritionInfo': nutritionInfo.toJson(),
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'tags': tags,
    };
  }
}

// Model class for Nutrition Information
class NutritionInfo {
  final int calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final double fiber; // in grams

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
}