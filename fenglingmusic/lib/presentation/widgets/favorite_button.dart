import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Retro Vinyl-styled Favorite Button with Animations
/// Features a golden heart that pulses, rotates, and bounces on toggle
class FavoriteButton extends StatefulWidget {
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
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  void _handleTap() {
    setState(() => _isPressed = true);
    _controller.forward(from: 0).then((_) {
      setState(() => _isPressed = false);
    });
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? const Color(0xFFD4AF37); // Golden
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value * (widget.isFavorite ? 1 : -1),
              child: Container(
                width: widget.size + 16,
                height: widget.size + 16,
                decoration: widget.isFavorite
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            activeColor.withOpacity(0.2),
                            activeColor.withOpacity(0.0),
                          ],
                        ),
                      )
                    : null,
                child: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: widget.size,
                  color: widget.isFavorite ? activeColor : inactiveColor,
                )
                    .animate(
                      target: widget.isFavorite ? 1 : 0,
                    )
                    .shimmer(
                      duration: 1200.ms,
                      color: activeColor.withOpacity(0.4),
                      angle: 45,
                    ),
              ),
            ),
          );
        },
      ),
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
