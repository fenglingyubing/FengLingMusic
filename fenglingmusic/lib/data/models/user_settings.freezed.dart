// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
// Theme settings
  AppThemeMode get themeMode => throw _privateConstructorUsedError;
  int get customPrimaryColor => throw _privateConstructorUsedError;
  bool get useCustomTheme => throw _privateConstructorUsedError; // Scan paths
  List<String> get scanPaths =>
      throw _privateConstructorUsedError; // Playback settings
  int get fadeInDuration => throw _privateConstructorUsedError; // milliseconds
  int get fadeOutDuration => throw _privateConstructorUsedError; // milliseconds
  bool get enableVolumeNormalization => throw _privateConstructorUsedError;
  String get defaultPlayMode =>
      throw _privateConstructorUsedError; // sequential, shuffle, repeat_one
// Animation settings
  bool get enableHighRefreshRate => throw _privateConstructorUsedError;
  int get targetFrameRate => throw _privateConstructorUsedError; // 60, 90, 120
  double get animationSpeed =>
      throw _privateConstructorUsedError; // Cache settings
  int get maxCacheSizeMB => throw _privateConstructorUsedError;
  int get maxCoverCacheSizeMB => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
          UserSettings value, $Res Function(UserSettings) then) =
      _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call(
      {AppThemeMode themeMode,
      int customPrimaryColor,
      bool useCustomTheme,
      List<String> scanPaths,
      int fadeInDuration,
      int fadeOutDuration,
      bool enableVolumeNormalization,
      String defaultPlayMode,
      bool enableHighRefreshRate,
      int targetFrameRate,
      double animationSpeed,
      int maxCacheSizeMB,
      int maxCoverCacheSizeMB});
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? customPrimaryColor = null,
    Object? useCustomTheme = null,
    Object? scanPaths = null,
    Object? fadeInDuration = null,
    Object? fadeOutDuration = null,
    Object? enableVolumeNormalization = null,
    Object? defaultPlayMode = null,
    Object? enableHighRefreshRate = null,
    Object? targetFrameRate = null,
    Object? animationSpeed = null,
    Object? maxCacheSizeMB = null,
    Object? maxCoverCacheSizeMB = null,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      customPrimaryColor: null == customPrimaryColor
          ? _value.customPrimaryColor
          : customPrimaryColor // ignore: cast_nullable_to_non_nullable
              as int,
      useCustomTheme: null == useCustomTheme
          ? _value.useCustomTheme
          : useCustomTheme // ignore: cast_nullable_to_non_nullable
              as bool,
      scanPaths: null == scanPaths
          ? _value.scanPaths
          : scanPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fadeInDuration: null == fadeInDuration
          ? _value.fadeInDuration
          : fadeInDuration // ignore: cast_nullable_to_non_nullable
              as int,
      fadeOutDuration: null == fadeOutDuration
          ? _value.fadeOutDuration
          : fadeOutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      enableVolumeNormalization: null == enableVolumeNormalization
          ? _value.enableVolumeNormalization
          : enableVolumeNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultPlayMode: null == defaultPlayMode
          ? _value.defaultPlayMode
          : defaultPlayMode // ignore: cast_nullable_to_non_nullable
              as String,
      enableHighRefreshRate: null == enableHighRefreshRate
          ? _value.enableHighRefreshRate
          : enableHighRefreshRate // ignore: cast_nullable_to_non_nullable
              as bool,
      targetFrameRate: null == targetFrameRate
          ? _value.targetFrameRate
          : targetFrameRate // ignore: cast_nullable_to_non_nullable
              as int,
      animationSpeed: null == animationSpeed
          ? _value.animationSpeed
          : animationSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      maxCacheSizeMB: null == maxCacheSizeMB
          ? _value.maxCacheSizeMB
          : maxCacheSizeMB // ignore: cast_nullable_to_non_nullable
              as int,
      maxCoverCacheSizeMB: null == maxCoverCacheSizeMB
          ? _value.maxCoverCacheSizeMB
          : maxCoverCacheSizeMB // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
          _$UserSettingsImpl value, $Res Function(_$UserSettingsImpl) then) =
      __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AppThemeMode themeMode,
      int customPrimaryColor,
      bool useCustomTheme,
      List<String> scanPaths,
      int fadeInDuration,
      int fadeOutDuration,
      bool enableVolumeNormalization,
      String defaultPlayMode,
      bool enableHighRefreshRate,
      int targetFrameRate,
      double animationSpeed,
      int maxCacheSizeMB,
      int maxCoverCacheSizeMB});
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
      _$UserSettingsImpl _value, $Res Function(_$UserSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? customPrimaryColor = null,
    Object? useCustomTheme = null,
    Object? scanPaths = null,
    Object? fadeInDuration = null,
    Object? fadeOutDuration = null,
    Object? enableVolumeNormalization = null,
    Object? defaultPlayMode = null,
    Object? enableHighRefreshRate = null,
    Object? targetFrameRate = null,
    Object? animationSpeed = null,
    Object? maxCacheSizeMB = null,
    Object? maxCoverCacheSizeMB = null,
  }) {
    return _then(_$UserSettingsImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      customPrimaryColor: null == customPrimaryColor
          ? _value.customPrimaryColor
          : customPrimaryColor // ignore: cast_nullable_to_non_nullable
              as int,
      useCustomTheme: null == useCustomTheme
          ? _value.useCustomTheme
          : useCustomTheme // ignore: cast_nullable_to_non_nullable
              as bool,
      scanPaths: null == scanPaths
          ? _value._scanPaths
          : scanPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fadeInDuration: null == fadeInDuration
          ? _value.fadeInDuration
          : fadeInDuration // ignore: cast_nullable_to_non_nullable
              as int,
      fadeOutDuration: null == fadeOutDuration
          ? _value.fadeOutDuration
          : fadeOutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      enableVolumeNormalization: null == enableVolumeNormalization
          ? _value.enableVolumeNormalization
          : enableVolumeNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultPlayMode: null == defaultPlayMode
          ? _value.defaultPlayMode
          : defaultPlayMode // ignore: cast_nullable_to_non_nullable
              as String,
      enableHighRefreshRate: null == enableHighRefreshRate
          ? _value.enableHighRefreshRate
          : enableHighRefreshRate // ignore: cast_nullable_to_non_nullable
              as bool,
      targetFrameRate: null == targetFrameRate
          ? _value.targetFrameRate
          : targetFrameRate // ignore: cast_nullable_to_non_nullable
              as int,
      animationSpeed: null == animationSpeed
          ? _value.animationSpeed
          : animationSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      maxCacheSizeMB: null == maxCacheSizeMB
          ? _value.maxCacheSizeMB
          : maxCacheSizeMB // ignore: cast_nullable_to_non_nullable
              as int,
      maxCoverCacheSizeMB: null == maxCoverCacheSizeMB
          ? _value.maxCoverCacheSizeMB
          : maxCoverCacheSizeMB // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl(
      {this.themeMode = AppThemeMode.system,
      this.customPrimaryColor = 0xFF6750A4,
      this.useCustomTheme = false,
      final List<String> scanPaths = const [],
      this.fadeInDuration = 300,
      this.fadeOutDuration = 300,
      this.enableVolumeNormalization = true,
      this.defaultPlayMode = 'sequential',
      this.enableHighRefreshRate = true,
      this.targetFrameRate = 120,
      this.animationSpeed = 1.0,
      this.maxCacheSizeMB = 500,
      this.maxCoverCacheSizeMB = 100})
      : _scanPaths = scanPaths;

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

// Theme settings
  @override
  @JsonKey()
  final AppThemeMode themeMode;
  @override
  @JsonKey()
  final int customPrimaryColor;
  @override
  @JsonKey()
  final bool useCustomTheme;
// Scan paths
  final List<String> _scanPaths;
// Scan paths
  @override
  @JsonKey()
  List<String> get scanPaths {
    if (_scanPaths is EqualUnmodifiableListView) return _scanPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scanPaths);
  }

