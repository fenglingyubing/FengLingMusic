// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyric_line_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LyricLineModel _$LyricLineModelFromJson(Map<String, dynamic> json) {
  return _LyricLineModel.fromJson(json);
}

/// @nodoc
mixin _$LyricLineModel {
  int get timestamp => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get translation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LyricLineModelCopyWith<LyricLineModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LyricLineModelCopyWith<$Res> {
  factory $LyricLineModelCopyWith(
          LyricLineModel value, $Res Function(LyricLineModel) then) =
      _$LyricLineModelCopyWithImpl<$Res, LyricLineModel>;
  @useResult
  $Res call({int timestamp, String text, String? translation});
}

/// @nodoc
class _$LyricLineModelCopyWithImpl<$Res, $Val extends LyricLineModel>
    implements $LyricLineModelCopyWith<$Res> {
  _$LyricLineModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? text = null,
    Object? translation = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      translation: freezed == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LyricLineModelImplCopyWith<$Res>
    implements $LyricLineModelCopyWith<$Res> {
  factory _$$LyricLineModelImplCopyWith(_$LyricLineModelImpl value,
          $Res Function(_$LyricLineModelImpl) then) =
      __$$LyricLineModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int timestamp, String text, String? translation});
}

/// @nodoc
class __$$LyricLineModelImplCopyWithImpl<$Res>
    extends _$LyricLineModelCopyWithImpl<$Res, _$LyricLineModelImpl>
    implements _$$LyricLineModelImplCopyWith<$Res> {
  __$$LyricLineModelImplCopyWithImpl(
      _$LyricLineModelImpl _value, $Res Function(_$LyricLineModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? text = null,
    Object? translation = freezed,
  }) {
    return _then(_$LyricLineModelImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      translation: freezed == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LyricLineModelImpl implements _LyricLineModel {
  const _$LyricLineModelImpl(
      {required this.timestamp, required this.text, this.translation});

  factory _$LyricLineModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LyricLineModelImplFromJson(json);

  @override
  final int timestamp;
  @override
  final String text;
  @override
  final String? translation;

  @override
  String toString() {
    return 'LyricLineModel(timestamp: $timestamp, text: $text, translation: $translation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LyricLineModelImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.translation, translation) ||
                other.translation == translation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, text, translation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LyricLineModelImplCopyWith<_$LyricLineModelImpl> get copyWith =>
      __$$LyricLineModelImplCopyWithImpl<_$LyricLineModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LyricLineModelImplToJson(
      this,
    );
  }
}

abstract class _LyricLineModel implements LyricLineModel {
  const factory _LyricLineModel(
      {required final int timestamp,
      required final String text,
      final String? translation}) = _$LyricLineModelImpl;

  factory _LyricLineModel.fromJson(Map<String, dynamic> json) =
      _$LyricLineModelImpl.fromJson;

  @override
  int get timestamp;
  @override
  String get text;
  @override
  String? get translation;
  @override
  @JsonKey(ignore: true)
  _$$LyricLineModelImplCopyWith<_$LyricLineModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
