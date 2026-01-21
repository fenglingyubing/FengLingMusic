import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global hotkey actions
enum HotkeyAction {
  playPause,
  nextTrack,
  previousTrack,
  volumeUp,
  volumeDown,
  toggleWindow,
}

/// Hotkey configuration
class HotkeyConfig {
  final HotkeyAction action;
  final List<KeyboardKey> modifiers;
  final KeyboardKey key;
  final String description;

  const HotkeyConfig({
    required this.action,
    required this.modifiers,
    required this.key,
    required this.description,
  });

  HotKey toHotKey() {
    return HotKey(
      key,
      modifiers: modifiers.map(_mapToKeyModifier).whereType<KeyModifier>().toList(),
      scope: HotKeyScope.system,
    );
  }

  KeyModifier? _mapToKeyModifier(KeyboardKey key) {
    switch (key) {
      case KeyboardKey.control:
      case KeyboardKey.controlLeft:
      case KeyboardKey.controlRight:
        return KeyModifier.control;
      case KeyboardKey.shift:
      case KeyboardKey.shiftLeft:
      case KeyboardKey.shiftRight:
        return KeyModifier.shift;
      case KeyboardKey.alt:
      case KeyboardKey.altLeft:
      case KeyboardKey.altRight:
        return KeyModifier.alt;
      case KeyboardKey.meta:
      case KeyboardKey.metaLeft:
      case KeyboardKey.metaRight:
        return KeyModifier.meta;
      default:
        return null;
    }
  }

  String get displayString {
    final parts = <String>[];
    for (final modifier in modifiers) {
      switch (modifier) {
        case KeyboardKey.control:
        case KeyboardKey.controlLeft:
        case KeyboardKey.controlRight:
          parts.add('Ctrl');
          break;
        case KeyboardKey.shift:
        case KeyboardKey.shiftLeft:
        case KeyboardKey.shiftRight:
          parts.add('Shift');
          break;
        case KeyboardKey.alt:
        case KeyboardKey.altLeft:
        case KeyboardKey.altRight:
          parts.add('Alt');
          break;
        case KeyboardKey.meta:
        case KeyboardKey.metaLeft:
        case KeyboardKey.metaRight:
          parts.add('Win');
          break;
        default:
          break;
      }
    }
    parts.add(_getKeyName(key));
    return parts.join('+');
  }

  String _getKeyName(KeyboardKey key) {
    if (key == KeyboardKey.space) return 'Space';
    if (key == KeyboardKey.arrowLeft) return 'Left';
    if (key == KeyboardKey.arrowRight) return 'Right';
    if (key == KeyboardKey.arrowUp) return 'Up';
    if (key == KeyboardKey.arrowDown) return 'Down';
    if (key.keyLabel.length == 1) return key.keyLabel.toUpperCase();
    return key.keyLabel;
  }
}

/// Default hotkey configurations
class DefaultHotkeys {
  static final Map<HotkeyAction, HotkeyConfig> defaults = {
    HotkeyAction.playPause: HotkeyConfig(
      action: HotkeyAction.playPause,
      modifiers: [KeyboardKey.control],
      key: KeyboardKey.space,
      description: 'Play/Pause',
    ),
    HotkeyAction.nextTrack: HotkeyConfig(
      action: HotkeyAction.nextTrack,
      modifiers: [KeyboardKey.control],
      key: KeyboardKey.arrowRight,
      description: 'Next Track',
    ),
    HotkeyAction.previousTrack: HotkeyConfig(
      action: HotkeyAction.previousTrack,
      modifiers: [KeyboardKey.control],
      key: KeyboardKey.arrowLeft,
      description: 'Previous Track',
    ),
    HotkeyAction.volumeUp: HotkeyConfig(
      action: HotkeyAction.volumeUp,
      modifiers: [KeyboardKey.control],
      key: KeyboardKey.arrowUp,
      description: 'Volume Up',
    ),
    HotkeyAction.volumeDown: HotkeyConfig(
      action: HotkeyAction.volumeDown,
      modifiers: [KeyboardKey.control],
      key: KeyboardKey.arrowDown,
      description: 'Volume Down',
    ),
  };
}

/// Global hotkey service for Windows
class HotkeyService {
  final Map<HotkeyAction, HotKey> _registeredHotkeys = {};
  final Map<HotkeyAction, VoidCallback> _callbacks = {};
  bool _isInitialized = false;

  /// Initialize hotkey manager
  Future<void> initialize() async {
    if (!Platform.isWindows) {
      debugPrint('HotkeyService: Not on Windows platform, skipping initialization');
      return;
    }

    try {
      await hotKeyManager.unregisterAll();
      _isInitialized = true;
      debugPrint('HotkeyService: Initialized successfully');
    } catch (e) {
      debugPrint('HotkeyService: Failed to initialize - $e');
    }
  }

  /// Register a hotkey
  Future<bool> registerHotkey(
    HotkeyConfig config,
    VoidCallback callback,
  ) async {
    if (!_isInitialized) {
      debugPrint('HotkeyService: Not initialized');
      return false;
    }

    try {
      // Unregister existing hotkey for this action
      await unregisterHotkey(config.action);

      // Register new hotkey
      final hotKey = config.toHotKey();
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (_) {
          debugPrint('HotkeyService: ${config.action} triggered');
          callback();
        },
      );

      _registeredHotkeys[config.action] = hotKey;
      _callbacks[config.action] = callback;

      debugPrint('HotkeyService: Registered ${config.displayString} for ${config.action}');
      return true;
    } catch (e) {
      debugPrint('HotkeyService: Failed to register hotkey - $e');
      return false;
    }
  }

  /// Unregister a hotkey
  Future<void> unregisterHotkey(HotkeyAction action) async {
    if (!_isInitialized) return;

    final hotKey = _registeredHotkeys[action];
    if (hotKey != null) {
      try {
        await hotKeyManager.unregister(hotKey);
        _registeredHotkeys.remove(action);
        _callbacks.remove(action);
        debugPrint('HotkeyService: Unregistered hotkey for $action');
      } catch (e) {
        debugPrint('HotkeyService: Failed to unregister hotkey - $e');
      }
    }
  }

  /// Register default hotkeys
  Future<void> registerDefaults(Map<HotkeyAction, VoidCallback> callbacks) async {
    for (final entry in DefaultHotkeys.defaults.entries) {
      final callback = callbacks[entry.key];
      if (callback != null) {
        await registerHotkey(entry.value, callback);
      }
    }
  }

  /// Unregister all hotkeys
  Future<void> unregisterAll() async {
    if (!_isInitialized) return;

    try {
      await hotKeyManager.unregisterAll();
      _registeredHotkeys.clear();
      _callbacks.clear();
      debugPrint('HotkeyService: Unregistered all hotkeys');
    } catch (e) {
      debugPrint('HotkeyService: Failed to unregister all - $e');
    }
  }

  /// Check if a hotkey is registered
  bool isRegistered(HotkeyAction action) {
    return _registeredHotkeys.containsKey(action);
  }

  /// Get registered hotkey configuration
  HotkeyConfig? getConfig(HotkeyAction action) {
    final hotKey = _registeredHotkeys[action];
    if (hotKey == null) return null;

    // Find matching config from defaults
    return DefaultHotkeys.defaults[action];
  }

  /// Get all registered actions
  List<HotkeyAction> get registeredActions => _registeredHotkeys.keys.toList();

  bool get isInitialized => _isInitialized;
}

/// Hotkey service provider
final hotkeyServiceProvider = Provider<HotkeyService>((ref) {
  return HotkeyService();
});
