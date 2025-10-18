import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import '../services/gemini_service.dart';

// AI Recipe Generator screen
class AIRecipeGeneratorScreen extends StatefulWidget {
  const AIRecipeGeneratorScreen({super.key});

  @override
  State<AIRecipeGeneratorScreen> createState() =>
      _AIRecipeGeneratorScreenState();
}

class _AIRecipeGeneratorScreenState extends State<AIRecipeGeneratorScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  final List<String> _selectedIngredients = [];
  Recipe? _generatedRecipe;
  bool _isGenerating = false;

  // Common ingredients for quick selection
  final List<String> _commonIngredients = [
    'Chicken',
    'Beef',
    'Fish',
    'Eggs',
    'Rice',
    'Pasta',
    'Potatoes',
    'Tomatoes',
    'Onions',
    'Garlic',
    'Cheese',
    'Milk',
    'Butter',
    'Olive Oil',
    'Salt',
    'Pepper',
    'Basil',
    'Oregano',
    'Lemon',
    'Spinach',
    'Mushrooms',
    'Bell Peppers',
    'Carrots',
    'Broccoli',
  ];

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
      });
      _ingredientsController.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
  }

  Future<void> _generateRecipe() async {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some ingredients first!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedRecipe = null;
    });

    try {
      // Use Gemini AI to generate recipes from ingredients
      final recipes = await GeminiService.generateRecipeFromIngredients(
        _selectedIngredients,
      );

      setState(() {
        // Use the first AI-generated recipe, or create a fallback
        _generatedRecipe = recipes.isNotEmpty
            ? recipes.first
            : _createFallbackRecipe();
        _isGenerating = false;
      });

      if (recipes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated ${recipes.length} AI recipe(s)!'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error generating AI recipe: $e');
      setState(() {
        _generatedRecipe = _createFallbackRecipe();
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI temporarily unavailable. Using fallback recipe.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Recipe _createFallbackRecipe() {
    return Recipe(
      id: 'generated_${DateTime.now().millisecondsSinceEpoch}',
      title:
          'AI Generated Recipe with ${_selectedIngredients.take(3).join(", ")}',
      description:
          'A delicious recipe created using your selected ingredients: ${_selectedIngredients.join(", ")}.',
      imageUrl:
          'https://images.unsplash.com/photo-1546548970-71785318a17b?w=400',
      ingredients: [
        ..._selectedIngredients,
        'Salt to taste',
        'Black pepper',
        'Olive oil',
      ],
      instructions: [
        'Prepare all ingredients by washing and chopping as needed.',
        'Heat olive oil in a large pan over medium heat.',
        'Add your main ingredients and cook until tender.',
        'Season with salt and pepper to taste.',
        'Serve hot and enjoy your AI-generated creation!',
      ],
      nutritionInfo: NutritionInfo(
        calories: 350,
        protein: 20.0,
        carbs: 25.0,
        fat: 15.0,
        fiber: 5.0,
      ),
      cookingTime: 25,
      difficulty: 'Easy',
      tags: ['AI Generated', 'Custom', 'Quick'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Recipe Generator',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Tell me what you have, I\'ll create magic!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ingredient input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Ingredients',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientsController,
                            decoration: InputDecoration(
                              hintText: 'Type an ingredient...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: _addIngredient,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _addIngredient(_ingredientsController.text),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Common ingredients quick select
              if (_commonIngredients.isNotEmpty) ...[
                Text(
                  'Quick Select',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _commonIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = _commonIngredients[index];
                      final isSelected = _selectedIngredients.contains(
                        ingredient,
                      );

                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            _removeIngredient(ingredient);
                          } else {
                            _addIngredient(ingredient);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Selected ingredients
              if (_selectedIngredients.isNotEmpty) ...[
                Text(
                  'Selected Ingredients',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: _selectedIngredients.map((ingredient) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      child: Chip(
                        label: Text(ingredient),
                        onDeleted: () => _removeIngredient(ingredient),
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        deleteIconColor: Theme.of(context).primaryColor,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateRecipe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Generating Recipe...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome),
                            SizedBox(width: 8),
                            Text('Generate Recipe'),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Generated recipe
              if (_generatedRecipe != null)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: RecipeCard(recipe: _generatedRecipe!, isLarge: true),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
