import '../models/recipe.dart';
import '../models/user.dart';

// Dummy data for recipes - In a real app, this would come from an API
class DummyData {
  static List<Recipe> get recipes => [
    Recipe(
      id: '1',
      title: 'Margherita Pizza',
      description: 'Classic Italian pizza with fresh tomatoes, mozzarella, and basil',
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500',
      ingredients: [
        '1 pizza dough',
        '200g tomato sauce',
        '200g fresh mozzarella',
        'Fresh basil leaves',
        '2 tbsp olive oil',
        '1 clove garlic',
        'Salt and pepper',
        'Parmesan cheese (optional)'
      ],
      instructions: [
        'Preheat oven to 475°F (245°C)',
        'Roll out pizza dough on floured surface',
        'Spread tomato sauce evenly on dough',
        'Add torn mozzarella pieces',
        'Drizzle with olive oil',
        'Bake for 12-15 minutes until crust is golden',
        'Add fresh basil leaves before serving'
      ],
      nutritionInfo: NutritionInfo(
        calories: 520,
        protein: 22.0,
        carbs: 58.0,
        fat: 24.0,
        fiber: 4.0,
      ),
      cookingTime: 25,
      difficulty: 'Medium',
      tags: ['Italian', 'Pizza', 'Vegetarian'],
    ),
    Recipe(
      id: '2',
      title: 'Chicken Caesar Salad',
      description: 'Fresh romaine lettuce with grilled chicken and classic Caesar dressing',
      imageUrl: 'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=500',
      ingredients: [
        '2 chicken breasts',
        '1 head romaine lettuce',
        '1/2 cup Caesar dressing',
        '1/4 cup Parmesan cheese',
        '1 cup croutons',
        '2 tbsp olive oil',
        'Salt and pepper'
      ],
      instructions: [
        'Season chicken with salt and pepper',
        'Heat olive oil in a pan and cook chicken until done',
        'Wash and chop romaine lettuce',
        'Slice cooked chicken',
        'Toss lettuce with Caesar dressing',
        'Top with chicken, Parmesan, and croutons'
      ],
      nutritionInfo: NutritionInfo(
        calories: 420,
        protein: 35.0,
        carbs: 15.0,
        fat: 25.0,
        fiber: 4.0,
      ),
      cookingTime: 25,
      difficulty: 'Easy',
      tags: ['Healthy', 'Salad', 'Protein'],
    ),
    Recipe(
      id: '3',
      title: 'Avocado Toast',
      description: 'Simple and nutritious breakfast with creamy avocado on toast',
      imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=500',
      ingredients: [
        '2 slices whole grain bread',
        '1 ripe avocado',
        '1 tbsp lemon juice',
        'Salt and pepper',
        'Red pepper flakes',
        '1 tomato (optional)',
        'Olive oil drizzle'
      ],
      instructions: [
        'Toast the bread slices until golden',
        'Mash avocado with lemon juice, salt, and pepper',
        'Spread avocado mixture on toast',
        'Add sliced tomato if desired',
        'Sprinkle with red pepper flakes',
        'Drizzle with olive oil and serve'
      ],
      nutritionInfo: NutritionInfo(
        calories: 280,
        protein: 8.0,
        carbs: 30.0,
        fat: 18.0,
        fiber: 12.0,
      ),
      cookingTime: 10,
      difficulty: 'Easy',
      tags: ['Breakfast', 'Healthy', 'Vegan', 'Quick'],
    ),
    Recipe(
      id: '4',
      title: 'Beef Stir Fry',
      description: 'Quick and flavorful Asian-inspired beef with vegetables',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500',
      ingredients: [
        '500g beef strips',
        '2 bell peppers',
        '1 onion',
        '2 cloves garlic',
        '2 tbsp soy sauce',
        '1 tbsp oyster sauce',
        '1 tsp sesame oil',
        '2 tbsp vegetable oil'
      ],
      instructions: [
        'Heat vegetable oil in a wok or large pan',
        'Cook beef strips until browned',
        'Remove beef and set aside',
        'Stir-fry vegetables until crisp-tender',
        'Return beef to pan',
        'Add sauces and stir to combine',
        'Serve over rice'
      ],
      nutritionInfo: NutritionInfo(
        calories: 450,
        protein: 40.0,
        carbs: 12.0,
        fat: 28.0,
        fiber: 3.0,
      ),
      cookingTime: 15,
      difficulty: 'Medium',
      tags: ['Asian', 'Quick', 'Protein'],
    ),
    Recipe(
      id: '5',
      title: 'Greek Yogurt Parfait',
      description: 'Layered breakfast with yogurt, berries, and granola',
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
      ingredients: [
        '1 cup Greek yogurt',
        '1/2 cup mixed berries',
        '1/4 cup granola',
        '1 tbsp honey',
        '1 tbsp chopped nuts',
        'Mint leaves (garnish)'
      ],
      instructions: [
        'Layer yogurt in a glass or bowl',
        'Add a layer of berries',
        'Sprinkle granola over berries',
        'Repeat layers as desired',
        'Drizzle with honey',
        'Top with nuts and mint'
      ],
      nutritionInfo: NutritionInfo(
        calories: 320,
        protein: 20.0,
        carbs: 35.0,
        fat: 12.0,
        fiber: 5.0,
      ),
      cookingTime: 5,
      difficulty: 'Easy',
      tags: ['Breakfast', 'Healthy', 'Quick', 'Vegetarian'],
    ),
  ];

