import 'package:flutter/material.dart';
import '../animations/micro_interactions.dart';

/// Retro Vinyl-styled Favorite Button with Animations
/// Features a golden heart that pulses, rotates, and bounces on toggle
/// Now uses enhanced micro-interactions for 120fps performance
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 32.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return MicroInteractions.favoriteButton(
      isFavorite: isFavorite,
      onToggle: onToggle,
      size: size,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}

/// Animated Favorite Icon for List Items
/// Simpler version for song tiles
class FavoriteIcon extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;

  const FavoriteIcon({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FavoriteButton(
        isFavorite: isFavorite,
        onToggle: onToggle,
        size: size,
      ),
      onPressed: onToggle,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: size + 16,
        minHeight: size + 16,
      ),
    );
  }
}
