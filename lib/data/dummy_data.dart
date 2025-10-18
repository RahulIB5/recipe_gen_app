import '../models/recipe.dart';
import '../models/user.dart';

// Dummy data for recipes - In a real app, this would come from an API
class DummyData {
  static List<Recipe> get recipes => [
    Recipe(
      id: '1',
      title: 'Spaghetti Carbonara',
      description: 'Classic Italian pasta dish with eggs, cheese, and pancetta',
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=500',
      ingredients: [
        '400g spaghetti',
        '200g pancetta or guanciale',
        '3 large eggs',
        '100g Pecorino Romano cheese',
        '2 cloves garlic',
        'Black pepper',
        'Salt',
      ],
      instructions: [
        'Bring a large pot of salted water to boil and cook spaghetti',
        'Cut pancetta into small cubes and cook until crispy',
        'Beat eggs with grated cheese and black pepper',
        'Drain pasta, reserving pasta water',
        'Mix hot pasta with egg mixture, adding pasta water as needed',
        'Add crispy pancetta and serve immediately',
      ],
      nutritionInfo: NutritionInfo(
        calories: 580,
        protein: 25.0,
        carbs: 65.0,
        fat: 22.0,
        fiber: 3.0,
      ),
      cookingTime: 20,
      difficulty: 'Medium',
      tags: ['Italian', 'Pasta', 'Quick'],
    ),
    Recipe(
      id: '2',
      title: 'Chicken Caesar Salad',
      description:
          'Fresh romaine lettuce with grilled chicken and classic Caesar dressing',
      imageUrl:
          'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500',
      ingredients: [
        '2 chicken breasts',
        '1 head romaine lettuce',
        '1/2 cup Caesar dressing',
        '1/4 cup Parmesan cheese',
        '1 cup croutons',
        '2 tbsp olive oil',
        'Salt and pepper',
      ],
      instructions: [
        'Season chicken with salt and pepper',
        'Heat olive oil in a pan and cook chicken until done',
        'Wash and chop romaine lettuce',
        'Slice cooked chicken',
        'Toss lettuce with Caesar dressing',
        'Top with chicken, Parmesan, and croutons',
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
      description:
          'Simple and nutritious breakfast with creamy avocado on toast',
      imageUrl:
          'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=500',
      ingredients: [
        '2 slices whole grain bread',
        '1 ripe avocado',
        '1 tbsp lemon juice',
        'Salt and pepper',
        'Red pepper flakes',
        '1 tomato (optional)',
        'Olive oil drizzle',
      ],
      instructions: [
        'Toast the bread slices until golden',
        'Mash avocado with lemon juice, salt, and pepper',
        'Spread avocado mixture on toast',
        'Add sliced tomato if desired',
        'Sprinkle with red pepper flakes',
        'Drizzle with olive oil and serve',
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
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500',
      ingredients: [
        '500g beef strips',
        '2 bell peppers',
        '1 onion',
        '2 cloves garlic',
        '2 tbsp soy sauce',
        '1 tbsp oyster sauce',
        '1 tsp sesame oil',
        '2 tbsp vegetable oil',
      ],
      instructions: [
        'Heat vegetable oil in a wok or large pan',
        'Cook beef strips until browned',
        'Remove beef and set aside',
        'Stir-fry vegetables until crisp-tender',
        'Return beef to pan',
        'Add sauces and stir to combine',
        'Serve over rice',
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
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
      ingredients: [
        '1 cup Greek yogurt',
        '1/2 cup mixed berries',
        '1/4 cup granola',
        '1 tbsp honey',
        '1 tbsp chopped nuts',
        'Mint leaves (garnish)',
      ],
      instructions: [
        'Layer yogurt in a glass or bowl',
        'Add a layer of berries',
        'Sprinkle granola over berries',
        'Repeat layers as desired',
        'Drizzle with honey',
        'Top with nuts and mint',
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
    Recipe(
      id: '6',
      title: 'Chicken Tikka Masala',
      description:
          'Creamy Indian curry with tender chicken in spiced tomato sauce',
      imageUrl:
          'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=500',
      ingredients: [
        '500g chicken breast',
        '1 can crushed tomatoes',
        '200ml heavy cream',
        '2 tbsp curry powder',
        '1 tbsp garam masala',
        '3 cloves garlic',
        '1 onion',
        'Basmati rice',
      ],
      instructions: [
        'Cut chicken into bite-sized pieces',
        'Marinate chicken with spices',
        'Cook chicken until golden',
        'Sauté onion and garlic',
        'Add tomatoes and spices',
        'Stir in cream and chicken',
        'Serve over basmati rice',
      ],
      nutritionInfo: NutritionInfo(
        calories: 485,
        protein: 32.0,
        carbs: 28.0,
        fat: 26.0,
        fiber: 4.0,
      ),
      cookingTime: 45,
      difficulty: 'Medium',
      tags: ['Indian', 'Dinner', 'Spicy', 'Comfort Food'],
    ),
    Recipe(
      id: '7',
      title: 'Chocolate Chip Cookies',
      description: 'Classic homemade cookies with gooey chocolate chips',
      imageUrl:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=500',
      ingredients: [
        '2 cups all-purpose flour',
        '1 cup butter',
        '3/4 cup brown sugar',
        '1/2 cup white sugar',
        '2 large eggs',
        '2 cups chocolate chips',
        '1 tsp vanilla extract',
        '1 tsp baking soda',
      ],
      instructions: [
        'Preheat oven to 375°F (190°C)',
        'Cream butter with both sugars',
        'Beat in eggs and vanilla',
        'Mix flour and baking soda separately',
        'Combine wet and dry ingredients',
        'Fold in chocolate chips',
        'Bake 9-11 minutes until golden',
      ],
      nutritionInfo: NutritionInfo(
        calories: 180,
        protein: 2.5,
        carbs: 24.0,
        fat: 9.0,
        fiber: 1.0,
      ),
      cookingTime: 25,
      difficulty: 'Easy',
      tags: ['Dessert', 'Sweet', 'Baking', 'Quick'],
    ),
    Recipe(
      id: '8',
      title: 'Quinoa Buddha Bowl',
      description:
          'Nutritious bowl with quinoa, roasted vegetables, and tahini dressing',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      ingredients: [
        '1 cup quinoa',
        '2 cups mixed vegetables',
        '1 avocado',
        '2 tbsp tahini',
        '1 tbsp lemon juice',
        '1 tbsp olive oil',
        'Pumpkin seeds',
        'Fresh herbs',
      ],
      instructions: [
        'Cook quinoa according to package directions',
        'Roast vegetables with olive oil',
        'Make tahini dressing with lemon',
        'Assemble bowl with quinoa base',
        'Add roasted vegetables and avocado',
        'Drizzle with tahini dressing',
        'Garnish with seeds and herbs',
      ],
      nutritionInfo: NutritionInfo(
        calories: 420,
        protein: 15.0,
        carbs: 52.0,
        fat: 18.0,
        fiber: 12.0,
      ),
      cookingTime: 35,
      difficulty: 'Easy',
      tags: ['Healthy', 'Vegan', 'Lunch', 'Bowl'],
    ),
    Recipe(
      id: '9',
      title: 'Pancakes',
      description: 'Fluffy American-style pancakes perfect for weekend brunch',
      imageUrl:
          'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=500',
      ingredients: [
        '2 cups all-purpose flour',
        '2 tbsp sugar',
        '2 tsp baking powder',
        '1 tsp salt',
        '2 large eggs',
        '1 3/4 cups milk',
        '1/4 cup melted butter',
        'Maple syrup',
      ],
      instructions: [
        'Mix dry ingredients in a bowl',
        'Whisk eggs, milk, and butter',
        'Combine wet and dry ingredients',
        'Heat griddle or pan',
        'Pour batter and cook until bubbles form',
        'Flip and cook until golden',
        'Serve with maple syrup',
      ],
      nutritionInfo: NutritionInfo(
        calories: 320,
        protein: 12.0,
        carbs: 48.0,
        fat: 10.0,
        fiber: 2.0,
      ),
      cookingTime: 20,
      difficulty: 'Easy',
      tags: ['Breakfast', 'Sweet', 'American', 'Weekend'],
    ),
    Recipe(
      id: '10',
      title: 'Thai Green Curry',
      description: 'Aromatic Thai curry with coconut milk and fresh herbs',
      imageUrl:
          'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=500',
      ingredients: [
        '400ml coconut milk',
        '2 tbsp green curry paste',
        '300g chicken thigh',
        '1 eggplant',
        'Thai basil',
        '2 tbsp fish sauce',
        '1 tbsp palm sugar',
        'Jasmine rice',
      ],
      instructions: [
        'Heat thick coconut milk',
        'Fry curry paste until fragrant',
        'Add chicken and cook through',
        'Pour remaining coconut milk',
        'Add vegetables and seasonings',
        'Simmer until tender',
        'Garnish with Thai basil',
      ],
      nutritionInfo: NutritionInfo(
        calories: 445,
        protein: 28.0,
        carbs: 18.0,
        fat: 30.0,
        fiber: 4.0,
      ),
      cookingTime: 30,
      difficulty: 'Medium',
      tags: ['Thai', 'Dinner', 'Spicy', 'Coconut'],
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
    String title =
        'AI Generated Recipe with ${ingredients.take(2).join(' & ')}';

    return Recipe(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description:
          'A delicious recipe created just for you using your available ingredients',
      imageUrl:
          'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=500',
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
        'Serve hot and enjoy your AI-created meal!',
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
        (recipe) =>
            recipe.title.toLowerCase().contains(detectedDish.toLowerCase()),
        orElse: () => recipes[0],
      ),
      possibleIngredients: ['Tomato', 'Cheese', 'Lettuce', 'Onion', 'Garlic'],
    );
  }
}
