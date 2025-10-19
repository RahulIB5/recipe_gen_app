class FirebaseConfig {
  // Firebase project configuration
  static const String projectId = 'smartchef-recipe-app';
  static const String storageBucket = 'smartchef-recipe-app.appspot.com';

  // Collections
  static const String usersCollection = 'users';
  static const String recipesCollection = 'recipes';
  static const String favoritesCollection = 'favorites';
  static const String reviewsCollection = 'reviews';
  static const String mealPlansCollection = 'meal_plans';

  // Storage paths
  static const String recipeImagesPath = 'recipe_images';
  static const String userImagesPath = 'user_images';

  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // Max cached recipes
}
