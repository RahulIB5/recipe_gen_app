import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../services/gemini_service.dart';
import '../services/spoonacular_service.dart';
import '../widgets/recipe_card.dart';

/// Gemini AI-powered Food Recognition Screen
/// This is the NEW functional version using Gemini API
class GeminiFoodRecognitionScreen extends StatefulWidget {
  const GeminiFoodRecognitionScreen({super.key});

  @override
  State<GeminiFoodRecognitionScreen> createState() => _GeminiFoodRecognitionScreenState();
}

class _GeminiFoodRecognitionScreenState extends State<GeminiFoodRecognitionScreen> {
  File? _selectedImage;
  String? _detectedFood;
  List<Recipe>? _suggestedRecipes;
  bool _isProcessing = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      print('📸 [UI] User selecting image from ${source == ImageSource.camera ? "camera" : "gallery"}');
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('✅ [UI] Image selected: ${image.path}');
        setState(() {
          _selectedImage = File(image.path);
          _detectedFood = null;
          _suggestedRecipes = null;
          _errorMessage = null;
        });
      } else {
        print('⚠️ [UI] No image selected');
      }
    } catch (e) {
      print('❌ [UI] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _identifyAndFetchRecipes() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _detectedFood = null;
      _suggestedRecipes = null;
      _errorMessage = null;
    });

    try {
      print('\n═══════════════════════════════════════');
      print('🚀 [PROCESS] Starting food identification process');
      print('═══════════════════════════════════════\n');

      // Step 1: Read image bytes
      final imageBytes = await _selectedImage!.readAsBytes();
      print('📦 [PROCESS] Image loaded: ${imageBytes.length} bytes');

      // Step 2: Call Gemini API
      print('\n--- GEMINI API CALL ---');
      final foodName = await GeminiService.identifyFoodFromImage(imageBytes);

      if (foodName.isEmpty) {
        throw Exception('Could not identify food from image. Please try another image with clear food items.');
      }

      setState(() {
        _detectedFood = foodName;
      });

      print('\n✅ [PROCESS] Food identified: "$foodName"');

      // Step 3: Fetch recipes from Spoonacular
      print('\n--- SPOONACULAR API CALL ---');
      print('🔍 [Spoonacular] Searching recipes for: "$foodName"');
      
      final recipes = await SpoonacularService.searchRecipes(
        query: foodName,
        number: 6,
      );

      print('📊 [Spoonacular] Recipe count returned: ${recipes.length}');
      
      if (recipes.isEmpty) {
        print('⚠️ [Spoonacular] No recipes found');
      } else {
        print('✅ [Spoonacular] Successfully fetched ${recipes.length} recipes');
        for (int i = 0; i < recipes.length; i++) {
          print('   ${i + 1}. ${recipes[i].title}');
        }
      }

      setState(() {
        _suggestedRecipes = recipes;
        _isProcessing = false;
      });

      print('\n═══════════════════════════════════════');
      print('✅ [PROCESS] Process completed successfully!');
      print('═══════════════════════════════════════\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${recipes.length} recipes for $foodName!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('\n❌ [PROCESS] Error occurred: $e');
      print('═══════════════════════════════════════\n');
      
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Image Source',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from your photos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_camera, color: Colors.green),
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Food Recognition'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Display
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 400,
                  maxHeight: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _selectedImage == null
                    ? _buildImagePlaceholder()
                    : _buildImageDisplay(),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text(
                        'Select Image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectedImage == null || _isProcessing
                          ? null
                          : _identifyAndFetchRecipes,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isProcessing ? 'Analyzing...' : 'Identify Food',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Detection Result
              if (_detectedFood != null) ...[
                const SizedBox(height: 24),
                _buildDetectionResult(),
              ],

              // Recipe Results
              if (_suggestedRecipes != null && _suggestedRecipes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Recipe Suggestions (${_suggestedRecipes!.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestedRecipes!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RecipeCard(recipe: _suggestedRecipes![index]),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Image Selected',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to select or capture\na food image for AI identification',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
          ),
        ),
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '🤖 Gemini AI is analyzing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'This may take a few seconds',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetectionResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.teal.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Food Detected!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                const Text(
                  '🍽️',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _detectedFood!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
