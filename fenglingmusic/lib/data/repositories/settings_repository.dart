import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';

/// Settings repository for managing user preferences
class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'user_settings';

  Box<String>? _box;

  /// Initialize Hive box
  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Get user settings
  UserSettings getSettings() {
    final jsonString = _box?.get(_settingsKey);
    if (jsonString == null) {
      return const UserSettings();
    }

    try {
      final json = Map<String, dynamic>.from(
        Uri.splitQueryString(jsonString),
      );
      return UserSettings.fromJson(json);
    } catch (e) {
      return const UserSettings();
    }
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    final json = settings.toJson();
    final jsonString = json.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    await _box?.put(_settingsKey, jsonString);
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode mode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  /// Update custom theme color
  Future<void> updateCustomThemeColor(int color, bool useCustom) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      customPrimaryColor: color,
      useCustomTheme: useCustom,
    ));
  }

  /// Update scan paths
  Future<void> updateScanPaths(List<String> paths) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(scanPaths: paths));
  }

  /// Update playback settings
  Future<void> updatePlaybackSettings({
    int? fadeInDuration,
    int? fadeOutDuration,
    bool? enableVolumeNormalization,
    String? defaultPlayMode,
  }) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      fadeInDuration: fadeInDuration ?? settings.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? settings.fadeOutDuration,
      enableVolumeNormalization: enableVolumeNormalization ?? settings.enableVolumeNormalization,
      defaultPlayMode: defaultPlayMode ?? settings.defaultPlayMode,
    ));
  }

  /// Update animation settings
  Future<void> updateAnimationSettings({
    bool? enableHighRefreshRate,
    int? targetFrameRate,
    double? animationSpeed,
  }) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      enableHighRefreshRate: enableHighRefreshRate ?? settings.enableHighRefreshRate,
      targetFrameRate: targetFrameRate ?? settings.targetFrameRate,
      animationSpeed: animationSpeed ?? settings.animationSpeed,
    ));
  }

  /// Update cache settings
  Future<void> updateCacheSettings({
    int? maxCacheSizeMB,
    int? maxCoverCacheSizeMB,
  }) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      maxCacheSizeMB: maxCacheSizeMB ?? settings.maxCacheSizeMB,
      maxCoverCacheSizeMB: maxCoverCacheSizeMB ?? settings.maxCoverCacheSizeMB,
    ));
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await _box?.delete(_settingsKey);
  }

  /// Dispose
  Future<void> dispose() async {
    await _box?.close();
  }
}
