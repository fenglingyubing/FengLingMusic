// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaylistModel _$PlaylistModelFromJson(Map<String, dynamic> json) {
  return _PlaylistModel.fromJson(json);
}

/// @nodoc
mixin _$PlaylistModel {
  int? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_path')
  String? get coverPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_count')
  int get songCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_duration')
  int get totalDuration => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_created')
  int get dateCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_modified')
  int get dateModified => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlaylistModelCopyWith<PlaylistModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistModelCopyWith<$Res> {
  factory $PlaylistModelCopyWith(
          PlaylistModel value, $Res Function(PlaylistModel) then) =
      _$PlaylistModelCopyWithImpl<$Res, PlaylistModel>;
  @useResult
  $Res call(
      {int? id,
      String name,
      String? description,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'song_count') int songCount,
      @JsonKey(name: 'total_duration') int totalDuration,
      @JsonKey(name: 'date_created') int dateCreated,
      @JsonKey(name: 'date_modified') int dateModified});
}

/// @nodoc
class _$PlaylistModelCopyWithImpl<$Res, $Val extends PlaylistModel>
    implements $PlaylistModelCopyWith<$Res> {
  _$PlaylistModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? coverPath = freezed,
    Object? songCount = null,
    Object? totalDuration = null,
    Object? dateCreated = null,
    Object? dateModified = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      coverPath: freezed == coverPath
          ? _value.coverPath
          : coverPath // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: null == songCount
          ? _value.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      dateCreated: null == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as int,
      dateModified: null == dateModified
          ? _value.dateModified
          : dateModified // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistModelImplCopyWith<$Res>
    implements $PlaylistModelCopyWith<$Res> {
  factory _$$PlaylistModelImplCopyWith(
          _$PlaylistModelImpl value, $Res Function(_$PlaylistModelImpl) then) =
      __$$PlaylistModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String name,
      String? description,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'song_count') int songCount,
      @JsonKey(name: 'total_duration') int totalDuration,
      @JsonKey(name: 'date_created') int dateCreated,
      @JsonKey(name: 'date_modified') int dateModified});
}

/// @nodoc
class __$$PlaylistModelImplCopyWithImpl<$Res>
    extends _$PlaylistModelCopyWithImpl<$Res, _$PlaylistModelImpl>
    implements _$$PlaylistModelImplCopyWith<$Res> {
  __$$PlaylistModelImplCopyWithImpl(
      _$PlaylistModelImpl _value, $Res Function(_$PlaylistModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? coverPath = freezed,
    Object? songCount = null,
    Object? totalDuration = null,
    Object? dateCreated = null,
    Object? dateModified = null,
  }) {
    return _then(_$PlaylistModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      coverPath: freezed == coverPath
          ? _value.coverPath
          : coverPath // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: null == songCount
          ? _value.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      dateCreated: null == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as int,
      dateModified: null == dateModified
          ? _value.dateModified
          : dateModified // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistModelImpl implements _PlaylistModel {
  const _$PlaylistModelImpl(
      {this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'cover_path') this.coverPath,
      @JsonKey(name: 'song_count') this.songCount = 0,
      @JsonKey(name: 'total_duration') this.totalDuration = 0,
      @JsonKey(name: 'date_created') required this.dateCreated,
      @JsonKey(name: 'date_modified') required this.dateModified});

  factory _$PlaylistModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'cover_path')
  final String? coverPath;
  @override
  @JsonKey(name: 'song_count')
  final int songCount;
  @override
  @JsonKey(name: 'total_duration')
  final int totalDuration;
  @override
  @JsonKey(name: 'date_created')
  final int dateCreated;
  @override
  @JsonKey(name: 'date_modified')
  final int dateModified;

  @override
  String toString() {
    return 'PlaylistModel(id: $id, name: $name, description: $description, coverPath: $coverPath, songCount: $songCount, totalDuration: $totalDuration, dateCreated: $dateCreated, dateModified: $dateModified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverPath, coverPath) ||
                other.coverPath == coverPath) &&
            (identical(other.songCount, songCount) ||
                other.songCount == songCount) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.dateModified, dateModified) ||
                other.dateModified == dateModified));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, coverPath,
      songCount, totalDuration, dateCreated, dateModified);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistModelImplCopyWith<_$PlaylistModelImpl> get copyWith =>
      __$$PlaylistModelImplCopyWithImpl<_$PlaylistModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistModelImplToJson(
      this,
    );
  }
}

abstract class _PlaylistModel implements PlaylistModel {
  const factory _PlaylistModel(
          {final int? id,
          required final String name,
          final String? description,
          @JsonKey(name: 'cover_path') final String? coverPath,
          @JsonKey(name: 'song_count') final int songCount,
          @JsonKey(name: 'total_duration') final int totalDuration,
          @JsonKey(name: 'date_created') required final int dateCreated,
          @JsonKey(name: 'date_modified') required final int dateModified}) =
      _$PlaylistModelImpl;

  factory _PlaylistModel.fromJson(Map<String, dynamic> json) =
      _$PlaylistModelImpl.fromJson;

