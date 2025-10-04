# SmartChef - AI-Powered Recipe Discovery App

A modern Flutter mobile app for recipe discovery and AI-powered cooking assistance.

## 🍳 Features

### 1. Recipe Discovery Module
- **Swipeable Carousel**: Browse featured recipes with beautiful cards
- **Recipe Details**: Step-by-step instructions, nutritional info, and ingredients
- **Search Functionality**: Find recipes by name or ingredients
- **Categories**: Quick access to breakfast, lunch, dinner, and more

### 2. AI Recipe Generator Module
- **Ingredient-Based Generation**: Input available ingredients to get recipe suggestions
- **Quick Select**: Choose from common ingredients with tap selection
- **Smart Recommendations**: AI-powered recipe creation based on your ingredients
- **Custom Recipes**: Generated recipes tailored to your available ingredients

### 3. Image Recognition Module
- **Photo Capture**: Take photos of dishes using camera or gallery
- **AI Dish Detection**: Identify dishes with confidence scores
- **Recipe Suggestions**: Get recommended recipes for detected dishes
- **Visual Recognition**: Powered by mock Gemini Vision API

### 4. User Profile Module
- **Dietary Preferences**: Set and manage dietary restrictions (vegan, keto, etc.)
- **Favorites**: Save and organize your favorite recipes
- **Cooking History**: Track your cooking adventures
- **Personal Stats**: View your cooking statistics

## 🎨 Design Features

- **Material 3 Design**: Modern, clean UI with beautiful animations
- **Responsive Layout**: Optimized for different screen sizes
- **Smooth Animations**: Hero transitions and page animations
- **Custom Components**: Reusable widgets for consistent design
- **Bottom Navigation**: Easy access to all main features

## 📱 Screenshots

The app includes:
- Home screen with recipe carousel
- AI recipe generator with ingredient selection
- Image recognition with camera integration
- Profile with preferences and favorites

## 🚀 Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: StatefulWidget with setState
- **Image Handling**: image_picker package
- **UI Components**: carousel_slider for recipe browsing
- **HTTP Requests**: http package (ready for API integration)

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── recipe.dart          # Recipe and nutrition models
│   └── user.dart            # User and AI request models
├── screens/                  # App screens
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── ai_recipe_generator_screen.dart
│   ├── image_recognition_screen.dart
│   ├── profile_screen.dart
│   └── recipe_detail_screen.dart
├── widgets/                  # Reusable widgets
│   └── recipe_card.dart     # Custom recipe card component
└── data/                    # Mock data
    └── dummy_data.dart      # Sample recipes and user data
```

## 🔧 Setup & Installation

1. **Prerequisites**:
   - Flutter SDK installed
   - Android Studio or VS Code with Flutter extensions
   - Android emulator or physical device

2. **Installation**:
   ```bash
   git clone <repository-url>
   cd recipe_gen
   flutter pub get
   flutter run
   ```

3. **Dependencies**:
   - `carousel_slider: ^4.2.1` - For recipe carousels
   - `image_picker: ^1.0.4` - For camera/gallery access
   - `http: ^1.1.0` - For future API integration

## 🎯 Future Enhancements

### Real API Integration
- Replace dummy data with real Gemini API calls
- Implement actual image recognition
- Add real user authentication
- Connect to recipe databases

### Additional Features
- Shopping list generation
- Meal planning
- Recipe sharing
- Cooking timers
- Video tutorials
- Social features

### Performance Optimizations
- Image caching
- Lazy loading
- State management with Provider/Bloc
- Offline support

## 🧪 Testing

The app is built with dummy data for immediate testing:
- Sample recipes with full details
- Mock AI recipe generation
- Simulated image recognition
- Test user profiles and preferences

All features are fully functional with mock data, making it easy to test the complete user experience.

## 📝 Code Quality

- **Clean Architecture**: Well-organized folder structure
- **Commented Code**: Extensive documentation for easy maintenance
- **Reusable Components**: Modular widget design
- **Error Handling**: Graceful error handling throughout
- **Responsive Design**: Adaptable to different screen sizes

## 🎨 Customization

The app is designed for easy customization:
- **Theme Colors**: Modify primary colors in `main.dart`
- **Recipe Data**: Update `dummy_data.dart` for different content
- **UI Components**: Customize widgets in the `widgets/` folder
- **Navigation**: Adjust bottom navigation in `main_navigation_screen.dart`

---

**SmartChef** - Your AI-powered cooking companion! 👨‍🍳✨
