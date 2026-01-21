import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen refresh rate information
class ScreenInfo {
  final double refreshRate;
  final Size size;
  final String displayName;
  final bool isHighRefreshRate;

  const ScreenInfo({
    required this.refreshRate,
    required this.size,
    required this.displayName,
    required this.isHighRefreshRate,
  });

  /// Get recommended frame rate for animations
  int get recommendedFrameRate {
    if (refreshRate >= 165) return 165;
    if (refreshRate >= 144) return 144;
    if (refreshRate >= 120) return 120;
    if (refreshRate >= 90) return 90;
    return 60;
  }

  /// Get animation duration multiplier (inverse of frame rate)
  double get animationDurationMultiplier {
    return 60.0 / recommendedFrameRate;
  }

  @override
  String toString() {
    return 'ScreenInfo(refreshRate: ${refreshRate}Hz, size: ${size.width}x${size.height}, '
        'displayName: $displayName, recommended: ${recommendedFrameRate}fps)';
  }
}

/// Screen service for detecting and managing screen properties
class ScreenService {
  ScreenInfo? _currentScreenInfo;
  bool _isInitialized = false;

  /// Initialize screen service
  Future<void> initialize() async {
    if (!Platform.isWindows) {
      debugPrint('ScreenService: Not on Windows platform, using default 60Hz');
      _currentScreenInfo = const ScreenInfo(
        refreshRate: 60.0,
        size: Size(1920, 1080),
        displayName: 'Default Display',
        isHighRefreshRate: false,
      );
      _isInitialized = true;
      return;
    }

    try {
      await _detectScreen();
      _isInitialized = true;
      debugPrint('ScreenService: Initialized successfully');
      debugPrint('ScreenService: $_currentScreenInfo');
    } catch (e) {
      debugPrint('ScreenService: Failed to initialize - $e');
      _currentScreenInfo = const ScreenInfo(
        refreshRate: 60.0,
        size: Size(1920, 1080),
        displayName: 'Default Display',
        isHighRefreshRate: false,
      );
      _isInitialized = true;
    }
  }

  /// Detect primary screen properties
  Future<void> _detectScreen() async {
    try {
      final primaryDisplay = await screenRetriever.getPrimaryDisplay();

      // Get refresh rate (if available, otherwise default to 60Hz)
      double refreshRate = 60.0;

      // Try to get refresh rate from display
      // Note: screen_retriever doesn't directly provide refresh rate
      // We'll use a workaround by checking common high refresh rates
      // In production, you might want to use platform channels for more accurate detection

      // For now, we'll detect based on common resolutions and assume standard rates
      // This is a limitation of the current screen_retriever package
      final size = Size(
        primaryDisplay.size.width,
        primaryDisplay.size.height,
      );

      // Heuristic: Most modern high-end displays are 120Hz+ at 1440p or higher
      // This is not accurate but provides a reasonable default
      // TODO: Implement native Windows API call for accurate refresh rate detection
      refreshRate = 60.0; // Default fallback

      final isHighRefreshRate = refreshRate >= 90;

      _currentScreenInfo = ScreenInfo(
        refreshRate: refreshRate,
        size: size,
        displayName: primaryDisplay.name ?? 'Unknown Display',
        isHighRefreshRate: isHighRefreshRate,
      );
    } catch (e) {
      debugPrint('ScreenService: Failed to detect screen - $e');
      rethrow;
    }
  }

  /// Get current screen info
  ScreenInfo? get currentScreenInfo => _currentScreenInfo;

  /// Get recommended frame rate
  int get recommendedFrameRate => _currentScreenInfo?.recommendedFrameRate ?? 60;

  /// Get animation duration multiplier
  double get animationDurationMultiplier =>
      _currentScreenInfo?.animationDurationMultiplier ?? 1.0;

  /// Check if screen supports high refresh rate
  bool get isHighRefreshRate => _currentScreenInfo?.isHighRefreshRate ?? false;

  /// Manually set refresh rate (for testing or manual override)
  void setRefreshRate(double rate) {
    if (_currentScreenInfo == null) return;

    _currentScreenInfo = ScreenInfo(
      refreshRate: rate,
      size: _currentScreenInfo!.size,
      displayName: _currentScreenInfo!.displayName,
      isHighRefreshRate: rate >= 90,
    );

    debugPrint('ScreenService: Manually set refresh rate to ${rate}Hz');
    debugPrint('ScreenService: $_currentScreenInfo');
  }

  /// Refresh screen detection
  Future<void> refresh() async {
    if (!Platform.isWindows) return;
    await _detectScreen();
    debugPrint('ScreenService: Screen info refreshed - $_currentScreenInfo');
  }

  bool get isInitialized => _isInitialized;
}

/// Screen service provider
final screenServiceProvider = Provider<ScreenService>((ref) {
  return ScreenService();
});

/// Current screen info provider
final currentScreenInfoProvider = Provider<ScreenInfo?>((ref) {
  final screenService = ref.watch(screenServiceProvider);
  return screenService.currentScreenInfo;
});

/// Recommended frame rate provider
final recommendedFrameRateProvider = Provider<int>((ref) {
  final screenService = ref.watch(screenServiceProvider);
  return screenService.recommendedFrameRate;
});