  // Dummy user data
  static User get currentUser => User(
    id: 'user1',
    name: 'Alex Johnson',
    email: 'alex.johnson@email.com',
    dietaryPreferences: ['Vegetarian'],
    favoriteRecipeIds: ['1', '3'],
    recipeHistory: ['1', '2', '3'],
  );

  // Available dietary preferences
  static List<String> get dietaryOptions => [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Dairy-Free',
    'Nut-Free',
  ];

  // Mock AI recipe generation
  static Recipe generateRecipeFromIngredients(List<String> ingredients) {
    // Simple mock logic - in real app, this would call Gemini API
    String title = 'AI Generated Recipe with ${ingredients.take(2).join(' & ')}';
    
    return Recipe(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'A delicious recipe created just for you using your available ingredients',
      imageUrl: 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=500',
      ingredients: [
        ...ingredients,
        'Salt and pepper to taste',
        'Olive oil',
        '1 onion',
      ],
      instructions: [
        'Prepare all ingredients by washing and chopping as needed',
        'Heat olive oil in a large pan over medium heat',
        'Add onion and cook until fragrant',
        'Add main ingredients: ${ingredients.join(', ')}',
        'Season with salt and pepper',
        'Cook until everything is well combined and heated through',
        'Taste and adjust seasoning as needed',
        'Serve hot and enjoy your AI-created meal!'
      ],
      nutritionInfo: NutritionInfo(
        calories: 350,
        protein: 15.0,
        carbs: 25.0,
        fat: 20.0,
        fiber: 6.0,
      ),
      cookingTime: 30,
      difficulty: 'Medium',
      tags: ['AI Generated', 'Custom'],
    );
  }

  // Mock image recognition results
  static ImageRecognitionResult mockImageRecognition() {
    List<String> dishes = ['Pizza', 'Burger', 'Salad', 'Pasta', 'Soup'];
    String detectedDish = dishes[DateTime.now().millisecond % dishes.length];
    
    return ImageRecognitionResult(
      detectedDish: detectedDish,
      confidence: 0.85 + (DateTime.now().millisecond % 15) / 100,
      suggestedRecipe: recipes.firstWhere(
        (recipe) => recipe.title.toLowerCase().contains(detectedDish.toLowerCase()),
        orElse: () => recipes[0],
      ),
      possibleIngredients: [
        'Tomato',
        'Cheese',
        'Lettuce',
        'Onion',
        'Garlic',
      ],
    );
  }
}