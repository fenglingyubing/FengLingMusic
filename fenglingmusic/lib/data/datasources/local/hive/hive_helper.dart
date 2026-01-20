import 'package:hive_flutter/hive_flutter.dart';

/// Hive database helper
/// Initializes and manages Hive boxes for local key-value storage
class HiveHelper {
  static final HiveHelper instance = HiveHelper._internal();
  HiveHelper._internal();

  /// Box names
  static const String _settingsBoxName = 'settings';
  static const String _playerStateBoxName = 'player_state';
  static const String _cacheBoxName = 'cache';

  bool _initialized = false;

  /// Initialize Hive
  Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Open boxes (using simple Map storage)
    await openBoxes();

    _initialized = true;
  }

  /// Open all Hive boxes
  Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox(_settingsBoxName),
      Hive.openBox(_playerStateBoxName),
      Hive.openBox(_cacheBoxName),
    ]);
  }

  /// Get settings box
  Box get settingsBox {
    if (!_initialized) {
      throw StateError('HiveHelper not initialized. Call init() first.');
    }
    return Hive.box(_settingsBoxName);
  }

  /// Get player state box
  Box get playerStateBox {
    if (!_initialized) {
      throw StateError('HiveHelper not initialized. Call init() first.');
    }
    return Hive.box(_playerStateBoxName);
  }

  /// Get cache box
  Box get cacheBox {
    if (!_initialized) {
      throw StateError('HiveHelper not initialized. Call init() first.');
    }
    return Hive.box(_cacheBoxName);
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }

  /// Delete all Hive data (for testing or reset)
  Future<void> deleteAll() async {
    await Future.wait([
      Hive.deleteBoxFromDisk(_settingsBoxName),
      Hive.deleteBoxFromDisk(_playerStateBoxName),
      Hive.deleteBoxFromDisk(_cacheBoxName),
    ]);
    _initialized = false;
  }
}
