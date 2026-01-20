import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/theme/app_theme.dart';

/// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// User settings notifier
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  UserSettingsNotifier(this._repository) : super(const UserSettings()) {
    _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    await _repository.init();
    state = _repository.getSettings();
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.updateThemeMode(mode);
  }

  /// Update custom theme color
  Future<void> updateCustomThemeColor(Color color, bool useCustom) async {
    state = state.copyWith(
      customPrimaryColor: color.value,
      useCustomTheme: useCustom,
    );
    await _repository.updateCustomThemeColor(color.value, useCustom);
  }

  /// Add scan path
  Future<void> addScanPath(String path) async {
    final paths = [...state.scanPaths, path];
    state = state.copyWith(scanPaths: paths);
    await _repository.updateScanPaths(paths);
  }

  /// Remove scan path
  Future<void> removeScanPath(String path) async {
    final paths = state.scanPaths.where((p) => p != path).toList();
    state = state.copyWith(scanPaths: paths);
    await _repository.updateScanPaths(paths);
  }

  /// Update fade in duration
  Future<void> updateFadeInDuration(int duration) async {
    state = state.copyWith(fadeInDuration: duration);
    await _repository.updatePlaybackSettings(fadeInDuration: duration);
  }

  /// Update fade out duration
  Future<void> updateFadeOutDuration(int duration) async {
    state = state.copyWith(fadeOutDuration: duration);
    await _repository.updatePlaybackSettings(fadeOutDuration: duration);
  }

  /// Toggle volume normalization
  Future<void> toggleVolumeNormalization() async {
    state = state.copyWith(enableVolumeNormalization: !state.enableVolumeNormalization);
    await _repository.updatePlaybackSettings(
      enableVolumeNormalization: state.enableVolumeNormalization,
    );
  }

  /// Update default play mode
  Future<void> updateDefaultPlayMode(String mode) async {
    state = state.copyWith(defaultPlayMode: mode);
    await _repository.updatePlaybackSettings(defaultPlayMode: mode);
  }

  /// Toggle high refresh rate
  Future<void> toggleHighRefreshRate() async {
    state = state.copyWith(enableHighRefreshRate: !state.enableHighRefreshRate);
    await _repository.updateAnimationSettings(
      enableHighRefreshRate: state.enableHighRefreshRate,
    );
  }

  /// Update target frame rate
  Future<void> updateTargetFrameRate(int frameRate) async {
    state = state.copyWith(targetFrameRate: frameRate);
    await _repository.updateAnimationSettings(targetFrameRate: frameRate);
  }

  /// Update animation speed
  Future<void> updateAnimationSpeed(double speed) async {
    state = state.copyWith(animationSpeed: speed);
    await _repository.updateAnimationSettings(animationSpeed: speed);
  }

  /// Update max cache size
  Future<void> updateMaxCacheSize(int sizeMB) async {
    state = state.copyWith(maxCacheSizeMB: sizeMB);
    await _repository.updateCacheSettings(maxCacheSizeMB: sizeMB);
  }

  /// Update max cover cache size
  Future<void> updateMaxCoverCacheSize(int sizeMB) async {
    state = state.copyWith(maxCoverCacheSizeMB: sizeMB);
    await _repository.updateCacheSettings(maxCoverCacheSizeMB: sizeMB);
  }
}

/// User settings provider
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UserSettingsNotifier(repository);
});

/// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.themeMode.themeMode;
});

/// Current theme data provider
final themeDataProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final settings = ref.watch(userSettingsProvider);

  if (settings.useCustomTheme) {
    return _buildCustomTheme(
      brightness,
      Color(settings.customPrimaryColor),
    );
  }

  return brightness == Brightness.light
      ? AppTheme.lightTheme
      : AppTheme.darkTheme;
});

/// Build custom theme with primary color
ThemeData _buildCustomTheme(Brightness brightness, Color primaryColor) {
  final baseTheme = brightness == Brightness.light
      ? AppTheme.lightTheme
      : AppTheme.darkTheme;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: brightness,
  );

  return baseTheme.copyWith(
    colorScheme: colorScheme,
  );
}
