import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe.dart';

/// Service for managing user favorites in Firestore
class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? get _currentUserId {
    final user = _auth.currentUser;
    print('🔑 Current user ID: ${user?.uid}');
    print('🔑 Is authenticated: ${user != null}');
    return user?.uid;
  }

  /// Collection reference for user favorites
  static CollectionReference get _favoritesCollection =>
      _firestore.collection('user_favorites');

  /// Add a recipe to user's favorites
  static Future<void> addToFavorites(Recipe recipe) async {
    final userId = _currentUserId;
    if (userId == null) throw 'User not authenticated';

    try {
      // Create a document with userId_recipeId as the document ID
      final docId = '${userId}_${recipe.id}';
      
      await _favoritesCollection.doc(docId).set({
        'userId': userId,
        'recipeId': recipe.id,
        'recipe': _recipeToMap(recipe),
        'addedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Successfully added recipe ${recipe.id} to favorites');
    } catch (e) {
      print('❌ Error adding to favorites: $e');
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'Permission denied. Please check Firestore rules.';
      }
      throw 'Failed to add recipe to favorites: $e';
    }
  }

  /// Remove a recipe from user's favorites
  static Future<void> removeFromFavorites(String recipeId) async {
    final userId = _currentUserId;
    if (userId == null) throw 'User not authenticated';

    try {
      final docId = '${userId}_$recipeId';
      await _favoritesCollection.doc(docId).delete();
      print('✅ Successfully removed recipe $recipeId from favorites');
    } catch (e) {
      print('❌ Error removing from favorites: $e');
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'Permission denied. Please check Firestore rules.';
      }
      throw 'Failed to remove recipe from favorites: $e';
    }
  }

  /// Check if a recipe is in user's favorites
  static Future<bool> isFavorite(String recipeId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final docId = '${userId}_$recipeId';
      final doc = await _favoritesCollection.doc(docId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking favorite status: $e');
      return false;
    }
  }

  /// Get all favorite recipes for the current user
  static Future<List<Recipe>> getFavoriteRecipes() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      // Use a simpler query without ordering to avoid index requirement
      final querySnapshot = await _favoritesCollection
          .where('userId', isEqualTo: userId)
          .get();

      final List<Recipe> favorites = [];
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['recipe'] != null) {
          try {
            final recipe = _recipeFromMap(data['recipe'] as Map<String, dynamic>);
            favorites.add(recipe);
          } catch (e) {
            print('Error parsing favorite recipe: $e');
          }
        }
      }
      
      // Sort by title locally (since we can't order by addedAt without index)
      favorites.sort((a, b) => a.title.compareTo(b.title));
      
      return favorites;
    } catch (e) {
      print('❌ Error fetching favorites: $e');
      throw 'Failed to fetch favorite recipes: $e';
    }
  }

  /// Stream of favorite recipes for real-time updates
  static Stream<List<Recipe>> getFavoriteRecipesStream() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    // Use a simpler query without ordering to avoid index requirement
    return _favoritesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final List<Recipe> favorites = [];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['recipe'] != null) {
          try {
            final recipe = _recipeFromMap(data['recipe'] as Map<String, dynamic>);
            favorites.add(recipe);
          } catch (e) {
            print('Error parsing favorite recipe: $e');
          }
        }
      }
      
      // Sort by title locally (since we can't order by addedAt without index)
      favorites.sort((a, b) => a.title.compareTo(b.title));
      
      return favorites;
    });
  }

  /// Convert Recipe to Map for Firestore storage
  static Map<String, dynamic> _recipeToMap(Recipe recipe) {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'description': recipe.description,
      'imageUrl': recipe.imageUrl,
      'ingredients': recipe.ingredients,
      'instructions': recipe.instructions,
      'nutritionInfo': {
        'calories': recipe.nutritionInfo.calories,
        'protein': recipe.nutritionInfo.protein,
        'carbs': recipe.nutritionInfo.carbs,
        'fat': recipe.nutritionInfo.fat,
        'fiber': recipe.nutritionInfo.fiber,
      },
      'cookingTime': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'tags': recipe.tags,
    };
  }

  /// Convert Map from Firestore to Recipe
  static Recipe _recipeFromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      nutritionInfo: NutritionInfo(
        calories: (map['nutritionInfo']?['calories'] ?? 0).toInt(),
        protein: (map['nutritionInfo']?['protein'] ?? 0.0).toDouble(),
        carbs: (map['nutritionInfo']?['carbs'] ?? 0.0).toDouble(),
        fat: (map['nutritionInfo']?['fat'] ?? 0.0).toDouble(),
        fiber: (map['nutritionInfo']?['fiber'] ?? 0.0).toDouble(),
      ),
      cookingTime: (map['cookingTime'] ?? 30).toInt(),
      difficulty: map['difficulty'] ?? 'Medium',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  /// Toggle favorite status (add if not favorite, remove if favorite)
  static Future<bool> toggleFavorite(Recipe recipe) async {
    final isFav = await isFavorite(recipe.id);
    if (isFav) {
      await removeFromFavorites(recipe.id);
      return false;
    } else {
      await addToFavorites(recipe);
      return true;
    }
  }
}