// Playback settings
  @override
  @JsonKey()
  final int fadeInDuration;
// milliseconds
  @override
  @JsonKey()
  final int fadeOutDuration;
// milliseconds
  @override
  @JsonKey()
  final bool enableVolumeNormalization;
  @override
  @JsonKey()
  final String defaultPlayMode;
// sequential, shuffle, repeat_one
// Animation settings
  @override
  @JsonKey()
  final bool enableHighRefreshRate;
  @override
  @JsonKey()
  final int targetFrameRate;
// 60, 90, 120
  @override
  @JsonKey()
  final double animationSpeed;
// Cache settings
  @override
  @JsonKey()
  final int maxCacheSizeMB;
  @override
  @JsonKey()
  final int maxCoverCacheSizeMB;

  @override
  String toString() {
    return 'UserSettings(themeMode: $themeMode, customPrimaryColor: $customPrimaryColor, useCustomTheme: $useCustomTheme, scanPaths: $scanPaths, fadeInDuration: $fadeInDuration, fadeOutDuration: $fadeOutDuration, enableVolumeNormalization: $enableVolumeNormalization, defaultPlayMode: $defaultPlayMode, enableHighRefreshRate: $enableHighRefreshRate, targetFrameRate: $targetFrameRate, animationSpeed: $animationSpeed, maxCacheSizeMB: $maxCacheSizeMB, maxCoverCacheSizeMB: $maxCoverCacheSizeMB)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.customPrimaryColor, customPrimaryColor) ||
                other.customPrimaryColor == customPrimaryColor) &&
            (identical(other.useCustomTheme, useCustomTheme) ||
                other.useCustomTheme == useCustomTheme) &&
            const DeepCollectionEquality()
                .equals(other._scanPaths, _scanPaths) &&
            (identical(other.fadeInDuration, fadeInDuration) ||
                other.fadeInDuration == fadeInDuration) &&
            (identical(other.fadeOutDuration, fadeOutDuration) ||
                other.fadeOutDuration == fadeOutDuration) &&
            (identical(other.enableVolumeNormalization,
                    enableVolumeNormalization) ||
                other.enableVolumeNormalization == enableVolumeNormalization) &&
            (identical(other.defaultPlayMode, defaultPlayMode) ||
                other.defaultPlayMode == defaultPlayMode) &&
            (identical(other.enableHighRefreshRate, enableHighRefreshRate) ||
                other.enableHighRefreshRate == enableHighRefreshRate) &&
            (identical(other.targetFrameRate, targetFrameRate) ||
                other.targetFrameRate == targetFrameRate) &&
            (identical(other.animationSpeed, animationSpeed) ||
                other.animationSpeed == animationSpeed) &&
            (identical(other.maxCacheSizeMB, maxCacheSizeMB) ||
                other.maxCacheSizeMB == maxCacheSizeMB) &&
            (identical(other.maxCoverCacheSizeMB, maxCoverCacheSizeMB) ||
                other.maxCoverCacheSizeMB == maxCoverCacheSizeMB));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      themeMode,
      customPrimaryColor,
      useCustomTheme,
      const DeepCollectionEquality().hash(_scanPaths),
      fadeInDuration,
      fadeOutDuration,
      enableVolumeNormalization,
      defaultPlayMode,
      enableHighRefreshRate,
      targetFrameRate,
      animationSpeed,
      maxCacheSizeMB,
      maxCoverCacheSizeMB);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(
      this,
    );
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings(
      {final AppThemeMode themeMode,
      final int customPrimaryColor,
      final bool useCustomTheme,
      final List<String> scanPaths,
      final int fadeInDuration,
      final int fadeOutDuration,
      final bool enableVolumeNormalization,
      final String defaultPlayMode,
      final bool enableHighRefreshRate,
      final int targetFrameRate,
      final double animationSpeed,
      final int maxCacheSizeMB,
      final int maxCoverCacheSizeMB}) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override // Theme settings
  AppThemeMode get themeMode;
  @override
  int get customPrimaryColor;
  @override
  bool get useCustomTheme;
  @override // Scan paths
  List<String> get scanPaths;
  @override // Playback settings
  int get fadeInDuration;
  @override // milliseconds
  int get fadeOutDuration;
  @override // milliseconds
  bool get enableVolumeNormalization;
  @override
  String get defaultPlayMode;
  @override // sequential, shuffle, repeat_one
// Animation settings
  bool get enableHighRefreshRate;
  @override
  int get targetFrameRate;
  @override // 60, 90, 120
  double get animationSpeed;
  @override // Cache settings
  int get maxCacheSizeMB;
  @override
  int get maxCoverCacheSizeMB;
  @override
  @JsonKey(ignore: true)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
