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

  // Convert from Spoonacular API JSON
  factory Recipe.fromSpoonacularJson(Map<String, dynamic> json) {
    // Extract ingredients from Spoonacular format
    List<String> ingredients = [];
    if (json['extendedIngredients'] != null) {
      ingredients = (json['extendedIngredients'] as List)
          .map((ingredient) => ingredient['original'] as String)
          .toList();
    }

    // Extract instructions from Spoonacular format
    List<String> instructions = [];
    if (json['analyzedInstructions'] != null &&
        (json['analyzedInstructions'] as List).isNotEmpty) {
      var steps = json['analyzedInstructions'][0]['steps'] as List;
      instructions = steps.map((step) => step['step'] as String).toList();
    } else if (json['instructions'] != null) {
      // Fallback to simple instructions string
      instructions = [json['instructions']];
    }

    // Extract nutrition info from Spoonacular format
    NutritionInfo nutritionInfo;
    if (json['nutrition'] != null && json['nutrition']['nutrients'] != null) {
      var nutrients = json['nutrition']['nutrients'] as List;

      double getNutrientAmount(String name) {
        var nutrient = nutrients.firstWhere(
          (n) => n['name'].toLowerCase() == name.toLowerCase(),
          orElse: () => {'amount': 0.0},
        );
        return (nutrient['amount'] ?? 0.0).toDouble();
      }

      nutritionInfo = NutritionInfo(
        calories: getNutrientAmount('Calories').round(),
        protein: getNutrientAmount('Protein'),
        carbs: getNutrientAmount('Carbohydrates'),
        fat: getNutrientAmount('Fat'),
        fiber: getNutrientAmount('Fiber'),
      );
    } else {
      // Default nutrition info if not available
      nutritionInfo = NutritionInfo(
        calories: 300,
        protein: 15.0,
        carbs: 30.0,
        fat: 10.0,
        fiber: 5.0,
      );
    }

    // Extract tags/diet labels
    List<String> tags = [];
    if (json['diets'] != null) {
      tags.addAll(List<String>.from(json['diets']));
    }
    if (json['dishTypes'] != null) {
      tags.addAll(List<String>.from(json['dishTypes']));
    }
    if (json['cuisines'] != null) {
      tags.addAll(List<String>.from(json['cuisines']));
    }

    // Determine difficulty based on cooking time and complexity
    String difficulty = 'Easy';
    int cookingTime = json['readyInMinutes'] ?? 30;
    if (cookingTime > 60 ||
        (json['analyzedInstructions'] != null &&
            json['analyzedInstructions'].isNotEmpty &&
            (json['analyzedInstructions'][0]['steps'] as List).length > 8)) {
      difficulty = 'Hard';
    } else if (cookingTime > 30 || ingredients.length > 8) {
      difficulty = 'Medium';
    }

    return Recipe(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Recipe',
      description:
          json['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ??
          'A delicious recipe from Spoonacular.',
      imageUrl:
          json['image'] ??
          'https://images.unsplash.com/photo-1546548970-71785318a17b?w=400',
      ingredients: ingredients,
      instructions: instructions,
      nutritionInfo: nutritionInfo,
      cookingTime: cookingTime,
      difficulty: difficulty,
      tags: tags,
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
