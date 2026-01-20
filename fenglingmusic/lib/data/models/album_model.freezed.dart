// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AlbumModel _$AlbumModelFromJson(Map<String, dynamic> json) {
  return _AlbumModel.fromJson(json);
}

/// @nodoc
mixin _$AlbumModel {
  int? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get artist => throw _privateConstructorUsedError;
  @JsonKey(name: 'album_artist')
  String? get albumArtist => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get genre => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_path')
  String? get coverPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'song_count')
  int get songCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_duration')
  int get totalDuration => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_added')
  int get dateAdded => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AlbumModelCopyWith<AlbumModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlbumModelCopyWith<$Res> {
  factory $AlbumModelCopyWith(
          AlbumModel value, $Res Function(AlbumModel) then) =
      _$AlbumModelCopyWithImpl<$Res, AlbumModel>;
  @useResult
  $Res call(
      {int? id,
      String title,
      String? artist,
      @JsonKey(name: 'album_artist') String? albumArtist,
      int? year,
      String? genre,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'song_count') int songCount,
      @JsonKey(name: 'total_duration') int totalDuration,
      @JsonKey(name: 'date_added') int dateAdded});
}

/// @nodoc
class _$AlbumModelCopyWithImpl<$Res, $Val extends AlbumModel>
    implements $AlbumModelCopyWith<$Res> {
  _$AlbumModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? albumArtist = freezed,
    Object? year = freezed,
    Object? genre = freezed,
    Object? coverPath = freezed,
    Object? songCount = null,
    Object? totalDuration = null,
    Object? dateAdded = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: freezed == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String?,
      albumArtist: freezed == albumArtist
          ? _value.albumArtist
          : albumArtist // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
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
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlbumModelImplCopyWith<$Res>
    implements $AlbumModelCopyWith<$Res> {
  factory _$$AlbumModelImplCopyWith(
          _$AlbumModelImpl value, $Res Function(_$AlbumModelImpl) then) =
      __$$AlbumModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String title,
      String? artist,
      @JsonKey(name: 'album_artist') String? albumArtist,
      int? year,
      String? genre,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'song_count') int songCount,
      @JsonKey(name: 'total_duration') int totalDuration,
      @JsonKey(name: 'date_added') int dateAdded});
}

/// @nodoc
class __$$AlbumModelImplCopyWithImpl<$Res>
    extends _$AlbumModelCopyWithImpl<$Res, _$AlbumModelImpl>
    implements _$$AlbumModelImplCopyWith<$Res> {
  __$$AlbumModelImplCopyWithImpl(
      _$AlbumModelImpl _value, $Res Function(_$AlbumModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? albumArtist = freezed,
    Object? year = freezed,
    Object? genre = freezed,
    Object? coverPath = freezed,
    Object? songCount = null,
    Object? totalDuration = null,
    Object? dateAdded = null,
  }) {
    return _then(_$AlbumModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: freezed == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String?,
      albumArtist: freezed == albumArtist
          ? _value.albumArtist
          : albumArtist // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
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
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlbumModelImpl implements _AlbumModel {
  const _$AlbumModelImpl(
      {this.id,
      required this.title,
      this.artist,
      @JsonKey(name: 'album_artist') this.albumArtist,
      this.year,
      this.genre,
      @JsonKey(name: 'cover_path') this.coverPath,
      @JsonKey(name: 'song_count') this.songCount = 0,
      @JsonKey(name: 'total_duration') this.totalDuration = 0,
      @JsonKey(name: 'date_added') required this.dateAdded});

  factory _$AlbumModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlbumModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String title;
  @override
  final String? artist;
  @override
  @JsonKey(name: 'album_artist')
  final String? albumArtist;
  @override
  final int? year;
  @override
  final String? genre;
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
  @JsonKey(name: 'date_added')
  final int dateAdded;

  @override
  String toString() {
    return 'AlbumModel(id: $id, title: $title, artist: $artist, albumArtist: $albumArtist, year: $year, genre: $genre, coverPath: $coverPath, songCount: $songCount, totalDuration: $totalDuration, dateAdded: $dateAdded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.albumArtist, albumArtist) ||
                other.albumArtist == albumArtist) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.coverPath, coverPath) ||
                other.coverPath == coverPath) &&
            (identical(other.songCount, songCount) ||
                other.songCount == songCount) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, artist, albumArtist,
      year, genre, coverPath, songCount, totalDuration, dateAdded);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumModelImplCopyWith<_$AlbumModelImpl> get copyWith =>
      __$$AlbumModelImplCopyWithImpl<_$AlbumModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlbumModelImplToJson(
      this,
    );
  }
}

abstract class _AlbumModel implements AlbumModel {
  const factory _AlbumModel(
          {final int? id,
          required final String title,
          final String? artist,
          @JsonKey(name: 'album_artist') final String? albumArtist,
          final int? year,
          final String? genre,
          @JsonKey(name: 'cover_path') final String? coverPath,
          @JsonKey(name: 'song_count') final int songCount,
          @JsonKey(name: 'total_duration') final int totalDuration,
          @JsonKey(name: 'date_added') required final int dateAdded}) =
      _$AlbumModelImpl;

  factory _AlbumModel.fromJson(Map<String, dynamic> json) =
      _$AlbumModelImpl.fromJson;

  @override
  int? get id;
  @override
  String get title;
  @override
  String? get artist;
  @override
  @JsonKey(name: 'album_artist')
  String? get albumArtist;
  @override
  int? get year;
  @override
  String? get genre;
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
  @JsonKey(name: 'date_added')
  int get dateAdded;
  @override
  @JsonKey(ignore: true)
  _$$AlbumModelImplCopyWith<_$AlbumModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
