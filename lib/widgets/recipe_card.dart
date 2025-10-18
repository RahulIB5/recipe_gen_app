import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../screens/recipe_detail_screen.dart';

// Custom widget for recipe cards in the carousel
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isLarge;

  const RecipeCard({super.key, required this.recipe, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                RecipeDetailScreen(recipe: recipe),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(
          1.0,
        ), // Even smaller margin for tighter grid
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), // Smaller border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4, // Minimal shadow
              offset: const Offset(0, 1), // Very small shadow offset
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8), // Match container radius
          child: AspectRatio(
            aspectRatio: 1.0, // Square shape (1:1 ratio)
            child: Stack(
              children: [
                // Full card background image with fallback
                Stack(
                  children: [
                    // Background image
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 40,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(
                                        0xFFB794F6,
                                      ) // Lighter purple for dark mode
                                    : Colors
                                          .grey[600], // Original for light mode
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Content overlay - positioned at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(
                      4,
                    ), // Even more minimal padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recipe.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLarge
                                ? 10
                                : 8, // Even smaller font sizes
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // Allow 2 lines for square cards
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1), // Minimal spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                  size: 8, // Even smaller icon
                                ),
                                const SizedBox(width: 1),
                                Text(
                                  '${recipe.cookingTime}m',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 6, // Even smaller font
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(recipe.difficulty),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                recipe
                                    .difficulty[0], // Just first letter (E/M/H)
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 6, // Even smaller font
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Loading widget with animation
class LoadingWidget extends StatefulWidget {
  final String message;

  const LoadingWidget({super.key, this.message = 'Loading...'});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _animation,
            child: Icon(
              Icons.restaurant,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFB794F6) // Lighter purple for dark mode
                  : Theme.of(
                      context,
                    ).primaryColor, // Original purple for light mode
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom chip widget for tags
class TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
