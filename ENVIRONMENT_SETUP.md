# Environment Setup for SmartChef

## Securing API Keys

This project uses environment variables to secure sensitive API keys. Follow these steps to set up your environment:

### 1. Create Environment File

Copy the example environment file and add your actual API keys:

```bash
cp .env.example .env
```

### 2. Add Your API Keys

Edit the `.env` file and replace the placeholder values with your actual API keys:

```env
# Spoonacular API Configuration
SPOONACULAR_API_KEY=your_actual_spoonacular_api_key_here
SPOONACULAR_BASE_URL=https://api.spoonacular.com
```

### 3. Get Spoonacular API Key

1. Visit [Spoonacular API](https://spoonacular.com/food-api)
2. Sign up for a free account
3. Navigate to your dashboard and copy your API key
4. Paste it into the `.env` file

### 4. Security Notes

- **Never commit `.env` to version control** - it's already in `.gitignore`
- The `.env.example` file shows the structure without actual keys
- In production, use secure environment variable management
- Consider using Firebase Remote Config for additional security

### 5. Dependencies

The app uses `flutter_dotenv` package to load environment variables:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

### 6. Usage in Code

Environment variables are accessed through the ApiConfig class:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get spoonacularApiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  static String get spoonacularBaseUrl => dotenv.env['SPOONACULAR_BASE_URL'] ?? 'https://api.spoonacular.com';
}
```

## Running the App

After setting up your `.env` file:

```bash
flutter pub get
flutter run
```

The app will automatically load the environment variables on startup.