# SmartChef - AI-Powered Recipe Discovery App

A modern Flutter mobile app for recipe discovery, search functionality, and favorites management with Firebase integration.

## 🍳 Features

### Core Functionality
- **Recipe Search**: Search recipes by name using Spoonacular API
- **Ingredient-Based Search**: Find recipes using available ingredients
- **Favorites System**: Save and manage favorite recipes with Firebase
- **User Authentication**: Email/password and Google OAuth login
- **Real-time Sync**: Favorites synchronized across devices


### User Experience
- **Material 3 Design**: Modern, clean UI with beautiful animations
- **Recipe Carousel**: Browse featured recipes with swipeable cards
- **Detailed Recipe View**: Complete ingredients, instructions, and nutrition info
- **Search Categories**: Quick access to popular recipe categories
- **Profile Management**: View favorites and manage account settings

## 🚀 Technical Stack

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore)
- **API Integration**: Spoonacular Recipe API
- **Authentication**: Firebase Auth with Google Sign-In
- **Database**: Cloud Firestore for favorites
- **State Management**: StatefulWidget with setState
- **Environment**: flutter_dotenv for secure API key management

## 📱 Key Screens

1. **Home Screen**: Recipe carousel, search bar, popular categories
2. **Search Results**: Grid/list view of recipe results
3. **Recipe Details**: Complete recipe information with favorite option
4. **Ingredients Screen**: Search recipes by available ingredients
5. **Profile Screen**: User info, favorites, and settings
6. **Authentication**: Login/register with email or Google

## � Setup & Installation

### Prerequisites
- Flutter SDK (3.8.1+)
- Firebase project setup
- Spoonacular API key

### 1. Clone Repository
```bash
git clone https://github.com/RahulIB5/recipe_gen_app
cd recipe_gen_app
```

### 2. Environment Setup
Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` and add your API keys:
```env
SPOONACULAR_API_KEY=your_spoonacular_api_key_here
SPOONACULAR_BASE_URL=https://api.spoonacular.com
```

### 3. Get API Keys

**Spoonacular API**:
1. Visit [Spoonacular API](https://spoonacular.com/food-api)
2. Sign up for a free account
3. Get your API key from the dashboard
4. Add it to your `.env` file

### 4. Firebase Setup
1. Create a Firebase project
2. Enable Authentication (Email/Password, Google)
3. Create Firestore database
4. Download `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
5. Place configuration files in respective platform folders

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Run the App
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase init
├── config/
│   └── api_config.dart         # API configuration with env variables
├── models/
│   ├── recipe.dart            # Recipe and nutrition models
│   └── user.dart              # User models
├── screens/
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── search_results_screen.dart
│   ├── ingredients_screen.dart
│   ├── profile_screen.dart
│   ├── recipe_detail_screen.dart
│   └── auth/
│       └── enhanced_login_screen.dart
├── services/
│   ├── auth_service.dart      # Firebase authentication
│   ├── favorites_service.dart # Firestore favorites management
│   └── spoonacular_service.dart # API service
├── widgets/
│   ├── recipe_card.dart       # Reusable recipe card
│   └── favorite_button.dart   # Heart icon for favorites
└── data/
    └── dummy_data.dart        # Sample data for offline testing
```

## � Security Features

- **Environment Variables**: API keys stored securely in `.env` file
- **Firebase Rules**: Secure Firestore rules for user data
- **Authentication**: Proper user authentication with Firebase
- **Git Safety**: `.env` file excluded from version control

## 🎯 API Integration

### Spoonacular API Endpoints Used
- **Complex Search**: `/recipes/complexSearch` - Search recipes by name
- **Find by Ingredients**: `/recipes/findByIngredients` - Ingredient-based search
- **Recipe Information**: `/recipes/{id}/information` - Detailed recipe data

### Firebase Services
- **Authentication**: User login/register with email and Google
- **Firestore**: Real-time favorites storage and synchronization
- **Security Rules**: Proper data access control

## 📊 Features in Detail

### Search Functionality
- Real-time search with Spoonacular API
- Popular search suggestions
- Search by recipe name or ingredients
- Detailed recipe information on tap

### Favorites System
- Heart icon to add/remove favorites
- Real-time updates with Firestore
- Favorites persist across app sessions
- Profile page shows all saved recipes

### Authentication
- Email/password registration and login
- Google OAuth integration
- Automatic login state management
- Secure user session handling

## 🧪 Testing

The app includes both real API integration and fallback dummy data:
- **Live API**: Full Spoonacular integration for recipe search
- **Offline Support**: Dummy data when API is unavailable
- **Firebase**: Real user authentication and data storage
- **Error Handling**: Graceful handling of API failures

## 📝 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.15.2
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  google_sign_in: ^6.2.0
  http: ^1.1.0
  carousel_slider: ^5.1.0
  flutter_dotenv: ^5.1.0
  flutter_spinkit: ^5.2.0
```

## � Future Enhancements

- Recipe meal planning
- Shopping list generation
- Cooking timers and notifications
- Recipe sharing and social features
- Offline recipe caching
- Advanced search filters
- Recipe ratings and reviews

## 🎨 Customization

- **Theme**: Modify colors in `main.dart` MaterialApp theme
- **API**: Add more recipe APIs in `services/` folder
- **UI Components**: Customize widgets for different layouts
- **Firebase Rules**: Adjust Firestore security rules as needed

---

**SmartChef** - Your complete recipe discovery and management companion! 👨‍🍳✨
