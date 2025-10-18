# Recipe Generator App - Spoonacular API Integration Guide

## Overview

This Flutter app has been integrated with the Spoonacular Food API to provide real recipe data, advanced search capabilities, and ingredient-based recipe suggestions. The app supports both online (API) and offline (local data) modes.

## Features Integrated

### 🔍 Recipe Discovery

- **Smart Search**: Search recipes by name, ingredients, or cooking method
- **Cuisine Filtering**: Filter by Italian, Asian, Mexican, American, and more cuisines
- **Diet-based Filtering**: Find recipes for specific diets (vegetarian, vegan, keto, etc.)
- **Random Recipe Discovery**: Get fresh recipe suggestions

### 🤖 AI Recipe Generator

- **Ingredient-based Generation**: Input available ingredients and get matching recipes
- **Smart Fallbacks**: If no API recipes match, generates custom recipes with your ingredients
- **Nutritional Information**: Each recipe includes detailed nutrition facts

### 📸 Image Recognition

- **Visual Recipe Detection**: Take photos of dishes and get similar recipe suggestions
- **Ingredient Analysis**: Identifies possible ingredients from food images
- **Recipe Recommendations**: Suggests recipes based on visual analysis

### 👤 User Profile

- **Favorite Recipes**: Save recipes from both API and local sources
- **Cooking History**: Track your cooking journey
- **Dietary Preferences**: Set preferences that influence recipe suggestions

## API Setup Instructions

### Step 1: Get Your Spoonacular API Key

1. Visit [Spoonacular Food API](https://spoonacular.com/food-api)
2. Sign up for a free account
3. Navigate to your profile/dashboard
4. Copy your API key

### Step 2: Configure the App

1. Open `lib/config/api_config.dart`
2. Replace `'YOUR_API_KEY_HERE'` with your actual API key:
   ```dart
   static const String spoonacularApiKey = 'your-actual-api-key-here';
   ```
3. Set `useFallbackData` to `false` to enable API features:
   ```dart
   static const bool useFallbackData = false;
   ```

### Step 3: Run the App

```bash
flutter pub get
flutter run -d chrome
```

## API Features vs Local Fallbacks

### With API Key Configured:

- ✅ Real recipe data from Spoonacular's database
- ✅ Advanced search with 500,000+ recipes
- ✅ Accurate nutritional information
- ✅ Multiple cuisine and diet filters
- ✅ Ingredient-based recipe matching
- ✅ High-quality recipe images

### Without API Key (Local Mode):

- ✅ 10 sample recipes for demonstration
- ✅ Basic search and filtering
- ✅ All app features functional
- ✅ Generated recipes from selected ingredients
- ⚠️ Limited recipe variety

## Configuration Options

Edit `lib/config/api_config.dart` to customize:

```dart
class ApiConfig {
  // Your API key
  static const String spoonacularApiKey = 'YOUR_API_KEY_HERE';

  // Use local data if true, API data if false
  static const bool useFallbackData = true;

  // Request timeout (seconds)
  static const int requestTimeoutSeconds = 10;

  // Cache settings
  static const int cacheValidityMinutes = 30;
  static const int maxCachedRecipes = 100;
}
```

## Data Source Management

The app intelligently manages data sources:

### Hybrid Mode (Recommended)

- Tries API first, falls back to local data on failure
- Provides best user experience
- Handles network issues gracefully

### API-Only Mode

- Always uses Spoonacular API
- Requires stable internet connection
- Provides maximum recipe variety

### Local-Only Mode

- Uses sample recipes only
- Works offline
- Good for development/testing

## Free Tier Limitations

Spoonacular's free tier includes:

- **150 API calls per day**
- Full recipe information
- Ingredient analysis
- Nutrition data
- Recipe search and filtering

The app implements intelligent caching to maximize your daily API quota.

## Usage Examples

### Search Recipes

```dart
// Search by query
final recipes = await RecipeRepository.searchRecipes('chicken pasta');

// Search by cuisine
final italianRecipes = await RecipeRepository.getRecipesByCuisine('Italian');

// Search by diet
final veganRecipes = await RecipeRepository.getRecipesByDiet('vegan');
```

### Generate Recipe from Ingredients

```dart
final ingredients = ['chicken', 'rice', 'vegetables'];
final recipes = await RecipeRepository.getRecipesByIngredients(ingredients);
```

### Get Random Recipes

```dart
final randomRecipes = await RecipeRepository.getRandomRecipes(count: 12);
```

## Error Handling

The app handles various scenarios:

- **No Internet**: Falls back to local recipes
- **API Quota Exceeded**: Uses cached data
- **Invalid API Key**: Switches to local mode
- **Network Timeout**: Retries with fallback

## Troubleshooting

### App Shows Only Sample Recipes

- Check your API key in `api_config.dart`
- Ensure `useFallbackData` is set to `false`
- Verify your internet connection

### "API Error" Messages

- Check your API key validity
- Verify you haven't exceeded daily quota (150 requests)
- Check network connectivity

### Slow Recipe Loading

- Increase `requestTimeoutSeconds` in config
- Check your internet speed
- Consider using hybrid mode for better performance

## Development Notes

### Repository Pattern

The app uses a repository pattern to abstract data sources:

- `RecipeRepository`: Main interface for recipe data
- `SpoonacularService`: Handles API communication
- `DummyData`: Provides local fallback recipes

### Caching Strategy

- Recipes are cached for 30 minutes by default
- Cache prevents redundant API calls
- Cache is automatically invalidated when needed

### Model Mapping

- `Recipe.fromSpoonacularJson()`: Maps API responses to app models
- Handles missing fields gracefully
- Provides consistent data structure

## Production Considerations

### API Key Security

- Store API keys in environment variables for production
- Never commit real API keys to version control
- Consider using build-time configuration

### Rate Limiting

- Implement request throttling for production apps
- Monitor API usage to stay within quotas
- Consider upgrading to paid tier for higher limits

### Error Monitoring

- Add crash reporting (Firebase Crashlytics)
- Monitor API response times
- Track API quota usage

## Support

For issues with:

- **Spoonacular API**: Visit [Spoonacular Support](https://spoonacular.com/food-api/docs)
- **App Features**: Check the troubleshooting section above
- **Flutter Development**: Refer to [Flutter Documentation](https://flutter.dev/docs)

## License

This project uses the Spoonacular Food API. Please review their [Terms of Service](https://spoonacular.com/food-api/terms) for commercial use.
