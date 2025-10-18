// API Configuration
class ApiConfig {
  // Replace this with your actual Spoonacular API key
  // Get one for free at: https://spoonacular.com/food-api
  static const String spoonacularApiKey =
      '*****************************'; // ⚠️ REPLACE WITH REAL KEY

  // Replace this with your actual Gemini API key
  // Get one for free at: https://makersuite.google.com/app/apikey
  static const String geminiApiKey =
      'YOUR_GEMINI_API_KEY_HERE'; // ⚠️ REPLACE WITH REAL KEY

  // API endpoints
  static const String spoonacularBaseUrl = 'https://api.spoonacular.com';

  // Fallback settings
  static const bool useFallbackData =
      true; // Set to false when you have a valid API key
  static const int requestTimeoutSeconds = 10;

  // Cache settings
  static const int cacheValidityMinutes = 30;
  static const int maxCachedRecipes = 100;
}

// Instructions for getting API keys:
/*
SPOONACULAR API SETUP:
1. Go to https://spoonacular.com/food-api
2. Sign up for a free account
3. Navigate to your profile/dashboard
4. Copy your API key
5. Replace the spoonacularApiKey above with your actual key
6. Set useFallbackData to false to use real API data

Free tier includes:
- 150 requests per day
- Full recipe information
- Ingredient analysis
- Nutrition data

GEMINI API SETUP:
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key
5. Replace 'YOUR_GEMINI_API_KEY_HERE' above with your actual key

Gemini AI Features:
- AI Recipe Generator: Natural language recipe creation from ingredients
- Image Recognition: Dish identification and recipe generation from photos
- Advanced recipe customization and suggestions
- Free tier: 15 requests per minute, 1500 requests per day
*/
