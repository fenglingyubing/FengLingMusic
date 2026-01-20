import 'dart:async';
import 'dart:ui';

import 'package:flutter/scheduler.dart';

import '../constants/animation_constants.dart';

/// Detects and manages display refresh rate for optimal animation performance
class RefreshRateDetector {
  RefreshRateDetector._();

  static final RefreshRateDetector instance = RefreshRateDetector._();

  /// Current detected refresh rate in Hz
  double _currentRefreshRate = AnimationConstants.defaultRefreshRate.toDouble();

  /// Whether high refresh rate is available
  bool _isHighRefreshRateAvailable = false;

  /// Whether refresh rate detection is complete
  bool _isDetectionComplete = false;

  /// Stream controller for refresh rate changes
  final StreamController<double> _refreshRateController = StreamController<double>.broadcast();

  /// Performance metrics
  final List<double> _fpsHistory = [];
  static const int _fpsHistoryMaxSize = 60; // Keep 1 second of history at 60fps

  /// Performance monitoring
  bool _isMonitoring = false;
  DateTime? _lastFrameTime;
  int _frameCount = 0;
  double _currentFps = 0.0;

  /// Get current refresh rate
  double get refreshRate => _currentRefreshRate;

  /// Get whether high refresh rate is available
  bool get isHighRefreshRateAvailable => _isHighRefreshRateAvailable;

  /// Get whether detection is complete
  bool get isDetectionComplete => _isDetectionComplete;

  /// Get current FPS
  double get currentFps => _currentFps;

  /// Get average FPS from history
  double get averageFps {
    if (_fpsHistory.isEmpty) return 0.0;
    return _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
  }

  /// Stream of refresh rate changes
  Stream<double> get refreshRateStream => _refreshRateController.stream;

  /// Initialize and detect refresh rate
  Future<void> detectRefreshRate() async {
    if (_isDetectionComplete) return;

    try {
      // Get the display refresh rate from Flutter's window
      final display = PlatformDispatcher.instance.displays.first;
      _currentRefreshRate = display.refreshRate;

      // Check if high refresh rate is available
      _isHighRefreshRateAvailable = _currentRefreshRate >= AnimationConstants.highRefreshRate;

      _isDetectionComplete = true;

      // Notify listeners
      _refreshRateController.add(_currentRefreshRate);

      print('[RefreshRateDetector] Detected refresh rate: ${_currentRefreshRate}Hz');
      print('[RefreshRateDetector] High refresh rate available: $_isHighRefreshRateAvailable');
    } catch (e) {
      // Fallback to default if detection fails
      _currentRefreshRate = AnimationConstants.defaultRefreshRate.toDouble();
      _isHighRefreshRateAvailable = false;
      _isDetectionComplete = true;

      print('[RefreshRateDetector] Failed to detect refresh rate: $e');
      print('[RefreshRateDetector] Using default: ${_currentRefreshRate}Hz');
    }
  }

  /// Get optimal frame duration for current refresh rate
  Duration getOptimalFrameDuration() {
    final microseconds = (1000000 / _currentRefreshRate).round();
    return Duration(microseconds: microseconds);
  }

  /// Get target FPS based on detected refresh rate
  double getTargetFps() {
    if (!_isDetectionComplete) {
      return AnimationConstants.defaultRefreshRate.toDouble();
    }

    // Return the detected refresh rate as target FPS
    return _currentRefreshRate;
  }

  /// Check if current performance meets the target
  bool isPerformanceAcceptable() {
    if (_fpsHistory.isEmpty) return true;

    final avgFps = averageFps;
    final targetFps = getTargetFps();

    // Allow 5% deviation from target
    final minAcceptable = targetFps * 0.95;

    return avgFps >= minAcceptable;
  }

  /// Start performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _lastFrameTime = DateTime.now();
    _frameCount = 0;
    _fpsHistory.clear();

    // Schedule frame callback
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

    print('[RefreshRateDetector] Performance monitoring started');
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _lastFrameTime = null;
    _frameCount = 0;

    print('[RefreshRateDetector] Performance monitoring stopped');
    print('[RefreshRateDetector] Average FPS: ${averageFps.toStringAsFixed(2)}');
  }

  /// Frame callback for performance monitoring
  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final elapsed = now.difference(_lastFrameTime!);
      _frameCount++;

      // Calculate FPS every second
      if (elapsed.inMilliseconds >= 1000) {
        _currentFps = _frameCount / (elapsed.inMilliseconds / 1000);

        // Add to history
        _fpsHistory.add(_currentFps);
        if (_fpsHistory.length > _fpsHistoryMaxSize) {
          _fpsHistory.removeAt(0);
        }

        // Reset for next measurement
        _frameCount = 0;
        _lastFrameTime = now;

        // Check if performance is degrading
        if (!isPerformanceAcceptable()) {
          print('[RefreshRateDetector] Warning: FPS below target (${_currentFps.toStringAsFixed(2)} < ${getTargetFps().toStringAsFixed(2)})');
        }
      }
    } else {
      _lastFrameTime = now;
    }
  }

  /// Get recommended animation duration based on refresh rate
  Duration getRecommendedDuration(int baseDurationMs) {
    // Adjust duration to be a multiple of frame duration
    final frameDuration = getOptimalFrameDuration();
    final frames = (baseDurationMs * 1000 / frameDuration.inMicroseconds).round();
    return Duration(microseconds: frames * frameDuration.inMicroseconds);
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _refreshRateController.close();
    _fpsHistory.clear();
  }
}