  @override
  int? get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'cover_path')
  String? get coverPath;
  @override
  @JsonKey(name: 'song_count')
  int get songCount;
  @override
  @JsonKey(name: 'total_duration')
  int get totalDuration;
  @override
  @JsonKey(name: 'date_created')
  int get dateCreated;
  @override
  @JsonKey(name: 'date_modified')
  int get dateModified;
  @override
  @JsonKey(ignore: true)
  _$$PlaylistModelImplCopyWith<_$PlaylistModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaylistSongModel _$PlaylistSongModelFromJson(Map<String, dynamic> json) {
  return _PlaylistSongModel.fromJson(json);
}

/// @nodoc
mixin _$PlaylistSongModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'playlist_id')
  int get playlistId => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_id')
  int get songId => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_added')
  int get dateAdded => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlaylistSongModelCopyWith<PlaylistSongModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistSongModelCopyWith<$Res> {
  factory $PlaylistSongModelCopyWith(
          PlaylistSongModel value, $Res Function(PlaylistSongModel) then) =
      _$PlaylistSongModelCopyWithImpl<$Res, PlaylistSongModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'playlist_id') int playlistId,
      @JsonKey(name: 'song_id') int songId,
      int position,
      @JsonKey(name: 'date_added') int dateAdded});
}

/// @nodoc
class _$PlaylistSongModelCopyWithImpl<$Res, $Val extends PlaylistSongModel>
    implements $PlaylistSongModelCopyWith<$Res> {
  _$PlaylistSongModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? playlistId = null,
    Object? songId = null,
    Object? position = null,
    Object? dateAdded = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      playlistId: null == playlistId
          ? _value.playlistId
          : playlistId // ignore: cast_nullable_to_non_nullable
              as int,
      songId: null == songId
          ? _value.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistSongModelImplCopyWith<$Res>
    implements $PlaylistSongModelCopyWith<$Res> {
  factory _$$PlaylistSongModelImplCopyWith(_$PlaylistSongModelImpl value,
          $Res Function(_$PlaylistSongModelImpl) then) =
      __$$PlaylistSongModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'playlist_id') int playlistId,
      @JsonKey(name: 'song_id') int songId,
      int position,
      @JsonKey(name: 'date_added') int dateAdded});
}

/// @nodoc
class __$$PlaylistSongModelImplCopyWithImpl<$Res>
    extends _$PlaylistSongModelCopyWithImpl<$Res, _$PlaylistSongModelImpl>
    implements _$$PlaylistSongModelImplCopyWith<$Res> {
  __$$PlaylistSongModelImplCopyWithImpl(_$PlaylistSongModelImpl _value,
      $Res Function(_$PlaylistSongModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? playlistId = null,
    Object? songId = null,
    Object? position = null,
    Object? dateAdded = null,
  }) {
    return _then(_$PlaylistSongModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      playlistId: null == playlistId
          ? _value.playlistId
          : playlistId // ignore: cast_nullable_to_non_nullable
              as int,
      songId: null == songId
          ? _value.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
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
class _$PlaylistSongModelImpl implements _PlaylistSongModel {
  const _$PlaylistSongModelImpl(
      {this.id,
      @JsonKey(name: 'playlist_id') required this.playlistId,
      @JsonKey(name: 'song_id') required this.songId,
      required this.position,
      @JsonKey(name: 'date_added') required this.dateAdded});

  factory _$PlaylistSongModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistSongModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'playlist_id')
  final int playlistId;
  @override
  @JsonKey(name: 'song_id')
  final int songId;
  @override
  final int position;
  @override
  @JsonKey(name: 'date_added')
  final int dateAdded;

  @override
  String toString() {
    return 'PlaylistSongModel(id: $id, playlistId: $playlistId, songId: $songId, position: $position, dateAdded: $dateAdded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistSongModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playlistId, playlistId) ||
                other.playlistId == playlistId) &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, playlistId, songId, position, dateAdded);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistSongModelImplCopyWith<_$PlaylistSongModelImpl> get copyWith =>
      __$$PlaylistSongModelImplCopyWithImpl<_$PlaylistSongModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistSongModelImplToJson(
      this,
    );
  }
}

abstract class _PlaylistSongModel implements PlaylistSongModel {
  const factory _PlaylistSongModel(
          {final int? id,
          @JsonKey(name: 'playlist_id') required final int playlistId,
          @JsonKey(name: 'song_id') required final int songId,
          required final int position,
          @JsonKey(name: 'date_added') required final int dateAdded}) =
      _$PlaylistSongModelImpl;

  factory _PlaylistSongModel.fromJson(Map<String, dynamic> json) =
      _$PlaylistSongModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'playlist_id')
  int get playlistId;
  @override
  @JsonKey(name: 'song_id')
  int get songId;
  @override
  int get position;
  @override
  @JsonKey(name: 'date_added')
  int get dateAdded;
  @override
  @JsonKey(ignore: true)
  _$$PlaylistSongModelImplCopyWith<_$PlaylistSongModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
