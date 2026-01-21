import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Window management service for Windows platform
/// Handles window minimize to tray, focus, visibility, etc.
class WindowService with WindowListener {
  bool _isInitialized = false;
  bool _minimizeToTray = true;
  VoidCallback? _onClose;
  VoidCallback? _onMinimize;
  VoidCallback? _onRestore;

  /// Initialize window manager
  Future<void> initialize({
    Size? minimumSize,
    Size? initialSize,
    String? title,
    bool minimizeToTray = true,
    VoidCallback? onClose,
    VoidCallback? onMinimize,
    VoidCallback? onRestore,
  }) async {
    if (!Platform.isWindows) {
      debugPrint('WindowService: Not on Windows platform, skipping initialization');
      return;
    }

    try {
      await windowManager.ensureInitialized();

      _minimizeToTray = minimizeToTray;
      _onClose = onClose;
      _onMinimize = onMinimize;
      _onRestore = onRestore;

      final windowOptions = WindowOptions(
        size: initialSize,
        minimumSize: minimumSize ?? const Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: title,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      // Add window listener
      windowManager.addListener(this);

      _isInitialized = true;
      debugPrint('WindowService: Initialized successfully');
    } catch (e) {
      debugPrint('WindowService: Failed to initialize - $e');
    }
  }

  /// Show window
  Future<void> show() async {
    if (!_isInitialized) return;

    try {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.restore();
    } catch (e) {
      debugPrint('WindowService: Failed to show window - $e');
    }
  }

  /// Hide window
  Future<void> hide() async {
    if (!_isInitialized) return;

    try {
      await windowManager.hide();
    } catch (e) {
      debugPrint('WindowService: Failed to hide window - $e');
    }
  }

  /// Minimize window
  Future<void> minimize() async {
    if (!_isInitialized) return;

    try {
      if (_minimizeToTray) {
        await hide();
      } else {
        await windowManager.minimize();
      }
    } catch (e) {
      debugPrint('WindowService: Failed to minimize window - $e');
    }
  }

  /// Maximize window
  Future<void> maximize() async {
    if (!_isInitialized) return;

    try {
      await windowManager.maximize();
    } catch (e) {
      debugPrint('WindowService: Failed to maximize window - $e');
    }
  }

  /// Restore window
  Future<void> restore() async {
    if (!_isInitialized) return;

    try {
      await windowManager.restore();
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      debugPrint('WindowService: Failed to restore window - $e');
    }
  }

  /// Check if window is visible
  Future<bool> isVisible() async {
    if (!_isInitialized) return false;

    try {
      return await windowManager.isVisible();
    } catch (e) {
      debugPrint('WindowService: Failed to check visibility - $e');
      return false;
    }
  }

  /// Check if window is minimized
  Future<bool> isMinimized() async {
    if (!_isInitialized) return false;

    try {
      return await windowManager.isMinimized();
    } catch (e) {
      debugPrint('WindowService: Failed to check if minimized - $e');
      return false;
    }
  }

  /// Check if window is maximized
  Future<bool> isMaximized() async {
    if (!_isInitialized) return false;

    try {
      return await windowManager.isMaximized();
    } catch (e) {
      debugPrint('WindowService: Failed to check if maximized - $e');
      return false;
    }
  }

  /// Set window title
  Future<void> setTitle(String title) async {
    if (!_isInitialized) return;

    try {
      await windowManager.setTitle(title);
    } catch (e) {
      debugPrint('WindowService: Failed to set title - $e');
    }
  }

  /// Set minimize to tray behavior
  void setMinimizeToTray(bool value) {
    _minimizeToTray = value;
  }

  /// Get minimize to tray behavior
  bool get minimizeToTray => _minimizeToTray;

  // WindowListener overrides

  @override
  void onWindowClose() {
    debugPrint('WindowService: Window close requested');
    if (_minimizeToTray) {
      hide();
    } else {
      _onClose?.call();
    }
  }

  @override
  void onWindowMinimize() {
    debugPrint('WindowService: Window minimized');
    _onMinimize?.call();
  }

  @override
  void onWindowRestore() {
    debugPrint('WindowService: Window restored');
    _onRestore?.call();
  }

  @override
  void onWindowFocus() {
    debugPrint('WindowService: Window focused');
  }

  @override
  void onWindowBlur() {
    debugPrint('WindowService: Window blurred');
  }

  @override
  void onWindowMaximize() {
    debugPrint('WindowService: Window maximized');
  }

  @override
  void onWindowUnmaximize() {
    debugPrint('WindowService: Window unmaximized');
  }

  @override
  void onWindowMove() {
    // Window moved
  }

  @override
  void onWindowResize() {
    // Window resized
  }

  @override
  void onWindowEnterFullScreen() {
    debugPrint('WindowService: Window entered fullscreen');
  }

  @override
  void onWindowLeaveFullScreen() {
    debugPrint('WindowService: Window left fullscreen');
  }

  /// Dispose window service
  void dispose() {
    if (_isInitialized) {
      windowManager.removeListener(this);
      _isInitialized = false;
      debugPrint('WindowService: Disposed');
    }
  }

  bool get isInitialized => _isInitialized;
}

/// Window service provider
final windowServiceProvider = Provider<WindowService>((ref) {
  final service = WindowService();
  ref.onDispose(() => service.dispose());
  return service;
});
