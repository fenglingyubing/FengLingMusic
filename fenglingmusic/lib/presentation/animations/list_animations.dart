import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/animation_constants.dart';
import '../../core/animation/refresh_rate_detector.dart';

/// Advanced list animations optimized for 120fps
/// Features: Staggered entry, slide-out delete, smooth drag-to-reorder
class ListAnimations {
  ListAnimations._();

  /// Get optimized duration for current refresh rate
  static Duration _getOptimizedDuration(int baseMs) {
    return RefreshRateDetector.instance.getRecommendedDuration(baseMs);
  }

  /// Staggered list item enter animation
  /// Creates a waterfall effect with fade + slide from left
  static Widget staggeredEntry({
    required Widget child,
    required int index,
    int maxItems = 20,
    Duration? baseDuration,
    Duration? delay,
  }) {
    final effectiveDelay = delay ??
        Duration(
          milliseconds: (index * AnimationConstants.listItemAnimationDelay)
              .clamp(0, maxItems * AnimationConstants.listItemAnimationDelay),
        );

    final effectiveDuration = baseDuration ??
        _getOptimizedDuration(AnimationConstants.listItemAnimationDuration);

    return child
        .animate(
          delay: effectiveDelay,
        )
        .fadeIn(
          duration: effectiveDuration,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: -0.1,
          end: 0,
          duration: effectiveDuration,
          curve: Curves.easeOutCubic,
        )
        .shimmer(
          delay: effectiveDelay,
          duration: 600.ms,
          color: Colors.white.withOpacity(0.1),
        );
  }

  /// Slide-out delete animation
  /// Slides item to the right while fading out
  static Widget deleteSlideOut({
    required Widget child,
    required Animation<double> animation,
    VoidCallback? onComplete,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.2, 0),
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    final scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      ),
    );
  }
}

/// Animated list item widget with staggered entry
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final bool animate;
  final Duration? delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.animate = true,
    this.delay,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: RefreshRateDetector.instance.getRecommendedDuration(
        AnimationConstants.listItemAnimationDuration,
      ),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.animate) {
      final delay = widget.delay ??
          Duration(
            milliseconds: widget.index * AnimationConstants.listItemAnimationDelay,
          );
      Future.delayed(delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Drag-to-reorder wrapper with smooth animations
class DraggableListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Function(int, int)? onReorder;
  final bool isBeingDragged;

  const DraggableListItem({
    super.key,
    required this.child,
    required this.index,
    this.onDragStart,
    this.onDragEnd,
    this.onReorder,
    this.isBeingDragged = false,
  });

  @override
  State<DraggableListItem> createState() => _DraggableListItemState();
}

class _DraggableListItemState extends State<DraggableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(DraggableListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBeingDragged != oldWidget.isBeingDragged) {
      if (widget.isBeingDragged) {
        _elevationController.forward();
      } else {
        _elevationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _elevationController.dispose();
    super.dispose();
  }

  void _handleDragStart() {
    setState(() => _isDragging = true);
    _elevationController.forward();
    widget.onDragStart?.call();
  }

  void _handleDragEnd() {
    setState(() => _isDragging = false);
    _elevationController.reverse();
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            elevation: _elevationAnimation.value,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: GestureDetector(
              onLongPressStart: (_) => _handleDragStart(),
              onLongPressEnd: (_) => _handleDragEnd(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isDragging
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Colors.transparent,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Smooth height transition for expanding/collapsing list items
class AnimatedHeightItem extends StatelessWidget {
  final Widget child;
  final bool isExpanded;
  final Duration? duration;

  const AnimatedHeightItem({
    super.key,
    required this.child,
    required this.isExpanded,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration ??
          RefreshRateDetector.instance.getRecommendedDuration(
            AnimationConstants.mediumDuration,
          ),
      curve: Curves.easeInOutCubic,
      child: isExpanded ? child : const SizedBox.shrink(),
    );
  }
}

/// Reorderable list with smooth transitions
class SmoothReorderableListView extends StatefulWidget {
  final List<Widget> children;
  final Function(int, int) onReorder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const SmoothReorderableListView({
    super.key,
    required this.children,
    required this.onReorder,
    this.padding,
    this.physics,
  });

  @override
  State<SmoothReorderableListView> createState() =>
      _SmoothReorderableListViewState();
}

class _SmoothReorderableListViewState extends State<SmoothReorderableListView> {
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      padding: widget.padding,
      physics: widget.physics,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          _draggingIndex = null;
        });
        widget.onReorder(oldIndex, newIndex);
      },
      onReorderStart: (index) {
        setState(() {
          _draggingIndex = index;
        });
      },
      onReorderEnd: (_) {
        setState(() {
          _draggingIndex = null;
        });
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(animation.value);
            final scale = 1.0 + (t * 0.05);
            final elevation = t * 8.0;

            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return DraggableListItem(
          key: ValueKey(index),
          index: index,
          isBeingDragged: _draggingIndex == index,
          child: child,
        );
      }).toList(),
    );
  }
}
