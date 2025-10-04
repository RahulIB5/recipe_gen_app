# SmartChef App - Feature Testing Guide

## 🧪 How to Test All Features

This guide will help you test all the features of the SmartChef app using the dummy data.

### 📱 Main Navigation
- **Bottom Navigation Bar**: Tap between Home, AI Generator, Image Scan, and Profile tabs
- **Smooth Transitions**: Notice the smooth transitions between screens

### 🏠 Home Screen Features

#### Recipe Discovery Carousel
1. **Auto-play Carousel**: Wait and watch recipes automatically slide
2. **Manual Navigation**: 
   - Swipe left/right on the carousel
   - Tap the dots below to jump to specific recipes
3. **Recipe Details**: Tap any recipe card to view full details
4. **Search Bar**: Tap the search bar (shows "coming soon" message)
5. **Category Chips**: Tap category buttons (Breakfast, Lunch, etc.)

#### Recipe Detail Screen
1. **Hero Animation**: Notice the smooth transition when opening a recipe
2. **Favorite Toggle**: Tap the heart icon to add/remove from favorites
3. **Nutrition Information**: View calories, protein, carbs, fat
4. **Step-by-step Instructions**: Scroll through numbered cooking steps
5. **Ingredients List**: View all required ingredients with bullet points

### 🤖 AI Recipe Generator Features

#### Ingredient Input
1. **Manual Entry**: 
   - Type ingredients in the text field
   - Press "Add" or hit Enter to add them
2. **Quick Select Grid**: 
   - Tap common ingredients to select/deselect
   - Selected ingredients turn purple
3. **Ingredient Management**:
   - View selected ingredients as chips
   - Tap the X on any chip to remove it

#### Recipe Generation
1. **Generate Recipe**: Tap "Generate Recipe" button
2. **Loading Animation**: Watch the AI cooking animation
3. **Generated Result**: View the AI-created recipe card
4. **Recipe Details**: Tap the generated recipe to view full details

### 📸 Image Recognition Features

#### Image Selection
1. **Image Source Dialog**: Tap "Pick Image" to choose source
2. **Camera Option**: Select camera to take a new photo
3. **Gallery Option**: Select gallery to choose existing photo
4. **Image Display**: See your selected image in the preview area

#### AI Analysis
1. **Analyze Button**: Tap "Analyze" after selecting an image
2. **Processing Animation**: Watch the AI analysis animation
3. **Detection Results**: 
   - View detected dish name
   - See confidence percentage
   - Get suggested recipe recommendations

### 👤 Profile Screen Features

#### User Information
1. **Profile Header**: View user avatar, name, and email
2. **Statistics Cards**: See counts for favorites, cooked recipes, and preferences

#### Favorites Tab
1. **View Favorites**: See all favorited recipes (initially includes Carbonara and Avocado Toast)
2. **Recipe Cards**: Tap any favorite to view details
3. **Empty State**: Remove all favorites to see empty state message

#### History Tab
1. **Cooking History**: View previously "cooked" recipes
2. **Recipe Interaction**: Tap recipes to view details
3. **Empty State**: Clear history to see empty state

#### Preferences Tab
1. **Dietary Options**: View all available dietary preferences
2. **Selection Toggle**: Tap options to select/deselect (they turn purple)
3. **Save Preferences**: Tap "Save Preferences" to apply changes
4. **Success Feedback**: See confirmation message when saved

### 🎨 UI/UX Features to Notice

#### Design Elements
1. **Material 3 Design**: Modern, clean interface throughout
2. **Purple Theme**: Consistent purple color scheme
3. **Rounded Corners**: 12px radius on cards and buttons
4. **Soft Shadows**: Subtle elevation on cards and components

#### Animations
1. **Page Transitions**: Smooth fade transitions between screens
2. **Hero Animations**: Recipe card to detail screen transitions
3. **Loading Spinners**: Animated loading indicators during AI processing
4. **Tab Switching**: Smooth bottom navigation transitions

#### Responsive Elements
1. **Grid Layouts**: Responsive ingredient grid and preference grid
2. **Flexible Cards**: Recipe cards adapt to content
3. **Scroll Views**: Smooth scrolling throughout the app

### 🔧 Testing Scenarios

#### Complete User Journey
1. **Discover Recipe**: Browse carousel → tap recipe → view details → favorite it
2. **Generate Recipe**: Add ingredients → generate → view result → check details
3. **Recognize Image**: Pick image → analyze → view results → explore suggestion
4. **Manage Profile**: Check favorites → update preferences → save changes

#### Error Handling
1. **No Ingredients**: Try generating recipe without ingredients
2. **No Image**: Try analyzing without selecting image
3. **Network Simulation**: All API calls are mocked for testing

#### Performance Features
1. **Image Loading**: Network images with error fallbacks
2. **Smooth Scrolling**: Long ingredient and instruction lists
3. **State Management**: Preserved state when switching tabs

### 📝 Dummy Data Content

#### Available Recipes
1. **Spaghetti Carbonara** (Italian, Medium, 20 min)
2. **Chicken Caesar Salad** (Healthy, Easy, 25 min)
3. **Avocado Toast** (Breakfast, Vegan, Easy, 10 min)
4. **Beef Stir Fry** (Asian, Medium, 15 min)
5. **Greek Yogurt Parfait** (Breakfast, Healthy, Easy, 5 min)

#### User Profile Data
- **Name**: Alex Johnson
- **Email**: alex.johnson@email.com
- **Initial Preferences**: Vegetarian
- **Favorites**: Carbonara, Avocado Toast
- **History**: All 3 recipes have been "cooked"

#### Dietary Options
- Vegetarian, Vegan, Gluten-Free, Keto, Paleo, Low-Carb, Dairy-Free, Nut-Free

### 🚀 Ready for Production

All features are implemented with mock data and are ready for real API integration:
- Replace `DummyData` class with actual API calls
- Update image recognition with real Gemini Vision API
- Connect AI generation to actual Gemini API
- Add real user authentication and data persistence

The app provides a complete, testable experience that demonstrates all planned functionality!