import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/spoonacular_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

// AI Recipe Generator screen
class AIRecipeGeneratorScreen extends StatefulWidget {
  const AIRecipeGeneratorScreen({super.key});

  @override
  State<AIRecipeGeneratorScreen> createState() => _AIRecipeGeneratorScreenState();
}

class _AIRecipeGeneratorScreenState extends State<AIRecipeGeneratorScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  final List<String> _selectedIngredients = [];
  List<Recipe> _generatedRecipes = [];
  bool _isGenerating = false;
  final ScrollController _scrollController = ScrollController();
  bool _isInputMinimized = false;

  // Common ingredients for quick selection
  final List<String> _commonIngredients = [
    'Chicken', 'Beef', 'Fish', 'Eggs', 'Rice', 'Pasta', 'Potatoes',
    'Tomatoes', 'Onions', 'Garlic', 'Cheese', 'Milk', 'Butter',
    'Olive Oil', 'Salt', 'Pepper', 'Basil', 'Oregano', 'Lemon',
    'Spinach', 'Mushrooms', 'Bell Peppers', 'Carrots', 'Broccoli',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 100.0; // Minimize after scrolling 100 pixels
    bool shouldMinimize = _scrollController.offset > threshold;
    
    if (shouldMinimize != _isInputMinimized) {
      setState(() {
        _isInputMinimized = shouldMinimize;
      });
    }
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
      _generatedRecipes.clear();
    });

    try {
      final recipes = await SpoonacularService.findRecipesByIngredients(_selectedIngredients);
      setState(() {
        _generatedRecipes = recipes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate recipes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  /// Load detailed recipe information
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - minimize when scrolling
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _isInputMinimized ? _buildMinimizedHeader() : _buildFullHeader(),
                ),

                const SizedBox(height: 24),

                // Ingredient input - hide when minimized
                if (!_isInputMinimized) ...[
                  _buildIngredientInput(),
                  const SizedBox(height: 16),
                  _buildQuickSelect(),
                  const SizedBox(height: 16),
                  _buildSelectedIngredients(),
                  const SizedBox(height: 16),
                ],

                // Generate button - always visible but compact when minimized
                _isInputMinimized ? _buildGenerateButtonCompact() : _buildGenerateButton(),

                const SizedBox(height: 24),

                // Generated recipes
                if (_generatedRecipes.isNotEmpty) ...[
                  Text(
                    'Found ${_generatedRecipes.length} recipes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_generatedRecipes.map((recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate directly to recipe detail since we already have full data
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                      child: RecipeCard(
                        recipe: recipe,
                        isLarge: true,
                      ),
                    ),
                  ))),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullHeader() {
    return Row(
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tell me what you have, I\'ll create magic!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimizedHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AI Recipe Generator',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_selectedIngredients.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedIngredients.length} ingredients',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIngredientInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      borderSide: BorderSide(color: Colors.grey[300]!),
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
                onPressed: () => _addIngredient(_ingredientsController.text),
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
    );
  }

  Widget _buildQuickSelect() {
    if (_commonIngredients.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _commonIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = _commonIngredients[index];
              final isSelected = _selectedIngredients.contains(ingredient);
              
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    _removeIngredient(ingredient);
                  } else {
                    _addIngredient(ingredient);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildSelectedIngredients() {
    if (_selectedIngredients.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                deleteIconColor: Theme.of(context).primaryColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }

  Widget _buildGenerateButtonCompact() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _selectedIngredients.isNotEmpty && !_isGenerating 
            ? _generateRecipe 
            : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Generating...', style: TextStyle(fontSize: 14)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 16),
                  SizedBox(width: 6),
                  Text('Generate Recipe', style: TextStyle(fontSize: 14)),
                ],
              ),
      ),
    );
  }
}