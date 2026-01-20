// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ArtistModel _$ArtistModelFromJson(Map<String, dynamic> json) {
  return _ArtistModel.fromJson(json);
}

/// @nodoc
mixin _$ArtistModel {
  int? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_path')
  String? get coverPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_count')
  int get songCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'album_count')
  int get albumCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_added')
  int get dateAdded => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ArtistModelCopyWith<ArtistModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArtistModelCopyWith<$Res> {
  factory $ArtistModelCopyWith(
          ArtistModel value, $Res Function(ArtistModel) then) =
      _$ArtistModelCopyWithImpl<$Res, ArtistModel>;
  @useResult
  $Res call(
      {int? id,
      String name,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'song_count') int songCount,
      @JsonKey(name: 'album_count') int albumCount,
      @JsonKey(name: 'date_added') int dateAdded});
}

/// @nodoc
class _$ArtistModelCopyWithImpl<$Res, $Val extends ArtistModel>
    implements $ArtistModelCopyWith<$Res> {
  _$ArtistModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? coverPath = freezed,
    Object? songCount = null,
    Object? albumCount = null,
    Object? dateAdded = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coverPath: freezed == coverPath
          ? _value.coverPath
          : coverPath // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: null == songCount
          ? _value.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int,
      albumCount: null == albumCount
          ? _value.albumCount
          : albumCount // ignore: cast_nullable_to_non_nullable
              as int,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArtistModelImplCopyWith<$Res>
    implements $ArtistModelCopyWith<$Res> {
  factory _$$ArtistModelImplCopyWith(
          _$ArtistModelImpl value, $Res Function(_$ArtistModelImpl) then) =
      __$$ArtistModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String name,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'song_count') int songCount,
      @JsonKey(name: 'album_count') int albumCount,
      @JsonKey(name: 'date_added') int dateAdded});
}

/// @nodoc
class __$$ArtistModelImplCopyWithImpl<$Res>
    extends _$ArtistModelCopyWithImpl<$Res, _$ArtistModelImpl>
    implements _$$ArtistModelImplCopyWith<$Res> {
  __$$ArtistModelImplCopyWithImpl(
      _$ArtistModelImpl _value, $Res Function(_$ArtistModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? coverPath = freezed,
    Object? songCount = null,
    Object? albumCount = null,
    Object? dateAdded = null,
  }) {
    return _then(_$ArtistModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coverPath: freezed == coverPath
          ? _value.coverPath
          : coverPath // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: null == songCount
          ? _value.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int,
      albumCount: null == albumCount
          ? _value.albumCount
          : albumCount // ignore: cast_nullable_to_non_nullable
              as int,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ArtistModelImpl implements _ArtistModel {
  const _$ArtistModelImpl(
      {this.id,
      required this.name,
      @JsonKey(name: 'cover_path') this.coverPath,
      @JsonKey(name: 'song_count') this.songCount = 0,
      @JsonKey(name: 'album_count') this.albumCount = 0,
      @JsonKey(name: 'date_added') required this.dateAdded});

  factory _$ArtistModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArtistModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  @override
  @JsonKey(name: 'cover_path')
  final String? coverPath;
  @override
  @JsonKey(name: 'song_count')
  final int songCount;
  @override
  @JsonKey(name: 'album_count')
  final int albumCount;
  @override
  @JsonKey(name: 'date_added')
  final int dateAdded;

  @override
  String toString() {
    return 'ArtistModel(id: $id, name: $name, coverPath: $coverPath, songCount: $songCount, albumCount: $albumCount, dateAdded: $dateAdded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArtistModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coverPath, coverPath) ||
                other.coverPath == coverPath) &&
            (identical(other.songCount, songCount) ||
                other.songCount == songCount) &&
            (identical(other.albumCount, albumCount) ||
                other.albumCount == albumCount) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, coverPath, songCount, albumCount, dateAdded);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArtistModelImplCopyWith<_$ArtistModelImpl> get copyWith =>
      __$$ArtistModelImplCopyWithImpl<_$ArtistModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArtistModelImplToJson(
      this,
    );
  }
}

abstract class _ArtistModel implements ArtistModel {
  const factory _ArtistModel(
          {final int? id,
          required final String name,
          @JsonKey(name: 'cover_path') final String? coverPath,
          @JsonKey(name: 'song_count') final int songCount,
          @JsonKey(name: 'album_count') final int albumCount,
          @JsonKey(name: 'date_added') required final int dateAdded}) =
      _$ArtistModelImpl;

  factory _ArtistModel.fromJson(Map<String, dynamic> json) =
      _$ArtistModelImpl.fromJson;

  @override
  int? get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'cover_path')
  String? get coverPath;
  @override
  @JsonKey(name: 'song_count')
  int get songCount;
  @override
  @JsonKey(name: 'album_count')
  int get albumCount;
  @override
  @JsonKey(name: 'date_added')
  int get dateAdded;
  @override
  @JsonKey(ignore: true)
  _$$ArtistModelImplCopyWith<_$ArtistModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
