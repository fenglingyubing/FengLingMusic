import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_tray/system_tray.dart';

import 'system_tray_service.dart';
import 'hotkey_service.dart';
import 'window_service.dart';
import 'screen_service.dart';

/// Windows platform manager
/// Integrates all Windows-specific features: system tray, hotkeys, window management, etc.
class WindowsPlatformManager {
  final SystemTrayService _systemTrayService;
  final HotkeyService _hotkeyService;
  final WindowService _windowService;
  final ScreenService _screenService;

  bool _isInitialized = false;

  WindowsPlatformManager({
    required SystemTrayService systemTrayService,
    required HotkeyService hotkeyService,
    required WindowService windowService,
    required ScreenService screenService,
  })  : _systemTrayService = systemTrayService,
        _hotkeyService = hotkeyService,
        _windowService = windowService,
        _screenService = screenService;

  /// Initialize all Windows platform features
  Future<void> initialize({
    required BuildContext context,
    String? appTitle,
    VoidCallback? onPlayPause,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
    VoidCallback? onExit,
  }) async {
    if (!Platform.isWindows) {
      debugPrint('WindowsPlatformManager: Not on Windows platform');
      return;
    }

    try {
      // 1. Initialize window service
      await _windowService.initialize(
        title: appTitle ?? 'FengLing Music',
        minimumSize: const Size(800, 600),
        initialSize: const Size(1200, 800),
        minimizeToTray: true,
      );

      // 2. Initialize screen service for high refresh rate detection
      await _screenService.initialize();

      // 3. Initialize system tray
      await _initializeSystemTray(
        onPlayPause: onPlayPause,
        onNext: onNext,
        onPrevious: onPrevious,
        onExit: onExit,
      );

      // 4. Initialize global hotkeys
      await _initializeHotkeys(
        onPlayPause: onPlayPause,
        onNext: onNext,
        onPrevious: onPrevious,
      );

      _isInitialized = true;
      debugPrint('WindowsPlatformManager: All features initialized successfully');
    } catch (e) {
      debugPrint('WindowsPlatformManager: Failed to initialize - $e');
    }
  }

  /// Initialize system tray with menu items
  Future<void> _initializeSystemTray({
    VoidCallback? onPlayPause,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
    VoidCallback? onExit,
  }) async {
    // Create default tray icon (you should replace with actual icon path)
    const iconPath = 'assets/icons/tray_icon.ico';

    final menuItems = <TrayMenuItem>[
      MenuItem(
        label: 'Show Window',
        onClicked: (_) => _windowService.show(),
      ),
      MenuSeparator(),
      MenuItem(
        label: 'Play/Pause',
        onClicked: (_) => onPlayPause?.call(),
      ),
      MenuItem(
        label: 'Next Track',
        onClicked: (_) => onNext?.call(),
      ),
      MenuItem(
        label: 'Previous Track',
        onClicked: (_) => onPrevious?.call(),
      ),
      MenuSeparator(),
      MenuItem(
        label: 'Exit',
        onClicked: (_) => onExit?.call(),
      ),
    ];

    await _systemTrayService.initialize(
      iconPath: iconPath,
      tooltip: 'FengLing Music',
      menuItems: menuItems,
    );
  }

  /// Initialize global hotkeys
  Future<void> _initializeHotkeys({
    VoidCallback? onPlayPause,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
  }) async {
    await _hotkeyService.initialize();

    final callbacks = <HotkeyAction, VoidCallback>{};

    if (onPlayPause != null) {
      callbacks[HotkeyAction.playPause] = onPlayPause;
    }
    if (onNext != null) {
      callbacks[HotkeyAction.nextTrack] = onNext;
    }
    if (onPrevious != null) {
      callbacks[HotkeyAction.previousTrack] = onPrevious;
    }

    await _hotkeyService.registerDefaults(callbacks);
  }

  /// Update system tray tooltip (e.g., with current song info)
  Future<void> updateTrayTooltip(String tooltip) async {
    if (!_isInitialized) return;
    await _systemTrayService.updateTooltip(tooltip);
  }

  /// Update system tray menu
  Future<void> updateTrayMenu(List<TrayMenuItem> menuItems) async {
    if (!_isInitialized) return;
    await _systemTrayService.updateMenu(menuItems);
  }

  /// Show main window
  Future<void> showWindow() async {
    if (!_isInitialized) return;
    await _windowService.show();
  }

  /// Hide window to tray
  Future<void> hideWindow() async {
    if (!_isInitialized) return;
    await _windowService.hide();
  }

  /// Register a custom hotkey
  Future<bool> registerHotkey(HotkeyConfig config, VoidCallback callback) async {
    if (!_isInitialized) return false;
    return await _hotkeyService.registerHotkey(config, callback);
  }

  /// Unregister a hotkey
  Future<void> unregisterHotkey(HotkeyAction action) async {
    if (!_isInitialized) return;
    await _hotkeyService.unregisterHotkey(action);
  }

  /// Get current screen info
  ScreenInfo? get screenInfo => _screenService.currentScreenInfo;

  /// Get recommended frame rate
  int get recommendedFrameRate => _screenService.recommendedFrameRate;

  /// Check if screen supports high refresh rate
  bool get isHighRefreshRate => _screenService.isHighRefreshRate;

  /// Dispose all services
  Future<void> dispose() async {
    if (!_isInitialized) return;

    await _systemTrayService.destroy();
    await _hotkeyService.unregisterAll();
    _windowService.dispose();

    _isInitialized = false;
    debugPrint('WindowsPlatformManager: Disposed');
  }

  bool get isInitialized => _isInitialized;
}

/// Windows platform manager provider
final windowsPlatformManagerProvider = Provider<WindowsPlatformManager>((ref) {
  final systemTrayService = ref.watch(systemTrayServiceProvider);
  final hotkeyService = ref.watch(hotkeyServiceProvider);
  final windowService = ref.watch(windowServiceProvider);
  final screenService = ref.watch(screenServiceProvider);

  final manager = WindowsPlatformManager(
    systemTrayService: systemTrayService,
    hotkeyService: hotkeyService,
    windowService: windowService,
    screenService: screenService,
  );

  ref.onDispose(() => manager.dispose());

  return manager;
});
