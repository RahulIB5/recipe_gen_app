import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';

/// A heart-shaped favorite button that toggles recipe favorite status
class FavoriteButton extends StatefulWidget {
  final Recipe recipe;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final VoidCallback? onToggle;

  const FavoriteButton({
    super.key,
    required this.recipe,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
    this.size = 24.0,
    this.onToggle,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load the current favorite status from Firestore
  Future<void> _loadFavoriteStatus() async {
    try {
      final isFav = await FavoritesService.isFavorite(widget.recipe.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      // Silently handle error - default to not favorite
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
    }
  }

  /// Toggle favorite status with animation
  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Animate the heart
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Toggle favorite status in Firestore
      final newFavoriteStatus = await FavoritesService.toggleFavorite(widget.recipe);
      
      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteStatus;
          _isLoading = false;
        });

        // Show feedback to user
        final message = newFavoriteStatus 
            ? 'Added to favorites!' 
            : 'Removed from favorites';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Call callback if provided
        widget.onToggle?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.activeColor ?? Colors.red,
                        ),
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite 
                          ? widget.activeColor 
                          : widget.inactiveColor,
                      size: widget.size,
                    ),
            ),
          );
        },
      ),
    );
  }
}