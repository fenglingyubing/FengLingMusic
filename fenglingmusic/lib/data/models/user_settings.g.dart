// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
              AppThemeMode.system,
      customPrimaryColor:
          (json['customPrimaryColor'] as num?)?.toInt() ?? 0xFF6750A4,
      useCustomTheme: json['useCustomTheme'] as bool? ?? false,
      scanPaths: (json['scanPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fadeInDuration: (json['fadeInDuration'] as num?)?.toInt() ?? 300,
      fadeOutDuration: (json['fadeOutDuration'] as num?)?.toInt() ?? 300,
      enableVolumeNormalization:
          json['enableVolumeNormalization'] as bool? ?? true,
      defaultPlayMode: json['defaultPlayMode'] as String? ?? 'sequential',
      enableHighRefreshRate: json['enableHighRefreshRate'] as bool? ?? true,
      targetFrameRate: (json['targetFrameRate'] as num?)?.toInt() ?? 120,
      animationSpeed: (json['animationSpeed'] as num?)?.toDouble() ?? 1.0,
      maxCacheSizeMB: (json['maxCacheSizeMB'] as num?)?.toInt() ?? 500,
      maxCoverCacheSizeMB:
          (json['maxCoverCacheSizeMB'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'customPrimaryColor': instance.customPrimaryColor,
      'useCustomTheme': instance.useCustomTheme,
      'scanPaths': instance.scanPaths,
      'fadeInDuration': instance.fadeInDuration,
      'fadeOutDuration': instance.fadeOutDuration,
      'enableVolumeNormalization': instance.enableVolumeNormalization,
      'defaultPlayMode': instance.defaultPlayMode,
      'enableHighRefreshRate': instance.enableHighRefreshRate,
      'targetFrameRate': instance.targetFrameRate,
      'animationSpeed': instance.animationSpeed,
      'maxCacheSizeMB': instance.maxCacheSizeMB,
      'maxCoverCacheSizeMB': instance.maxCoverCacheSizeMB,
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.system: 'system',
};
