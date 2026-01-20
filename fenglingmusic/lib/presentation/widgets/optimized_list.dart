import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/animation_constants.dart';
import '../../core/animation/refresh_rate_detector.dart';

/// Optimized scroll physics for 120fps smooth scrolling
class HighRefreshRateScrollPhysics extends ScrollPhysics {
  const HighRefreshRateScrollPhysics({super.parent});

  @override
  HighRefreshRateScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HighRefreshRateScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription(
        mass: 0.5,
        stiffness: AnimationConstants.scrollSpringConstant,
        damping: AnimationConstants.scrollDampingRatio,
      );

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;

  @override
  Tolerance get tolerance => Tolerance(
        velocity: 1.0 / (0.050 * PlatformDispatcher.instance.views.first.devicePixelRatio),
        distance: 1.0 / PlatformDispatcher.instance.views.first.devicePixelRatio,
      );
}

/// Optimized list view builder with RepaintBoundary
class OptimizedListView extends StatelessWidget {
  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.cacheExtent,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final double? cacheExtent;

  @override
  Widget build(BuildContext context) {
    final scrollPhysics = physics ?? const HighRefreshRateScrollPhysics();

    if (separatorBuilder != null) {
      return ListView.separated(
        controller: scrollController,
        physics: scrollPhysics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        cacheExtent: cacheExtent ?? _getOptimalCacheExtent(),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildOptimizedItem(context, index),
        separatorBuilder: separatorBuilder!,
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: scrollPhysics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent ?? _getOptimalCacheExtent(),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildOptimizedItem(context, index),
    );
  }

  Widget _buildOptimizedItem(BuildContext context, int index) {
    Widget item = itemBuilder(context, index);

    // Add RepaintBoundary to isolate repaints
    if (addRepaintBoundaries) {
      item = RepaintBoundary(child: item);
    }

    return item;
  }

  double _getOptimalCacheExtent() {
    // Calculate optimal cache extent based on screen size and refresh rate
    final view = PlatformDispatcher.instance.views.first;
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;

    // Cache 2 screens worth of content for smooth scrolling
    return screenHeight * 2;
  }
}

/// Optimized grid view with RepaintBoundary
class OptimizedGridView extends StatelessWidget {
  const OptimizedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.addRepaintBoundaries = true,
    this.cacheExtent,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool addRepaintBoundaries;
  final double? cacheExtent;

  @override
  Widget build(BuildContext context) {
    final scrollPhysics = physics ?? const HighRefreshRateScrollPhysics();

    return GridView.builder(
      controller: scrollController,
      physics: scrollPhysics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent ?? _getOptimalCacheExtent(),
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildOptimizedItem(context, index),
    );
  }

  Widget _buildOptimizedItem(BuildContext context, int index) {
    Widget item = itemBuilder(context, index);

    // Add RepaintBoundary to isolate repaints
    if (addRepaintBoundaries) {
      item = RepaintBoundary(child: item);
    }

    return item;
  }

  double _getOptimalCacheExtent() {
    final view = PlatformDispatcher.instance.views.first;
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    return screenHeight * 2;
  }
}

/// Scroll controller with performance monitoring
class PerformanceMonitoringScrollController extends ScrollController {
  PerformanceMonitoringScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  final RefreshRateDetector _detector = RefreshRateDetector.instance;
  bool _isMonitoring = false;

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    _startMonitoring();
  }

  @override
  void detach(ScrollPosition position) {
    _stopMonitoring();
    super.detach(position);
  }

  void _startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _detector.startMonitoring();
  }

  void _stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    _detector.stopMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }
}

/// Widget for optimizing list item rendering
class OptimizedListItem extends StatelessWidget {
  const OptimizedListItem({
    super.key,
    required this.child,
    this.enableRepaintBoundary = true,
  });

  final Widget child;
  final bool enableRepaintBoundary;

  @override
  Widget build(BuildContext context) {
    if (enableRepaintBoundary) {
      return RepaintBoundary(child: child);
    }
    return child;
  }
}

/// Sliver list with optimizations
class OptimizedSliverList extends StatelessWidget {
  const OptimizedSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.addRepaintBoundaries = true,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool addRepaintBoundaries;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildOptimizedItem(context, index),
        childCount: itemCount,
        addRepaintBoundaries: addRepaintBoundaries,
        addAutomaticKeepAlives: false,
      ),
    );
  }

  Widget _buildOptimizedItem(BuildContext context, int index) {
    Widget item = itemBuilder(context, index);

    if (addRepaintBoundaries) {
      item = RepaintBoundary(child: item);
    }

    return item;
  }
}

/// Scroll behavior with high refresh rate support
class HighRefreshRateScrollBehavior extends ScrollBehavior {
  const HighRefreshRateScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const HighRefreshRateScrollPhysics();
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Use default scrollbar behavior
    return child;
  }
}

/// Extension methods for scroll optimization
extension ScrollOptimizationExtensions on BuildContext {
  /// Get optimal cache extent for current screen
  double getOptimalCacheExtent() {
    final screenHeight = MediaQuery.of(this).size.height;
    return screenHeight * 2;
  }

  /// Create optimized scroll controller
  PerformanceMonitoringScrollController createOptimizedScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  }) {
    return PerformanceMonitoringScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      debugLabel: debugLabel,
    );
  }
}
