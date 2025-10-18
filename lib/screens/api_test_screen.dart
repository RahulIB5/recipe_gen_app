import 'package:flutter/material.dart';
import '../services/spoonacular_service.dart';
import '../config/api_config.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing...';
    });

    try {
      // Check if API key is configured
      if (!SpoonacularService.isApiKeyConfigured) {
        setState(() {
          _status =
              '❌ API Key not configured.\nPlease add your Spoonacular API key to lib/config/api_config.dart';
          _isLoading = false;
        });
        return;
      }

      // Test API call
      final recipes = await SpoonacularService.getRandomRecipes(number: 1);

      setState(() {
        if (recipes.isNotEmpty) {
          _status =
              '✅ API Connection Successful!\nReceived recipe: ${recipes.first.title}';
        } else {
          _status = '⚠️ API responded but no recipes found';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status =
            '❌ API Error: $e\n\nPossible issues:\n• Invalid API key\n• Network connection\n• Daily quota exceeded (150 requests)';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spoonacular API Configuration',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            SpoonacularService.isApiKeyConfigured
                                ? Icons.check_circle
                                : Icons.warning,
                            color: SpoonacularService.isApiKeyConfigured
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            SpoonacularService.isApiKeyConfigured
                                ? 'API Key Configured'
                                : 'API Key Needed',
                            style: TextStyle(
                              color: SpoonacularService.isApiKeyConfigured
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            ApiConfig.useFallbackData
                                ? Icons.offline_pin
                                : Icons.cloud,
                            color: ApiConfig.useFallbackData
                                ? Colors.grey
                                : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ApiConfig.useFallbackData
                                ? 'Using Local Data'
                                : 'Using API Data',
                            style: TextStyle(
                              color: ApiConfig.useFallbackData
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Instructions',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '1. Go to spoonacular.com/food-api\n'
                        '2. Sign up for free account\n'
                        '3. Copy your API key\n'
                        '4. Edit lib/config/api_config.dart\n'
                        '5. Replace "YOUR_ACTUAL_API_KEY_HERE" with real key\n'
                        '6. Restart the app',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testApiConnection,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? 'Testing...' : 'Test API Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(_status, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
