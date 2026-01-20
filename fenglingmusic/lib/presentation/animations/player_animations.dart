import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/animation_constants.dart';
import '../../core/animation/refresh_rate_detector.dart';

/// Advanced player animations optimized for 120fps
/// Features: Play/pause morphing, vinyl rotation, song transitions
class PlayerAnimations {
  PlayerAnimations._();

  /// Play/Pause button morph animation
  static Widget playPauseButton({
    required bool isPlaying,
    required VoidCallback onTap,
    double size = 48.0,
    Color? color,
  }) {
    return _PlayPauseButton(
      isPlaying: isPlaying,
      onTap: onTap,
      size: size,
      color: color,
    );
  }

  /// Rotating vinyl/album cover
  static Widget rotatingAlbum({
    required Widget child,
    required bool isPlaying,
    double size = 200.0,
  }) {
    return _RotatingAlbum(
      isPlaying: isPlaying,
      size: size,
      child: child,
    );
  }

  /// Song transition animation (crossfade with slide)
  static Widget songTransition({
    required Widget child,
    required String songId,
    Duration? duration,
  }) {
    return AnimatedSwitcher(
      duration: duration ??
          RefreshRateDetector.instance.getRecommendedDuration(
            AnimationConstants.mediumDuration,
          ),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Container(
        key: ValueKey(songId),
        child: child,
      ),
    );
  }
}

/// Custom Play/Pause button with morphing animation
class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
    required this.size,
    this.color,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: RefreshRateDetector.instance.getRecommendedDuration(
        AnimationConstants.playPauseAnimationDuration,
      ),
      vsync: this,
    );

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handleTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.92 : 1.0,
            child: Container(
              width: widget.size + 24,
              height: widget.size + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.0),
                  ],
                ),
              ),
              child: Center(
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _iconAnimation,
                  size: widget.size,
                  color: color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rotating vinyl/album cover widget
class _RotatingAlbum extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final double size;

  const _RotatingAlbum({
    required this.child,
    required this.isPlaying,
    required this.size,
  });

  @override
  State<_RotatingAlbum> createState() => _RotatingAlbumState();
}

class _RotatingAlbumState extends State<_RotatingAlbum>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // Create a continuous rotation animation
    _rotationController = AnimationController(
      duration: Duration(
        milliseconds: AnimationConstants.albumCoverRotationDuration,
      ),
      vsync: this,
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(_RotatingAlbum oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        // Resume rotation from current position
        _rotationController.repeat();
      } else {
        // Pause rotation
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                children: [
                  // Album cover
                  widget.child,

                  // Vinyl grooves effect (subtle radial gradient)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Center hole (like a vinyl record)
                  Center(
                    child: Container(
                      width: widget.size * 0.15,
                      height: widget.size * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                        border: Border.all(
                          color: Colors.white24,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Progress bar reset animation
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.activeColor,
    this.inactiveColor,
    this.height = 4.0,
    this.borderRadius,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _resetController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _resetAnimation = Tween<double>(
      begin: _previousProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    ));

    _previousProgress = widget.progress;
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect reset (new song)
    if (widget.progress < _previousProgress &&
        widget.progress < 0.1 &&
        _previousProgress > 0.5) {
      _resetAnimation = Tween<double>(
        begin: _previousProgress,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeInOut,
      ));
      _resetController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _previousProgress = widget.progress;
          });
        }
      });
    } else {
      _previousProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ??
        theme.colorScheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _resetController,
          builder: (context, child) {
            final progress = _resetController.isAnimating
                ? _resetAnimation.value
                : widget.progress;

            return LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: inactiveColor,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            );
          },
        ),
      ),
    );
  }
}

/// Album cover transition with scale and fade
class AlbumCoverTransition extends StatelessWidget {
  final Widget child;
  final String albumId;
  final double size;

  const AlbumCoverTransition({
    super.key,
    required this.child,
    required this.albumId,
    this.size = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final scaleAnimation = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(albumId),
        width: size,
        height: size,
        child: child,
      ),
    );
  }
}

/// Pulsing equalizer bars for playing indicator
class PulsingEqualizer extends StatefulWidget {
  final bool isPlaying;
  final Color? color;
  final double size;
  final int barCount;

  const PulsingEqualizer({
    super.key,
    required this.isPlaying,
    this.color,
    this.size = 24.0,
    this.barCount = 3,
  });

  @override
  State<PulsingEqualizer> createState() => _PulsingEqualizerState();
}

class _PulsingEqualizerState extends State<PulsingEqualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.value = 0.3;
    }
  }

  @override
  void didUpdateWidget(PulsingEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: widget.size / (widget.barCount * 2),
                height: widget.size * _animations[index].value,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
