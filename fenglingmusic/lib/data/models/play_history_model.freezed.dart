// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayHistoryModel _$PlayHistoryModelFromJson(Map<String, dynamic> json) {
  return _PlayHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$PlayHistoryModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_id')
  int get songId => throw _privateConstructorUsedError;
  @JsonKey(name: 'play_timestamp')
  int get playTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'play_duration')
  int get playDuration => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_rate')
  double get completionRate => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayHistoryModelCopyWith<PlayHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayHistoryModelCopyWith<$Res> {
  factory $PlayHistoryModelCopyWith(
          PlayHistoryModel value, $Res Function(PlayHistoryModel) then) =
      _$PlayHistoryModelCopyWithImpl<$Res, PlayHistoryModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'song_id') int songId,
      @JsonKey(name: 'play_timestamp') int playTimestamp,
      @JsonKey(name: 'play_duration') int playDuration,
      @JsonKey(name: 'completion_rate') double completionRate,
      String? source});
}

/// @nodoc
class _$PlayHistoryModelCopyWithImpl<$Res, $Val extends PlayHistoryModel>
    implements $PlayHistoryModelCopyWith<$Res> {
  _$PlayHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? songId = null,
    Object? playTimestamp = null,
    Object? playDuration = null,
    Object? completionRate = null,
    Object? source = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      songId: null == songId
          ? _value.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      playTimestamp: null == playTimestamp
          ? _value.playTimestamp
          : playTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      playDuration: null == playDuration
          ? _value.playDuration
          : playDuration // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayHistoryModelImplCopyWith<$Res>
    implements $PlayHistoryModelCopyWith<$Res> {
  factory _$$PlayHistoryModelImplCopyWith(_$PlayHistoryModelImpl value,
          $Res Function(_$PlayHistoryModelImpl) then) =
      __$$PlayHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'song_id') int songId,
      @JsonKey(name: 'play_timestamp') int playTimestamp,
      @JsonKey(name: 'play_duration') int playDuration,
      @JsonKey(name: 'completion_rate') double completionRate,
      String? source});
}

/// @nodoc
class __$$PlayHistoryModelImplCopyWithImpl<$Res>
    extends _$PlayHistoryModelCopyWithImpl<$Res, _$PlayHistoryModelImpl>
    implements _$$PlayHistoryModelImplCopyWith<$Res> {
  __$$PlayHistoryModelImplCopyWithImpl(_$PlayHistoryModelImpl _value,
      $Res Function(_$PlayHistoryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? songId = null,
    Object? playTimestamp = null,
    Object? playDuration = null,
    Object? completionRate = null,
    Object? source = freezed,
  }) {
    return _then(_$PlayHistoryModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      songId: null == songId
          ? _value.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      playTimestamp: null == playTimestamp
          ? _value.playTimestamp
          : playTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      playDuration: null == playDuration
          ? _value.playDuration
          : playDuration // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayHistoryModelImpl implements _PlayHistoryModel {
  const _$PlayHistoryModelImpl(
      {this.id,
      @JsonKey(name: 'song_id') required this.songId,
      @JsonKey(name: 'play_timestamp') required this.playTimestamp,
      @JsonKey(name: 'play_duration') this.playDuration = 0,
      @JsonKey(name: 'completion_rate') this.completionRate = 0.0,
      this.source});

  factory _$PlayHistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayHistoryModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'song_id')
  final int songId;
  @override
  @JsonKey(name: 'play_timestamp')
  final int playTimestamp;
  @override
  @JsonKey(name: 'play_duration')
  final int playDuration;
  @override
  @JsonKey(name: 'completion_rate')
  final double completionRate;
  @override
  final String? source;

  @override
  String toString() {
    return 'PlayHistoryModel(id: $id, songId: $songId, playTimestamp: $playTimestamp, playDuration: $playDuration, completionRate: $completionRate, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayHistoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.playTimestamp, playTimestamp) ||
                other.playTimestamp == playTimestamp) &&
            (identical(other.playDuration, playDuration) ||
                other.playDuration == playDuration) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, songId, playTimestamp,
      playDuration, completionRate, source);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayHistoryModelImplCopyWith<_$PlayHistoryModelImpl> get copyWith =>
      __$$PlayHistoryModelImplCopyWithImpl<_$PlayHistoryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayHistoryModelImplToJson(
      this,
    );
  }
}

abstract class _PlayHistoryModel implements PlayHistoryModel {
  const factory _PlayHistoryModel(
      {final int? id,
      @JsonKey(name: 'song_id') required final int songId,
      @JsonKey(name: 'play_timestamp') required final int playTimestamp,
      @JsonKey(name: 'play_duration') final int playDuration,
      @JsonKey(name: 'completion_rate') final double completionRate,
      final String? source}) = _$PlayHistoryModelImpl;

  factory _PlayHistoryModel.fromJson(Map<String, dynamic> json) =
      _$PlayHistoryModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'song_id')
  int get songId;
  @override
  @JsonKey(name: 'play_timestamp')
  int get playTimestamp;
  @override
  @JsonKey(name: 'play_duration')
  int get playDuration;
  @override
  @JsonKey(name: 'completion_rate')
  double get completionRate;
  @override
  String? get source;
  @override
  @JsonKey(ignore: true)
  _$$PlayHistoryModelImplCopyWith<_$PlayHistoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
