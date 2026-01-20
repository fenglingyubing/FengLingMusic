import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

/// Theme mode settings
enum AppThemeMode {
  light,
  dark,
  system,
}

/// User settings model
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    // Theme settings
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(0xFF6750A4) int customPrimaryColor,
    @Default(false) bool useCustomTheme,

    // Scan paths
    @Default([]) List<String> scanPaths,

    // Playback settings
    @Default(300) int fadeInDuration, // milliseconds
    @Default(300) int fadeOutDuration, // milliseconds
    @Default(true) bool enableVolumeNormalization,
    @Default('sequential') String defaultPlayMode, // sequential, shuffle, repeat_one

    // Animation settings
    @Default(true) bool enableHighRefreshRate,
    @Default(120) int targetFrameRate, // 60, 90, 120
    @Default(1.0) double animationSpeed,

    // Cache settings
    @Default(500) int maxCacheSizeMB,
    @Default(100) int maxCoverCacheSizeMB,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

/// Extension for AppThemeMode
extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return '浅色';
      case AppThemeMode.dark:
        return '深色';
      case AppThemeMode.system:
        return '跟随系统';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
