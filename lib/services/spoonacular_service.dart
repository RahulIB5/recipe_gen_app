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
    int number = 20,
    int offset = 0,
  }) async {
    if (!isApiKeyConfigured) {
      print('Spoonacular API key not configured, using fallback data');
      return _getFallbackRecipes();
    }

    try {
      final queryParams = <String, String>{
        'apiKey': _apiKey,
        'number': number.toString(),
        'offset': offset.toString(),
        'addRecipeInformation': 'true',
        'fillIngredients': 'true',
        'addRecipeNutrition': 'true',
        'instructionsRequired': 'true',
        'sort': 'popularity',
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

        // Get detailed recipe information with nutrition for each result
        List<Recipe> detailedRecipes = [];
        for (var recipeBasic in results) {
          final detailedRecipe = await getRecipeById(
            recipeBasic['id'].toString(),
          );
          if (detailedRecipe != null) {
            detailedRecipes.add(detailedRecipe);
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

  // Get random recipes
  static Future<List<Recipe>> getRandomRecipes({
    int number = 20,
    String tags = '',
  }) async {
    if (!isApiKeyConfigured) {
      print('Spoonacular API key not configured, using fallback data');
      return _getFallbackRecipes();
    }

    try {
      final queryParams = <String, String>{
        'apiKey': _apiKey,
        'number': number.toString(),
        'include-nutrition': 'true',
        'include-tags': tags.isNotEmpty ? tags : 'vegetarian,healthy,quick',
      };

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
    if (!isApiKeyConfigured) {
      print('Spoonacular API key not configured');
      return null;
    }

    try {
      final uri = Uri.parse('$_baseUrl/recipes/$id/information').replace(
        queryParameters: {
          'apiKey': _apiKey,
          'includeNutrition': 'true',
          'addWinePairing': 'false',
          'addTasteData': 'false',
        },
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
    int number = 20,
    int ranking = 1,
  }) async {
    if (!isApiKeyConfigured) {
      print('Spoonacular API key not configured, using fallback data');
      return _getFallbackRecipes();
    }

    try {
      final queryParams = {
        'apiKey': _apiKey,
        'ingredients': ingredients.join(','),
        'number': number.toString(),
        'ranking': ranking.toString(),
        'ignorePantry': 'true',
        'limitLicense': 'false',
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

  // Fallback recipes when API fails - structured like Spoonacular responses
  static List<Recipe> _getFallbackRecipes() {
    return [
      Recipe(
        id: 'spoon_demo_1',
        title: 'Mediterranean Quinoa Bowl',
        description:
            'A nutritious and colorful quinoa bowl packed with Mediterranean flavors, fresh vegetables, and healthy fats.',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        ingredients: [
          '1 cup quinoa, rinsed',
          '2 cups vegetable broth',
          '1 cucumber, diced',
          '1 cup cherry tomatoes, halved',
          '1/2 red onion, thinly sliced',
          '1/2 cup kalamata olives, pitted',
          '1/2 cup crumbled feta cheese',
          '1/4 cup extra virgin olive oil',
          '2 tablespoons fresh lemon juice',
          '2 cloves garlic, minced',
          '1 teaspoon dried oregano',
          '1/4 cup fresh parsley, chopped',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Rinse quinoa under cold water until water runs clear.',
          'In a medium saucepan, bring vegetable broth to a boil.',
          'Add quinoa, reduce heat to low, cover and simmer for 15 minutes.',
          'Remove from heat and let stand 5 minutes, then fluff with a fork.',
          'In a large bowl, combine cucumber, tomatoes, red onion, and olives.',
          'In a small bowl, whisk together olive oil, lemon juice, garlic, and oregano.',
          'Add cooked quinoa to the vegetable mixture.',
          'Pour dressing over the salad and toss to combine.',
          'Top with crumbled feta cheese and fresh parsley.',
          'Season with salt and pepper to taste before serving.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 385,
          protein: 12.5,
          carbs: 48.2,
          fat: 16.8,
          fiber: 6.2,
        ),
        cookingTime: 25,
        difficulty: 'Easy',
        tags: [
          'Mediterranean',
          'Vegetarian',
          'Healthy',
          'Gluten-Free',
          'High-Fiber',
        ],
      ),
      Recipe(
        id: 'spoon_demo_2',
        title: 'Honey Garlic Salmon with Broccoli',
        description:
            'Tender salmon glazed with honey garlic sauce, served with steamed broccoli. High in protein and omega-3 fatty acids.',
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400',
        ingredients: [
          '4 salmon fillets (6 oz each)',
          '3 tablespoons honey',
          '3 cloves garlic, minced',
          '2 tablespoons soy sauce',
          '1 tablespoon olive oil',
          '1 tablespoon fresh ginger, grated',
          '1 tablespoon rice vinegar',
          '4 cups fresh broccoli florets',
          '1 tablespoon sesame seeds',
          '2 green onions, sliced',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Preheat oven to 400°F (200°C).',
          'In a small bowl, whisk together honey, garlic, soy sauce, ginger, and rice vinegar.',
          'Season salmon fillets with salt and pepper.',
          'Heat olive oil in an oven-safe skillet over medium-high heat.',
          'Sear salmon fillets for 2-3 minutes per side.',
          'Brush salmon with honey garlic glaze.',
          'Transfer skillet to oven and bake for 8-10 minutes.',
          'Meanwhile, steam broccoli for 4-5 minutes until tender-crisp.',
          'Remove salmon from oven and brush with remaining glaze.',
          'Serve salmon over steamed broccoli, garnished with sesame seeds and green onions.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 35.8,
          carbs: 24.1,
          fat: 22.3,
          fiber: 4.1,
        ),
        cookingTime: 20,
        difficulty: 'Medium',
        tags: ['High-Protein', 'Omega-3', 'Low-Carb', 'Healthy', 'Quick'],
      ),
      Recipe(
        id: 'spoon_demo_3',
        title: 'Chickpea and Spinach Curry',
        description:
            'A flavorful and nutritious plant-based curry with chickpeas, spinach, and aromatic spices. Rich in protein and iron.',
        imageUrl:
            'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
        ingredients: [
          '2 cans (15 oz each) chickpeas, drained and rinsed',
          '4 cups fresh spinach, chopped',
          '1 large onion, diced',
          '3 cloves garlic, minced',
          '1 tablespoon fresh ginger, grated',
          '1 can (14 oz) coconut milk',
          '1 can (14 oz) diced tomatoes',
          '2 tablespoons coconut oil',
          '2 teaspoons curry powder',
          '1 teaspoon ground cumin',
          '1 teaspoon turmeric',
          '1/2 teaspoon cayenne pepper',
          '1 teaspoon salt',
          '2 tablespoons fresh cilantro, chopped',
          'Cooked basmati rice for serving',
        ],
        instructions: [
          'Heat coconut oil in a large pot over medium heat.',
          'Add diced onion and cook until softened, about 5 minutes.',
          'Add garlic and ginger, cook for another minute.',
          'Stir in curry powder, cumin, turmeric, and cayenne, cook for 30 seconds.',
          'Add diced tomatoes and cook for 5 minutes.',
          'Pour in coconut milk and bring to a simmer.',
          'Add chickpeas and salt, simmer for 15 minutes.',
          'Stir in chopped spinach and cook until wilted, about 2 minutes.',
          'Taste and adjust seasoning as needed.',
          'Serve over basmati rice, garnished with fresh cilantro.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 315,
          protein: 14.2,
          carbs: 35.6,
          fat: 14.8,
          fiber: 9.4,
        ),
        cookingTime: 35,
        difficulty: 'Easy',
        tags: ['Vegan', 'High-Fiber', 'Plant-Based', 'Indian', 'Dairy-Free'],
      ),
      Recipe(
        id: 'spoon_demo_4',
        title: 'Classic Margherita Pizza',
        description:
            'Authentic Italian pizza with fresh mozzarella, basil, and San Marzano tomatoes on a crispy homemade crust.',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
        ingredients: [
          '1 pizza dough (store-bought or homemade)',
          '1/2 cup pizza sauce',
          '8 oz fresh mozzarella, sliced',
          '1/4 cup fresh basil leaves',
          '2 tablespoons olive oil',
          '1 clove garlic, minced',
          '1/4 teaspoon salt',
          '1/4 teaspoon black pepper',
          'Parmesan cheese for serving',
        ],
        instructions: [
          'Preheat oven to 475°F (245°C).',
          'Roll out pizza dough on a floured surface.',
          'Transfer to a pizza stone or baking sheet.',
          'Brush dough with olive oil and minced garlic.',
          'Spread pizza sauce evenly over the dough.',
          'Arrange mozzarella slices on top.',
          'Season with salt and pepper.',
          'Bake for 12-15 minutes until crust is golden.',
          'Top with fresh basil leaves and serve with Parmesan.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 285,
          protein: 14.8,
          carbs: 35.2,
          fat: 10.6,
          fiber: 2.1,
        ),
        cookingTime: 25,
        difficulty: 'Medium',
        tags: ['Italian', 'Vegetarian', 'Classic', 'Pizza'],
      ),
      Recipe(
        id: 'spoon_demo_5',
        title: 'Thai Green Curry Chicken',
        description:
            'Aromatic and creamy Thai green curry with tender chicken, vegetables, and fragrant herbs.',
        imageUrl:
            'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400',
        ingredients: [
          '1 lb chicken thighs, cut into bite-sized pieces',
          '1 can (14 oz) coconut milk',
          '2 tablespoons green curry paste',
          '1 bell pepper, sliced',
          '1 zucchini, sliced',
          '1/2 cup bamboo shoots',
          '2 tablespoons fish sauce',
          '1 tablespoon brown sugar',
          '2 Thai basil leaves',
          '1 lime, juiced',
          '1 tablespoon vegetable oil',
        ],
        instructions: [
          'Heat oil in a large pan over medium-high heat.',
          'Add green curry paste and fry for 1 minute.',
          'Add thick part of coconut milk and simmer until oil separates.',
          'Add chicken and cook until no longer pink.',
          'Add remaining coconut milk, fish sauce, and brown sugar.',
          'Add vegetables and simmer for 10 minutes.',
          'Stir in Thai basil and lime juice.',
          'Serve over jasmine rice.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 380,
          protein: 28.5,
          carbs: 12.8,
          fat: 25.2,
          fiber: 3.1,
        ),
        cookingTime: 30,
        difficulty: 'Medium',
        tags: ['Thai', 'Spicy', 'Asian', 'High-Protein'],
      ),
      Recipe(
        id: 'spoon_demo_6',
        title: 'Avocado Toast with Poached Egg',
        description:
            'Perfect breakfast or brunch with creamy avocado, perfectly poached egg, and everything bagel seasoning.',
        imageUrl:
            'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400',
        ingredients: [
          '2 slices whole grain bread',
          '1 ripe avocado',
          '2 eggs',
          '1 tablespoon white vinegar',
          '1 tablespoon lemon juice',
          '1 teaspoon everything bagel seasoning',
          '1/4 teaspoon red pepper flakes',
          'Salt and pepper to taste',
          'Microgreens for garnish',
        ],
        instructions: [
          'Toast bread slices until golden brown.',
          'Bring water to gentle simmer in a saucepan, add vinegar.',
          'Crack eggs into small bowls.',
          'Create whirlpool in water and gently drop in eggs.',
          'Poach eggs for 3-4 minutes for runny yolks.',
          'Mash avocado with lemon juice, salt, and pepper.',
          'Spread avocado mixture on toast.',
          'Top with poached eggs and seasonings.',
          'Garnish with microgreens and serve immediately.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 320,
          protein: 16.2,
          carbs: 28.4,
          fat: 18.6,
          fiber: 8.2,
        ),
        cookingTime: 15,
        difficulty: 'Easy',
        tags: ['Breakfast', 'Healthy', 'High-Fiber', 'Vegetarian'],
      ),
      Recipe(
        id: 'spoon_demo_7',
        title: 'Beef Stir Fry with Vegetables',
        description:
            'Quick and flavorful beef stir fry with crisp vegetables in a savory sauce.',
        imageUrl:
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
        ingredients: [
          '1 lb beef sirloin, sliced thin',
          '2 cups mixed vegetables (broccoli, carrots, snap peas)',
          '2 tablespoons soy sauce',
          '1 tablespoon oyster sauce',
          '1 teaspoon sesame oil',
          '2 cloves garlic, minced',
          '1 tablespoon fresh ginger, grated',
          '2 tablespoons vegetable oil',
          '1 teaspoon cornstarch',
          '2 green onions, sliced',
        ],
        instructions: [
          'Marinate beef with soy sauce and cornstarch for 15 minutes.',
          'Heat wok or large skillet over high heat.',
          'Add 1 tablespoon oil and stir-fry beef until browned.',
          'Remove beef and set aside.',
          'Add remaining oil and stir-fry vegetables until crisp-tender.',
          'Add garlic and ginger, stir for 30 seconds.',
          'Return beef to pan with oyster sauce and sesame oil.',
          'Toss everything together and garnish with green onions.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 285,
          protein: 26.8,
          carbs: 8.4,
          fat: 16.2,
          fiber: 2.8,
        ),
        cookingTime: 20,
        difficulty: 'Medium',
        tags: ['Asian', 'High-Protein', 'Quick', 'Low-Carb'],
      ),
      Recipe(
        id: 'spoon_demo_8',
        title: 'Caprese Salad',
        description:
            'Classic Italian salad with fresh mozzarella, ripe tomatoes, and basil drizzled with balsamic glaze.',
        imageUrl:
            'https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?w=400',
        ingredients: [
          '3 large ripe tomatoes, sliced',
          '8 oz fresh mozzarella, sliced',
          '1/2 cup fresh basil leaves',
          '1/4 cup extra virgin olive oil',
          '2 tablespoons balsamic glaze',
          '1/2 teaspoon sea salt',
          '1/4 teaspoon black pepper',
        ],
        instructions: [
          'Arrange tomato and mozzarella slices alternately on a platter.',
          'Tuck fresh basil leaves between the slices.',
          'Drizzle with extra virgin olive oil.',
          'Season with sea salt and black pepper.',
          'Drizzle with balsamic glaze just before serving.',
          'Serve at room temperature for best flavor.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 195,
          protein: 11.2,
          carbs: 8.6,
          fat: 14.8,
          fiber: 1.4,
        ),
        cookingTime: 10,
        difficulty: 'Easy',
        tags: ['Italian', 'Vegetarian', 'Fresh', 'No-Cook'],
      ),
      Recipe(
        id: 'spoon_demo_9',
        title: 'Chocolate Chip Cookies',
        description:
            'Classic homemade chocolate chip cookies that are crispy on the outside and chewy on the inside.',
        imageUrl:
            'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400',
        ingredients: [
          '2 1/4 cups all-purpose flour',
          '1 tsp baking soda',
          '1 tsp salt',
          '1 cup butter, softened',
          '3/4 cup granulated sugar',
          '3/4 cup brown sugar, packed',
          '2 large eggs',
          '2 tsp vanilla extract',
          '2 cups chocolate chips',
        ],
        instructions: [
          'Preheat oven to 375°F (190°C).',
          'Mix flour, baking soda, and salt in a bowl.',
          'Cream butter and both sugars until fluffy.',
          'Beat in eggs and vanilla.',
          'Gradually blend in flour mixture.',
          'Stir in chocolate chips.',
          'Drop rounded tablespoons onto ungreased baking sheets.',
          'Bake 9-11 minutes until golden brown.',
          'Cool on baking sheet for 2 minutes before removing.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 142,
          protein: 2.1,
          carbs: 20.8,
          fat: 6.4,
          fiber: 0.8,
        ),
        cookingTime: 25,
        difficulty: 'Easy',
        tags: ['Dessert', 'Baking', 'Classic', 'Sweet'],
      ),
      Recipe(
        id: 'spoon_demo_10',
        title: 'Greek Lemon Chicken',
        description:
            'Tender chicken marinated in olive oil, lemon, and Mediterranean herbs, roasted to perfection.',
        imageUrl:
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
        ingredients: [
          '4 chicken breasts',
          '1/3 cup olive oil',
          '1/4 cup fresh lemon juice',
          '3 cloves garlic, minced',
          '1 tsp dried oregano',
          '1/2 tsp dried thyme',
          '1/2 tsp salt',
          '1/4 tsp black pepper',
          '1 lemon, sliced',
          'Fresh herbs for garnish',
        ],
        instructions: [
          'Marinate chicken in olive oil, lemon juice, garlic, and herbs for 2 hours.',
          'Preheat oven to 400°F (200°C).',
          'Place chicken in baking dish with marinade.',
          'Top with lemon slices.',
          'Roast for 25-30 minutes until internal temperature reaches 165°F.',
          'Let rest 5 minutes before serving.',
          'Garnish with fresh herbs.',
        ],
        nutritionInfo: NutritionInfo(
          calories: 245,
          protein: 31.8,
          carbs: 3.2,
          fat: 11.4,
          fiber: 0.4,
        ),
        cookingTime: 40,
        difficulty: 'Easy',
        tags: ['Greek', 'Mediterranean', 'High-Protein', 'Gluten-Free'],
      ),
      // Adding 40+ more recipes for carousel
      Recipe(
        id: 'demo_11',
        title: 'Thai Green Curry',
        description:
            'Authentic Thai green curry with coconut milk, vegetables, and aromatic spices.',
        imageUrl:
            'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400',
        ingredients: [
          'Green curry paste',
          'Coconut milk',
          'Thai basil',
          'Eggplant',
          'Chicken',
        ],
        instructions: [
          'Heat curry paste',
          'Add coconut milk',
          'Add vegetables',
          'Simmer until done',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 28.0,
          carbs: 15.0,
          fat: 32.0,
          fiber: 4.0,
        ),
        cookingTime: 25,
        difficulty: 'Medium',
        tags: ['Thai', 'Spicy', 'Coconut'],
      ),
      Recipe(
        id: 'demo_12',
        title: 'Mushroom Risotto',
        description:
            'Creamy Italian risotto with mixed mushrooms and Parmesan cheese.',
        imageUrl:
            'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=400',
        ingredients: [
          'Arborio rice',
          'Mixed mushrooms',
          'White wine',
          'Parmesan',
          'Vegetable broth',
        ],
        instructions: [
          'Sauté mushrooms',
          'Add rice',
          'Add wine',
          'Gradually add broth',
          'Stir in cheese',
        ],
        nutritionInfo: NutritionInfo(
          calories: 380,
          protein: 12.0,
          carbs: 58.0,
          fat: 14.0,
          fiber: 3.0,
        ),
        cookingTime: 35,
        difficulty: 'Hard',
        tags: ['Italian', 'Vegetarian', 'Creamy'],
      ),
      Recipe(
        id: 'demo_13',
        title: 'BBQ Pulled Pork',
        description:
            'Slow-cooked pork shoulder in tangy BBQ sauce, perfect for sandwiches.',
        imageUrl:
            'https://images.unsplash.com/photo-1558030006-450675393462?w=400',
        ingredients: [
          'Pork shoulder',
          'BBQ sauce',
          'Brown sugar',
          'Paprika',
          'Onion powder',
        ],
        instructions: [
          'Season pork',
          'Slow cook 8 hours',
          'Shred meat',
          'Mix with BBQ sauce',
        ],
        nutritionInfo: NutritionInfo(
          calories: 520,
          protein: 45.0,
          carbs: 8.0,
          fat: 32.0,
          fiber: 0.5,
        ),
        cookingTime: 480,
        difficulty: 'Easy',
        tags: ['American', 'BBQ', 'Slow-cooked'],
      ),
      Recipe(
        id: 'demo_14',
        title: 'Caprese Salad',
        description:
            'Fresh mozzarella, tomatoes, and basil drizzled with balsamic glaze.',
        imageUrl:
            'https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?w=400',
        ingredients: [
          'Fresh mozzarella',
          'Tomatoes',
          'Fresh basil',
          'Balsamic glaze',
          'Olive oil',
        ],
        instructions: [
          'Slice mozzarella and tomatoes',
          'Arrange on plate',
          'Add basil',
          'Drizzle with balsamic',
        ],
        nutritionInfo: NutritionInfo(
          calories: 280,
          protein: 18.0,
          carbs: 8.0,
          fat: 20.0,
          fiber: 2.0,
        ),
        cookingTime: 10,
        difficulty: 'Easy',
        tags: ['Italian', 'Fresh', 'Vegetarian'],
      ),
      Recipe(
        id: 'demo_15',
        title: 'Beef Tacos',
        description:
            'Seasoned ground beef in corn tortillas with fresh toppings.',
        imageUrl:
            'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400',
        ingredients: [
          'Ground beef',
          'Corn tortillas',
          'Lettuce',
          'Cheese',
          'Salsa',
        ],
        instructions: [
          'Cook beef with spices',
          'Warm tortillas',
          'Fill with beef',
          'Add toppings',
        ],
        nutritionInfo: NutritionInfo(
          calories: 340,
          protein: 22.0,
          carbs: 18.0,
          fat: 20.0,
          fiber: 3.0,
        ),
        cookingTime: 15,
        difficulty: 'Easy',
        tags: ['Mexican', 'Quick', 'Spicy'],
      ),
      Recipe(
        id: 'demo_16',
        title: 'Chocolate Chip Cookies',
        description:
            'Classic homemade chocolate chip cookies with a chewy texture.',
        imageUrl:
            'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400',
        ingredients: [
          'Flour',
          'Butter',
          'Brown sugar',
          'Chocolate chips',
          'Vanilla',
        ],
        instructions: [
          'Cream butter and sugar',
          'Add dry ingredients',
          'Fold in chips',
          'Bake 12 minutes',
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
        tags: ['Dessert', 'Baking', 'Sweet'],
      ),
      Recipe(
        id: 'demo_17',
        title: 'Vegetable Stir Fry',
        description:
            'Quick and healthy mixed vegetable stir fry with soy-ginger sauce.',
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
        ingredients: [
          'Mixed vegetables',
          'Soy sauce',
          'Ginger',
          'Garlic',
          'Sesame oil',
        ],
        instructions: [
          'Heat oil in wok',
          'Add vegetables',
          'Stir fry 5 minutes',
          'Add sauce',
        ],
        nutritionInfo: NutritionInfo(
          calories: 120,
          protein: 4.0,
          carbs: 18.0,
          fat: 5.0,
          fiber: 6.0,
        ),
        cookingTime: 12,
        difficulty: 'Easy',
        tags: ['Asian', 'Vegetarian', 'Quick'],
      ),
      Recipe(
        id: 'demo_18',
        title: 'French Onion Soup',
        description:
            'Rich and savory soup with caramelized onions and melted Gruyère cheese.',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
        ingredients: [
          'Yellow onions',
          'Beef broth',
          'White wine',
          'Gruyère cheese',
          'French bread',
        ],
        instructions: [
          'Caramelize onions',
          'Add broth and wine',
          'Simmer 30 minutes',
          'Top with cheese and bread',
        ],
        nutritionInfo: NutritionInfo(
          calories: 320,
          protein: 16.0,
          carbs: 28.0,
          fat: 16.0,
          fiber: 3.0,
        ),
        cookingTime: 60,
        difficulty: 'Medium',
        tags: ['French', 'Soup', 'Comfort Food'],
      ),
      Recipe(
        id: 'demo_19',
        title: 'Lemon Herb Roasted Chicken',
        description:
            'Whole roasted chicken with fresh herbs and lemon for a perfect dinner.',
        imageUrl:
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
        ingredients: [
          'Whole chicken',
          'Lemon',
          'Rosemary',
          'Thyme',
          'Olive oil',
        ],
        instructions: [
          'Season chicken',
          'Stuff with lemon and herbs',
          'Roast at 375°F',
          'Rest before carving',
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 52.0,
          carbs: 2.0,
          fat: 24.0,
          fiber: 0.0,
        ),
        cookingTime: 90,
        difficulty: 'Medium',
        tags: ['Roasted', 'Herb', 'Classic'],
      ),
      Recipe(
        id: 'demo_20',
        title: 'Avocado Toast',
        description:
            'Simple and nutritious avocado toast with various toppings.',
        imageUrl:
            'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400',
        ingredients: [
          'Avocado',
          'Sourdough bread',
          'Lime',
          'Salt',
          'Red pepper flakes',
        ],
        instructions: [
          'Toast bread',
          'Mash avocado',
          'Spread on toast',
          'Season and garnish',
        ],
        nutritionInfo: NutritionInfo(
          calories: 240,
          protein: 6.0,
          carbs: 20.0,
          fat: 16.0,
          fiber: 8.0,
        ),
        cookingTime: 5,
        difficulty: 'Easy',
        tags: ['Breakfast', 'Healthy', 'Quick'],
      ),
      Recipe(
        id: 'demo_21',
        title: 'Shrimp Scampi',
        description: 'Garlic butter shrimp served over linguine pasta.',
        imageUrl:
            'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=400',
        ingredients: ['Shrimp', 'Linguine', 'Garlic', 'White wine', 'Butter'],
        instructions: [
          'Cook pasta',
          'Sauté garlic',
          'Add shrimp',
          'Toss with pasta',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 28.0,
          carbs: 45.0,
          fat: 14.0,
          fiber: 2.0,
        ),
        cookingTime: 20,
        difficulty: 'Medium',
        tags: ['Seafood', 'Italian', 'Pasta'],
      ),
      Recipe(
        id: 'demo_22',
        title: 'Greek Salad',
        description: 'Traditional Greek salad with feta cheese and olives.',
        imageUrl:
            'https://images.unsplash.com/photo-1544048404-ec68744de702?w=400',
        ingredients: [
          'Tomatoes',
          'Cucumber',
          'Red onion',
          'Feta cheese',
          'Kalamata olives',
        ],
        instructions: [
          'Chop vegetables',
          'Arrange in bowl',
          'Add cheese and olives',
          'Dress with olive oil',
        ],
        nutritionInfo: NutritionInfo(
          calories: 200,
          protein: 8.0,
          carbs: 12.0,
          fat: 14.0,
          fiber: 4.0,
        ),
        cookingTime: 10,
        difficulty: 'Easy',
        tags: ['Greek', 'Salad', 'Fresh'],
      ),
      Recipe(
        id: 'demo_23',
        title: 'Banana Pancakes',
        description:
            'Fluffy pancakes with mashed banana for natural sweetness.',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
        ingredients: ['Flour', 'Banana', 'Milk', 'Eggs', 'Baking powder'],
        instructions: [
          'Mash bananas',
          'Mix wet ingredients',
          'Combine with flour',
          'Cook on griddle',
        ],
        nutritionInfo: NutritionInfo(
          calories: 280,
          protein: 8.0,
          carbs: 45.0,
          fat: 8.0,
          fiber: 3.0,
        ),
        cookingTime: 15,
        difficulty: 'Easy',
        tags: ['Breakfast', 'Sweet', 'Fruit'],
      ),
      Recipe(
        id: 'demo_24',
        title: 'Chicken Caesar Salad',
        description:
            'Crisp romaine lettuce with grilled chicken and Caesar dressing.',
        imageUrl:
            'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
        ingredients: [
          'Romaine lettuce',
          'Grilled chicken',
          'Parmesan',
          'Croutons',
          'Caesar dressing',
        ],
        instructions: [
          'Grill chicken',
          'Chop lettuce',
          'Toss with dressing',
          'Top with chicken and cheese',
        ],
        nutritionInfo: NutritionInfo(
          calories: 380,
          protein: 32.0,
          carbs: 8.0,
          fat: 24.0,
          fiber: 3.0,
        ),
        cookingTime: 20,
        difficulty: 'Easy',
        tags: ['Salad', 'Protein', 'Classic'],
      ),
      Recipe(
        id: 'demo_25',
        title: 'Beef Stir Fry',
        description: 'Tender beef strips with vegetables in savory sauce.',
        imageUrl:
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
        ingredients: [
          'Beef strips',
          'Bell peppers',
          'Broccoli',
          'Soy sauce',
          'Cornstarch',
        ],
        instructions: [
          'Marinate beef',
          'Stir fry vegetables',
          'Add beef',
          'Toss with sauce',
        ],
        nutritionInfo: NutritionInfo(
          calories: 340,
          protein: 28.0,
          carbs: 12.0,
          fat: 20.0,
          fiber: 3.0,
        ),
        cookingTime: 18,
        difficulty: 'Medium',
        tags: ['Asian', 'Protein', 'Quick'],
      ),
      Recipe(
        id: 'demo_26',
        title: 'Margherita Pizza',
        description:
            'Classic Italian pizza with tomato sauce, mozzarella, and fresh basil.',
        imageUrl:
            'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
        ingredients: [
          'Pizza dough',
          'Tomato sauce',
          'Mozzarella',
          'Fresh basil',
          'Olive oil',
        ],
        instructions: [
          'Roll out dough',
          'Spread sauce',
          'Add cheese',
          'Bake until golden',
        ],
        nutritionInfo: NutritionInfo(
          calories: 320,
          protein: 14.0,
          carbs: 42.0,
          fat: 12.0,
          fiber: 2.0,
        ),
        cookingTime: 25,
        difficulty: 'Medium',
        tags: ['Italian', 'Pizza', 'Classic'],
      ),
      Recipe(
        id: 'demo_27',
        title: 'Fish and Chips',
        description: 'Beer-battered fish with crispy chips and mushy peas.',
        imageUrl:
            'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=400',
        ingredients: [
          'White fish',
          'Potatoes',
          'Beer batter',
          'Peas',
          'Vinegar',
        ],
        instructions: [
          'Cut and fry chips',
          'Batter fish',
          'Deep fry fish',
          'Serve with peas',
        ],
        nutritionInfo: NutritionInfo(
          calories: 580,
          protein: 35.0,
          carbs: 52.0,
          fat: 28.0,
          fiber: 4.0,
        ),
        cookingTime: 35,
        difficulty: 'Hard',
        tags: ['British', 'Fried', 'Comfort Food'],
      ),
      Recipe(
        id: 'demo_28',
        title: 'Chocolate Brownies',
        description: 'Rich and fudgy chocolate brownies with a crispy top.',
        imageUrl:
            'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
        ingredients: ['Dark chocolate', 'Butter', 'Sugar', 'Eggs', 'Flour'],
        instructions: [
          'Melt chocolate and butter',
          'Beat in eggs and sugar',
          'Fold in flour',
          'Bake until set',
        ],
        nutritionInfo: NutritionInfo(
          calories: 250,
          protein: 4.0,
          carbs: 32.0,
          fat: 14.0,
          fiber: 2.0,
        ),
        cookingTime: 35,
        difficulty: 'Medium',
        tags: ['Dessert', 'Chocolate', 'Baking'],
      ),
      Recipe(
        id: 'demo_29',
        title: 'Chicken Tikka Masala',
        description:
            'Creamy Indian curry with tender chicken in spiced tomato sauce.',
        imageUrl:
            'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
        ingredients: ['Chicken', 'Yogurt', 'Tomatoes', 'Cream', 'Garam masala'],
        instructions: [
          'Marinate chicken',
          'Grill chicken',
          'Make sauce',
          'Combine and simmer',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 35.0,
          carbs: 12.0,
          fat: 26.0,
          fiber: 2.0,
        ),
        cookingTime: 45,
        difficulty: 'Hard',
        tags: ['Indian', 'Curry', 'Spicy'],
      ),
      Recipe(
        id: 'demo_30',
        title: 'Apple Pie',
        description:
            'Classic American apple pie with flaky crust and cinnamon filling.',
        imageUrl:
            'https://images.unsplash.com/photo-1621743478914-cc8a86d7e9b5?w=400',
        ingredients: ['Apples', 'Pie crust', 'Sugar', 'Cinnamon', 'Butter'],
        instructions: [
          'Prepare crust',
          'Slice apples',
          'Mix with spices',
          'Assemble and bake',
        ],
        nutritionInfo: NutritionInfo(
          calories: 320,
          protein: 3.0,
          carbs: 52.0,
          fat: 12.0,
          fiber: 4.0,
        ),
        cookingTime: 75,
        difficulty: 'Hard',
        tags: ['Dessert', 'American', 'Fruit'],
      ),
      Recipe(
        id: 'demo_31',
        title: 'Pad Thai',
        description:
            'Traditional Thai stir-fried noodles with shrimp and peanuts.',
        imageUrl:
            'https://images.unsplash.com/photo-1559314809-0f31657def5e?w=400',
        ingredients: [
          'Rice noodles',
          'Shrimp',
          'Bean sprouts',
          'Peanuts',
          'Tamarind',
        ],
        instructions: [
          'Soak noodles',
          'Stir fry shrimp',
          'Add noodles and sauce',
          'Garnish with peanuts',
        ],
        nutritionInfo: NutritionInfo(
          calories: 450,
          protein: 22.0,
          carbs: 65.0,
          fat: 14.0,
          fiber: 3.0,
        ),
        cookingTime: 25,
        difficulty: 'Medium',
        tags: ['Thai', 'Noodles', 'Seafood'],
      ),
      Recipe(
        id: 'demo_32',
        title: 'Meatball Subs',
        description:
            'Italian meatballs in marinara sauce served in crusty rolls.',
        imageUrl:
            'https://images.unsplash.com/photo-1619158072944-8fc6cdaec1a2?w=400',
        ingredients: [
          'Ground beef',
          'Bread crumbs',
          'Marinara sauce',
          'Sub rolls',
          'Mozzarella',
        ],
        instructions: [
          'Form meatballs',
          'Brown in pan',
          'Simmer in sauce',
          'Serve in rolls with cheese',
        ],
        nutritionInfo: NutritionInfo(
          calories: 520,
          protein: 32.0,
          carbs: 42.0,
          fat: 24.0,
          fiber: 3.0,
        ),
        cookingTime: 30,
        difficulty: 'Medium',
        tags: ['Italian', 'Sandwich', 'Comfort Food'],
      ),
      Recipe(
        id: 'demo_33',
        title: 'Vegetable Curry',
        description:
            'Hearty mixed vegetable curry with coconut milk and spices.',
        imageUrl:
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',
        ingredients: [
          'Mixed vegetables',
          'Coconut milk',
          'Curry powder',
          'Onions',
          'Garlic',
        ],
        instructions: [
          'Sauté onions and garlic',
          'Add vegetables',
          'Pour in coconut milk',
          'Simmer until tender',
        ],
        nutritionInfo: NutritionInfo(
          calories: 280,
          protein: 8.0,
          carbs: 22.0,
          fat: 18.0,
          fiber: 8.0,
        ),
        cookingTime: 25,
        difficulty: 'Easy',
        tags: ['Vegetarian', 'Curry', 'Healthy'],
      ),
      Recipe(
        id: 'demo_34',
        title: 'Grilled Cheese Sandwich',
        description:
            'Classic comfort food with melted cheese between crispy bread.',
        imageUrl:
            'https://images.unsplash.com/photo-1528736235302-52922df5c122?w=400',
        ingredients: ['Bread', 'Cheese', 'Butter', 'Salt', 'Pepper'],
        instructions: [
          'Butter bread',
          'Add cheese',
          'Grill until golden',
          'Flip and repeat',
        ],
        nutritionInfo: NutritionInfo(
          calories: 380,
          protein: 16.0,
          carbs: 28.0,
          fat: 24.0,
          fiber: 2.0,
        ),
        cookingTime: 8,
        difficulty: 'Easy',
        tags: ['Comfort Food', 'Quick', 'Classic'],
      ),
      Recipe(
        id: 'demo_35',
        title: 'Stuffed Bell Peppers',
        description:
            'Bell peppers stuffed with rice, ground meat, and vegetables.',
        imageUrl:
            'https://images.unsplash.com/photo-1606490598040-cbd9e8a1c1b3?w=400',
        ingredients: [
          'Bell peppers',
          'Ground beef',
          'Rice',
          'Onions',
          'Tomatoes',
        ],
        instructions: [
          'Hollow out peppers',
          'Cook filling',
          'Stuff peppers',
          'Bake until tender',
        ],
        nutritionInfo: NutritionInfo(
          calories: 320,
          protein: 22.0,
          carbs: 28.0,
          fat: 14.0,
          fiber: 4.0,
        ),
        cookingTime: 45,
        difficulty: 'Medium',
        tags: ['Stuffed', 'Healthy', 'Complete Meal'],
      ),
      Recipe(
        id: 'demo_36',
        title: 'Clam Chowder',
        description:
            'Creamy New England clam chowder with potatoes and celery.',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
        ingredients: ['Clams', 'Potatoes', 'Celery', 'Onions', 'Heavy cream'],
        instructions: [
          'Sauté vegetables',
          'Add potatoes and broth',
          'Stir in clams',
          'Finish with cream',
        ],
        nutritionInfo: NutritionInfo(
          calories: 380,
          protein: 18.0,
          carbs: 24.0,
          fat: 24.0,
          fiber: 2.0,
        ),
        cookingTime: 40,
        difficulty: 'Medium',
        tags: ['Soup', 'Seafood', 'Creamy'],
      ),
      Recipe(
        id: 'demo_37',
        title: 'Chicken Parmesan',
        description:
            'Breaded chicken cutlets topped with marinara and mozzarella.',
        imageUrl:
            'https://images.unsplash.com/photo-1632778149955-e80f8ceca2e8?w=400',
        ingredients: [
          'Chicken breast',
          'Bread crumbs',
          'Marinara sauce',
          'Mozzarella',
          'Parmesan',
        ],
        instructions: [
          'Bread chicken',
          'Pan fry until golden',
          'Top with sauce and cheese',
          'Bake until melted',
        ],
        nutritionInfo: NutritionInfo(
          calories: 480,
          protein: 42.0,
          carbs: 18.0,
          fat: 26.0,
          fiber: 2.0,
        ),
        cookingTime: 35,
        difficulty: 'Medium',
        tags: ['Italian', 'Breaded', 'Cheese'],
      ),
      Recipe(
        id: 'demo_38',
        title: 'Smoothie Bowl',
        description:
            'Thick fruit smoothie topped with granola, berries, and coconut.',
        imageUrl:
            'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400',
        ingredients: [
          'Frozen berries',
          'Banana',
          'Granola',
          'Coconut flakes',
          'Chia seeds',
        ],
        instructions: [
          'Blend frozen fruit',
          'Pour into bowl',
          'Add toppings',
          'Serve immediately',
        ],
        nutritionInfo: NutritionInfo(
          calories: 320,
          protein: 8.0,
          carbs: 58.0,
          fat: 10.0,
          fiber: 12.0,
        ),
        cookingTime: 5,
        difficulty: 'Easy',
        tags: ['Breakfast', 'Healthy', 'Fruit'],
      ),
      Recipe(
        id: 'demo_39',
        title: 'Beef Stroganoff',
        description:
            'Tender beef in creamy mushroom sauce served over egg noodles.',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
        ingredients: [
          'Beef strips',
          'Mushrooms',
          'Sour cream',
          'Egg noodles',
          'Beef broth',
        ],
        instructions: [
          'Brown beef',
          'Sauté mushrooms',
          'Make sauce',
          'Combine and serve over noodles',
        ],
        nutritionInfo: NutritionInfo(
          calories: 520,
          protein: 32.0,
          carbs: 42.0,
          fat: 24.0,
          fiber: 3.0,
        ),
        cookingTime: 30,
        difficulty: 'Medium',
        tags: ['Russian', 'Creamy', 'Comfort Food'],
      ),
      Recipe(
        id: 'demo_40',
        title: 'Ratatouille',
        description:
            'Traditional French vegetable stew with eggplant, zucchini, and tomatoes.',
        imageUrl:
            'https://images.unsplash.com/photo-1572441713132-51c75654db73?w=400',
        ingredients: [
          'Eggplant',
          'Zucchini',
          'Tomatoes',
          'Bell peppers',
          'Herbs de Provence',
        ],
        instructions: [
          'Slice vegetables',
          'Layer in dish',
          'Season with herbs',
          'Bake until tender',
        ],
        nutritionInfo: NutritionInfo(
          calories: 180,
          protein: 4.0,
          carbs: 22.0,
          fat: 8.0,
          fiber: 8.0,
        ),
        cookingTime: 60,
        difficulty: 'Medium',
        tags: ['French', 'Vegetarian', 'Rustic'],
      ),
      Recipe(
        id: 'demo_41',
        title: 'Korean Bibimbap',
        description:
            'Mixed rice bowl with vegetables, meat, and spicy gochujang sauce.',
        imageUrl:
            'https://images.unsplash.com/photo-1553163147-622ab57be1c7?w=400',
        ingredients: [
          'Rice',
          'Mixed vegetables',
          'Beef bulgogi',
          'Fried egg',
          'Gochujang',
        ],
        instructions: [
          'Prepare vegetables',
          'Cook rice',
          'Arrange in bowl',
          'Top with egg and sauce',
        ],
        nutritionInfo: NutritionInfo(
          calories: 460,
          protein: 24.0,
          carbs: 58.0,
          fat: 16.0,
          fiber: 6.0,
        ),
        cookingTime: 30,
        difficulty: 'Medium',
        tags: ['Korean', 'Rice Bowl', 'Spicy'],
      ),
      Recipe(
        id: 'demo_42',
        title: 'Lobster Bisque',
        description: 'Rich and creamy lobster soup with brandy and herbs.',
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
        ingredients: [
          'Lobster',
          'Heavy cream',
          'Brandy',
          'Shallots',
          'Tomato paste',
        ],
        instructions: [
          'Extract lobster meat',
          'Make stock from shells',
          'Sauté aromatics',
          'Finish with cream',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 22.0,
          carbs: 8.0,
          fat: 32.0,
          fiber: 1.0,
        ),
        cookingTime: 90,
        difficulty: 'Hard',
        tags: ['French', 'Seafood', 'Luxury'],
      ),
      Recipe(
        id: 'demo_43',
        title: 'Churros with Chocolate',
        description:
            'Crispy Spanish pastries dusted with cinnamon sugar and chocolate sauce.',
        imageUrl:
            'https://images.unsplash.com/photo-1558182075-fbd9c5d6d499?w=400',
        ingredients: ['Flour', 'Water', 'Salt', 'Sugar', 'Dark chocolate'],
        instructions: [
          'Make choux pastry',
          'Pipe and fry churros',
          'Roll in cinnamon sugar',
          'Serve with chocolate',
        ],
        nutritionInfo: NutritionInfo(
          calories: 280,
          protein: 4.0,
          carbs: 38.0,
          fat: 14.0,
          fiber: 2.0,
        ),
        cookingTime: 25,
        difficulty: 'Medium',
        tags: ['Spanish', 'Dessert', 'Fried'],
      ),
      Recipe(
        id: 'demo_44',
        title: 'Turkey Club Sandwich',
        description:
            'Triple-decker sandwich with turkey, bacon, lettuce, and tomato.',
        imageUrl:
            'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=400',
        ingredients: ['Turkey', 'Bacon', 'Lettuce', 'Tomato', 'Bread'],
        instructions: [
          'Toast bread',
          'Cook bacon',
          'Layer ingredients',
          'Cut into triangles',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 28.0,
          carbs: 32.0,
          fat: 20.0,
          fiber: 4.0,
        ),
        cookingTime: 15,
        difficulty: 'Easy',
        tags: ['Sandwich', 'American', 'Lunch'],
      ),
      Recipe(
        id: 'demo_45',
        title: 'Moroccan Tagine',
        description:
            'Slow-cooked Moroccan stew with lamb, apricots, and aromatic spices.',
        imageUrl:
            'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        ingredients: [
          'Lamb',
          'Dried apricots',
          'Cinnamon',
          'Ginger',
          'Almonds',
        ],
        instructions: [
          'Brown lamb',
          'Add spices and fruit',
          'Slow cook 2 hours',
          'Garnish with almonds',
        ],
        nutritionInfo: NutritionInfo(
          calories: 480,
          protein: 35.0,
          carbs: 24.0,
          fat: 26.0,
          fiber: 4.0,
        ),
        cookingTime: 150,
        difficulty: 'Hard',
        tags: ['Moroccan', 'Slow-cooked', 'Exotic'],
      ),
      Recipe(
        id: 'demo_46',
        title: 'Vanilla Crème Brûlée',
        description:
            'Classic French dessert with vanilla custard and caramelized sugar top.',
        imageUrl:
            'https://images.unsplash.com/photo-1516684669134-de6f7c473a2a?w=400',
        ingredients: [
          'Heavy cream',
          'Vanilla bean',
          'Egg yolks',
          'Sugar',
          'Brown sugar',
        ],
        instructions: [
          'Heat cream with vanilla',
          'Whisk with egg yolks',
          'Bake in water bath',
          'Torch sugar top',
        ],
        nutritionInfo: NutritionInfo(
          calories: 380,
          protein: 6.0,
          carbs: 28.0,
          fat: 28.0,
          fiber: 0.0,
        ),
        cookingTime: 180,
        difficulty: 'Hard',
        tags: ['French', 'Dessert', 'Elegant'],
      ),
      Recipe(
        id: 'demo_47',
        title: 'Pho Bo',
        description:
            'Vietnamese beef noodle soup with aromatic broth and fresh herbs.',
        imageUrl:
            'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400',
        ingredients: [
          'Beef bones',
          'Rice noodles',
          'Beef slices',
          'Bean sprouts',
          'Fresh herbs',
        ],
        instructions: [
          'Make bone broth',
          'Cook noodles',
          'Slice beef thin',
          'Assemble with garnishes',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 28.0,
          carbs: 48.0,
          fat: 12.0,
          fiber: 3.0,
        ),
        cookingTime: 480,
        difficulty: 'Hard',
        tags: ['Vietnamese', 'Soup', 'Noodles'],
      ),
      Recipe(
        id: 'demo_48',
        title: 'Stuffed Mushrooms',
        description:
            'Button mushrooms stuffed with herbs, cheese, and breadcrumbs.',
        imageUrl:
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
        ingredients: [
          'Button mushrooms',
          'Bread crumbs',
          'Parmesan',
          'Garlic',
          'Parsley',
        ],
        instructions: [
          'Remove mushroom stems',
          'Make stuffing',
          'Fill mushroom caps',
          'Bake until golden',
        ],
        nutritionInfo: NutritionInfo(
          calories: 180,
          protein: 8.0,
          carbs: 12.0,
          fat: 12.0,
          fiber: 3.0,
        ),
        cookingTime: 25,
        difficulty: 'Easy',
        tags: ['Appetizer', 'Vegetarian', 'Stuffed'],
      ),
      Recipe(
        id: 'demo_49',
        title: 'Peking Duck',
        description:
            'Traditional Chinese roasted duck with crispy skin and pancakes.',
        imageUrl:
            'https://images.unsplash.com/photo-1625937286074-9ca519d5d9df?w=400',
        ingredients: [
          'Whole duck',
          'Hoisin sauce',
          'Pancakes',
          'Scallions',
          'Cucumber',
        ],
        instructions: [
          'Prepare duck',
          'Roast until crispy',
          'Slice thin',
          'Serve with pancakes and sauce',
        ],
        nutritionInfo: NutritionInfo(
          calories: 520,
          protein: 42.0,
          carbs: 18.0,
          fat: 32.0,
          fiber: 2.0,
        ),
        cookingTime: 300,
        difficulty: 'Hard',
        tags: ['Chinese', 'Roasted', 'Traditional'],
      ),
      Recipe(
        id: 'demo_50',
        title: 'Tiramisu',
        description:
            'Classic Italian dessert with coffee-soaked ladyfingers and mascarpone.',
        imageUrl:
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
        ingredients: [
          'Ladyfingers',
          'Mascarpone',
          'Coffee',
          'Cocoa powder',
          'Marsala wine',
        ],
        instructions: [
          'Make coffee mixture',
          'Whip mascarpone',
          'Layer with soaked cookies',
          'Chill overnight',
        ],
        nutritionInfo: NutritionInfo(
          calories: 420,
          protein: 8.0,
          carbs: 32.0,
          fat: 28.0,
          fiber: 1.0,
        ),
        cookingTime: 30,
        difficulty: 'Medium',
        tags: ['Italian', 'Dessert', 'Coffee'],
      ),
    ];
  }

  // Helper method to get cuisine-specific recipes
  static Future<List<Recipe>> getRecipesByCuisine(String cuisine) async {
    return await searchRecipes(cuisine: cuisine, number: 20);
  }

  // Helper method to get diet-specific recipes
  static Future<List<Recipe>> getRecipesByDiet(String diet) async {
    return await searchRecipes(diet: diet, number: 20);
  }

  // Get trending/popular recipes
  static Future<List<Recipe>> getTrendingRecipes({int number = 20}) async {
    if (!isApiKeyConfigured) {
      print('Spoonacular API key not configured, using fallback data');
      return _getFallbackRecipes();
    }

    try {
      // Use complex search with popularity sorting for trending recipes
      return await searchRecipes(
        number: number,
        // Add popular tags to get trending recipes
      );
    } catch (e) {
      print('Failed to get trending recipes: $e');
      return _getFallbackRecipes();
    }
  }
}
