import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for Gemini AI food recognition
class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// List available Gemini models for debugging
  static Future<void> listAvailableModels() async {
    try {
      if (_apiKey.isEmpty) {
        print('❌ [Gemini] API key not configured');
        return;
      }

      print('🔍 [Gemini] Testing available models...');
      
      final testModels = [
        'gemini-pro-latest',
        'gemini-flash-latest',
        'gemini-2.5-pro',
        'gemini-2.0-flash',
      ];

      for (final modelName in testModels) {
        try {
          // ignore: unused_local_variable
          final model = GenerativeModel(
            model: modelName,
            apiKey: _apiKey,
          );
          print('✅ Model "$modelName" - initialized successfully');
        } catch (e) {
          print('❌ Model "$modelName" - error: $e');
        }
      }
    } catch (e) {
      print('❌ [Gemini] Error listing models: $e');
    }
  }

  /// Identify food from image using Gemini AI
  /// Returns the clean food name or throws an exception with error details
  static Future<String> identifyFoodFromImage(Uint8List imageBytes) async {
    try {
      print('🤖 [Gemini] Starting food identification...');
      print('📦 [Gemini] Image size: ${imageBytes.length} bytes');
      
      if (_apiKey.isEmpty) {
        print('❌ [Gemini] API key not configured');
        throw Exception('Gemini API key not found. Please add GEMINI_API_KEY to your .env file.');
      }

      print('🔑 [Gemini] API key found: ${_apiKey.substring(0, 10)}...');

      // Initialize Gemini model with safety settings
      // Using gemini-2.0-flash which supports multimodal (text + images)
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
      );

      print('🔄 [Gemini] Sending request to gemini-2.0-flash model...');

      // Create the prompt - more flexible to handle various food images
      const prompt = '''Look at this image and identify the food item.
If you see:
- Fruits: name the specific fruit (e.g., "apple", "banana", "orange")
- Vegetables: name the vegetable
- Prepared dishes: name the dish (e.g., "pizza", "burger", "pasta")
- Snacks or packaged foods: identify what it is

Return ONLY the name of the food item, nothing else. Be specific but concise.''';
      
      // Create content with image
      final imagePart = DataPart('image/jpeg', imageBytes);
      final content = [
        Content.multi([
          TextPart(prompt),
          imagePart,
        ])
      ];

      // Generate response
      final response = await model.generateContent(content);
      
      print('✅ [Gemini] Response received');
      print('📊 [Gemini] Candidates count: ${response.candidates.length}');
      
      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        print('🔍 [Gemini] Finish reason: ${candidate.finishReason}');
        print('🛡️ [Gemini] Safety ratings: ${candidate.safetyRatings?.map((r) => '${r.category}: ${r.probability}').join(', ')}');
      }
      
      print('📄 [Gemini] Raw response text: ${response.text}');

      if (response.text == null || response.text!.isEmpty) {
        print('⚠️ [Gemini] Empty response received');
        
        // Check if response was blocked
        if (response.candidates.isNotEmpty) {
          final candidate = response.candidates.first;
          if (candidate.finishReason == FinishReason.safety) {
            throw Exception('Gemini blocked the response due to safety settings. Try a different image.');
          }
        }
        
        throw Exception('Gemini returned an empty response. The image might not contain recognizable food.');
      }

      // Clean the food name
      String foodName = _cleanFoodName(response.text!);
      print('🍽️ [Gemini] Extracted food name: "$foodName"');

      return foodName;
    } catch (e) {
      print('❌ [Gemini] Error: $e');
      rethrow;
    }
  }

  /// Clean and normalize the food name from Gemini response
  static String _cleanFoodName(String rawText) {
    // Remove extra whitespace and newlines
    String cleaned = rawText.trim();
    
    // Remove common prefixes/suffixes that Gemini might add
    cleaned = cleaned.replaceAll(RegExp(r'^(The food (item )?is:?\s*)', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'^(This (is|appears to be):?\s*)', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'^(I see:?\s*)', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'^(It (is|looks like):?\s*)', caseSensitive: false), '');
    
    // Remove quotes if present
    cleaned = cleaned.replaceAll(RegExp(r'''^["']|["']$'''), '');
    
    // Remove trailing periods or punctuation
    cleaned = cleaned.replaceAll(RegExp(r'[.!?,]+$'), '');
    
    // If response has multiple lines, take the first non-empty line
    final lines = cleaned.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    if (lines.isNotEmpty) {
      cleaned = lines.first;
    }
    
    // Remove any remaining extra whitespace
    cleaned = cleaned.trim();
    
    // Capitalize first letter of each word for consistency
    cleaned = cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return cleaned;
  }
}
