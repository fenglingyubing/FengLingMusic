import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/animation_constants.dart';
import '../../core/animation/refresh_rate_detector.dart';

/// Micro-interaction animations optimized for 120fps
/// Features: Button feedback, haptic feedback, favorite animations
class MicroInteractions {
  MicroInteractions._();

  /// Haptic feedback helper
  static Future<void> _triggerHaptic(HapticFeedbackType type) async {
    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }

  /// Ripple button with scale feedback
  static Widget rippleButton({
    required Widget child,
    required VoidCallback onTap,
    HapticFeedbackType hapticFeedback = HapticFeedbackType.light,
    Color? rippleColor,
    BorderRadius? borderRadius,
    bool enableHaptic = true,
  }) {
    return _RippleButton(
      onTap: onTap,
      hapticFeedback: hapticFeedback,
      rippleColor: rippleColor,
      borderRadius: borderRadius,
      enableHaptic: enableHaptic,
      child: child,
    );
  }

  /// Bouncing button with elastic effect
  static Widget bouncingButton({
    required Widget child,
    required VoidCallback onTap,
    HapticFeedbackType hapticFeedback = HapticFeedbackType.medium,
    double scale = 0.92,
    bool enableHaptic = true,
  }) {
    return _BouncingButton(
      onTap: onTap,
      hapticFeedback: hapticFeedback,
      scale: scale,
      enableHaptic: enableHaptic,
      child: child,
    );
  }

  /// Enhanced favorite button with heart animation
  static Widget favoriteButton({
    required bool isFavorite,
    required VoidCallback onToggle,
    double size = 32.0,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return _EnhancedFavoriteButton(
      isFavorite: isFavorite,
      onToggle: onToggle,
      size: size,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

/// Ripple button with scale feedback
class _RippleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final HapticFeedbackType hapticFeedback;
  final Color? rippleColor;
  final BorderRadius? borderRadius;
  final bool enableHaptic;

  const _RippleButton({
    required this.child,
    required this.onTap,
    required this.hapticFeedback,
    this.rippleColor,
    this.borderRadius,
    required this.enableHaptic,
  });

  @override
  State<_RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<_RippleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.enableHaptic) {
      await MicroInteractions._triggerHaptic(widget.hapticFeedback);
    }
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            child: InkWell(
              onTap: _handleTap,
              splashColor: widget.rippleColor ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              highlightColor: widget.rippleColor ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Bouncing button with elastic effect
class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final HapticFeedbackType hapticFeedback;
  final double scale;
  final bool enableHaptic;

  const _BouncingButton({
    required this.child,
    required this.onTap,
    required this.hapticFeedback,
    required this.scale,
    required this.enableHaptic,
  });

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: widget.scale),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.scale, end: 1.02),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.enableHaptic) {
      await MicroInteractions._triggerHaptic(widget.hapticFeedback);
    }
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Enhanced favorite button with complex animations
class _EnhancedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const _EnhancedFavoriteButton({
    required this.isFavorite,
    required this.onToggle,
    required this.size,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<_EnhancedFavoriteButton> createState() =>
      _EnhancedFavoriteButtonState();
}

class _EnhancedFavoriteButtonState extends State<_EnhancedFavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Main scale animation with bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_mainController);

    // Rotate animation
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOutBack,
    ));

    // Glow animation
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 50,
      ),
    ]).animate(_mainController);

    // Initialize particles
    _generateParticles();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 8; i++) {
      _particles.add(_Particle(
        angle: (i * 45.0) * (3.14159 / 180.0),
        size: 4.0 + (i % 2) * 2.0,
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_EnhancedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite && widget.isFavorite) {
      _mainController.forward(from: 0);
      _particleController.forward(from: 0);
    }
  }

  void _handleTap() async {
    await HapticFeedback.mediumImpact();

    if (!widget.isFavorite) {
      _mainController.forward(from: 0);
      _particleController.forward(from: 0);
    }

    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? const Color(0xFFD4AF37); // Golden
    final inactiveColor =
        widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size + 32,
        height: widget.size + 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particles
            if (widget.isFavorite)
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(widget.size + 32, widget.size + 32),
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: _particleController.value,
                      color: activeColor,
                    ),
                  );
                },
              ),

            // Main heart icon
            AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value *
                        (widget.isFavorite ? 1 : -1),
                    child: Container(
                      width: widget.size + 24,
                      height: widget.size + 24,
                      decoration: widget.isFavorite
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor
                                      .withOpacity(0.4 * _glowAnimation.value),
                                  blurRadius: 20 * _glowAnimation.value,
                                  spreadRadius: 5 * _glowAnimation.value,
                                ),
                              ],
                            )
                          : null,
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: widget.size,
                        color: widget.isFavorite ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      )
          .animate(
            target: widget.isFavorite ? 1 : 0,
          )
          .shimmer(
            duration: 1200.ms,
            color: activeColor.withOpacity(0.3),
            angle: 45,
          ),
    );
  }
}

/// Particle for favorite animation
class _Particle {
  final double angle;
  final double size;

  _Particle({
    required this.angle,
    required this.size,
  });
}

/// Particle painter for favorite animation
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxDistance = size.width * 0.4;

    for (var particle in particles) {
      final distance = maxDistance * progress;
      final x = center.dx + (distance * Math.cos(particle.angle));
      final y = center.dy + (distance * Math.sin(particle.angle));

      final particleSize = particle.size * (1.0 - progress);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Math utilities for particle calculations
class Math {
  static double cos(double radians) =>
      (radians == 0) ? 1.0 : _cosTable[(radians * 100).round() % 628];

  static double sin(double radians) =>
      (radians == 0) ? 0.0 : _sinTable[(radians * 100).round() % 628];

  // Pre-computed sin/cos tables for performance
  static final List<double> _cosTable = List.generate(
    628,
    (i) => dart_math.cos(i / 100.0),
  );

  static final List<double> _sinTable = List.generate(
    628,
    (i) => dart_math.sin(i / 100.0),
  );
}

import 'dart:math' as dart_math;

/// Long press button with growing circle feedback
class LongPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;
  final Duration duration;
  final Color? progressColor;

  const LongPressButton({
    super.key,
    required this.child,
    required this.onLongPress,
    this.duration = const Duration(milliseconds: 500),
    this.progressColor,
  });

  @override
  State<LongPressButton> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onLongPress();
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressStart() {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _handlePressEnd() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor =
        widget.progressColor ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onLongPressStart: (_) => _handlePressStart(),
      onLongPressEnd: (_) => _handlePressEnd(),
      onLongPressCancel: _handlePressEnd,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _CircleProgressPainter(
                  progress: _controller.value,
                  color: progressColor,
                ),
                child: widget.child,
              );
            },
          ),

          // Child
          widget.child,
        ],
      ),
    );
  }
}

/// Circle progress painter for long press
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) + 8;

    final sweepAngle = 2 * dart_math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -dart_math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
