import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System tray service for Windows platform
/// Provides system tray icon, tooltip, and context menu
class SystemTrayService {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  bool _isInitialized = false;

  /// Initialize system tray
  Future<void> initialize({
    required String iconPath,
    required String tooltip,
    required Menu menuItems,
  }) async {
    if (!Platform.isWindows) {
      debugPrint('SystemTray: Not on Windows platform, skipping initialization');
      return;
    }

    try {
      // Initialize tray icon
      await _systemTray.initSystemTray(
        title: tooltip,
        iconPath: iconPath,
        toolTip: tooltip,
      );

      // Set menu
      await _systemTray.setContextMenu(menuItems);

      // Register system tray event handlers
      _systemTray.registerSystemTrayEventHandler((eventName) {
        debugPrint('SystemTray: Event received: $eventName');

        if (eventName == kSystemTrayEventClick) {
          _handleTrayClick();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });

      _isInitialized = true;
      debugPrint('SystemTray: Initialized successfully');
    } catch (e) {
      debugPrint('SystemTray: Failed to initialize - $e');
    }
  }

  /// Update tray icon
  Future<void> updateIcon(String iconPath) async {
    if (!_isInitialized) return;

    try {
      await _systemTray.setImage(iconPath);
    } catch (e) {
      debugPrint('SystemTray: Failed to update icon - $e');
    }
  }

  /// Update tooltip
  Future<void> updateTooltip(String tooltip) async {
    if (!_isInitialized) return;

    try {
      await _systemTray.setToolTip(tooltip);
    } catch (e) {
      debugPrint('SystemTray: Failed to update tooltip - $e');
    }
  }

  /// Update context menu
  Future<void> updateMenu(Menu menuItems) async {
    if (!_isInitialized) return;

    try {
      await _systemTray.setContextMenu(menuItems);
    } catch (e) {
      debugPrint('SystemTray: Failed to update menu - $e');
    }
  }

  /// Show main window
  Future<void> showWindow() async {
    try {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.restore();
    } catch (e) {
      debugPrint('SystemTray: Failed to show window - $e');
    }
  }

  /// Hide window to tray
  Future<void> hideWindow() async {
    try {
      await windowManager.hide();
    } catch (e) {
      debugPrint('SystemTray: Failed to hide window - $e');
    }
  }

  /// Handle tray icon click (double click to restore window)
  void _handleTrayClick() {
    showWindow();
  }

  /// Destroy system tray
  Future<void> destroy() async {
    if (!_isInitialized) return;

    try {
      await _systemTray.destroy();
      _isInitialized = false;
      debugPrint('SystemTray: Destroyed');
    } catch (e) {
      debugPrint('SystemTray: Failed to destroy - $e');
    }
  }

  bool get isInitialized => _isInitialized;
}

/// System tray service provider
final systemTrayServiceProvider = Provider<SystemTrayService>((ref) {
  return SystemTrayService();
});

/// MenuItemBase extension for easy menu creation
class TrayMenuBuilder {
  /// Create a menu item
  static MenuItem item({
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return MenuItem(
      label: label,
      onClicked: (_) => onTap?.call(),
      disabled: !enabled,
    );
  }

  /// Create a separator
  static MenuSeparator separator() {
    return MenuSeparator();
  }

  /// Create a submenu
  static SubMenu submenu({
    required String label,
    required List<MenuItemBase> children,
  }) {
    return SubMenu(
      label: label,
      children: children,
    );
  }
}
