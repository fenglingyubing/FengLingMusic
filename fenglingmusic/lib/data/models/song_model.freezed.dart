// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SongModel _$SongModelFromJson(Map<String, dynamic> json) {
  return _SongModel.fromJson(json);
}

/// @nodoc
mixin _$SongModel {
  int? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get artist => throw _privateConstructorUsedError;
  String? get album => throw _privateConstructorUsedError;
  @JsonKey(name: 'album_artist')
  String? get albumArtist => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_path')
  String get filePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String? get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'bit_rate')
  int? get bitRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'sample_rate')
  int? get sampleRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_number')
  int? get trackNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'disc_number')
  int? get discNumber => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get genre => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_path')
  String? get coverPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'lyrics_path')
  String? get lyricsPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'play_count')
  int get playCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'skip_count')
  int get skipCount => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_added')
  int get dateAdded => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_modified')
  int get dateModified => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_played')
  int? get lastPlayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongModelCopyWith<SongModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongModelCopyWith<$Res> {
  factory $SongModelCopyWith(SongModel value, $Res Function(SongModel) then) =
      _$SongModelCopyWithImpl<$Res, SongModel>;
  @useResult
  $Res call(
      {int? id,
      String title,
      String? artist,
      String? album,
      @JsonKey(name: 'album_artist') String? albumArtist,
      int duration,
      @JsonKey(name: 'file_path') String filePath,
      @JsonKey(name: 'file_size') int fileSize,
      @JsonKey(name: 'mime_type') String? mimeType,
      @JsonKey(name: 'bit_rate') int? bitRate,
      @JsonKey(name: 'sample_rate') int? sampleRate,
      @JsonKey(name: 'track_number') int? trackNumber,
      @JsonKey(name: 'disc_number') int? discNumber,
      int? year,
      String? genre,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'lyrics_path') String? lyricsPath,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'play_count') int playCount,
      @JsonKey(name: 'skip_count') int skipCount,
      double rating,
      @JsonKey(name: 'date_added') int dateAdded,
      @JsonKey(name: 'date_modified') int dateModified,
      @JsonKey(name: 'last_played') int? lastPlayed});
}

/// @nodoc
class _$SongModelCopyWithImpl<$Res, $Val extends SongModel>
    implements $SongModelCopyWith<$Res> {
  _$SongModelCopyWithImpl(this._value, this._then);

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
    Object? album = freezed,
    Object? albumArtist = freezed,
    Object? duration = null,
    Object? filePath = null,
    Object? fileSize = null,
    Object? mimeType = freezed,
    Object? bitRate = freezed,
    Object? sampleRate = freezed,
    Object? trackNumber = freezed,
    Object? discNumber = freezed,
    Object? year = freezed,
    Object? genre = freezed,
    Object? coverPath = freezed,
    Object? lyricsPath = freezed,
    Object? isFavorite = null,
    Object? playCount = null,
    Object? skipCount = null,
    Object? rating = null,
    Object? dateAdded = null,
    Object? dateModified = null,
    Object? lastPlayed = freezed,
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
      album: freezed == album
          ? _value.album
          : album // ignore: cast_nullable_to_non_nullable
              as String?,
      albumArtist: freezed == albumArtist
          ? _value.albumArtist
          : albumArtist // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      bitRate: freezed == bitRate
          ? _value.bitRate
          : bitRate // ignore: cast_nullable_to_non_nullable
              as int?,
      sampleRate: freezed == sampleRate
          ? _value.sampleRate
          : sampleRate // ignore: cast_nullable_to_non_nullable
              as int?,
      trackNumber: freezed == trackNumber
          ? _value.trackNumber
          : trackNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      discNumber: freezed == discNumber
          ? _value.discNumber
          : discNumber // ignore: cast_nullable_to_non_nullable
              as int?,
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
      lyricsPath: freezed == lyricsPath
          ? _value.lyricsPath
          : lyricsPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      skipCount: null == skipCount
          ? _value.skipCount
          : skipCount // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
      dateModified: null == dateModified
          ? _value.dateModified
          : dateModified // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayed: freezed == lastPlayed
          ? _value.lastPlayed
          : lastPlayed // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SongModelImplCopyWith<$Res>
    implements $SongModelCopyWith<$Res> {
  factory _$$SongModelImplCopyWith(
          _$SongModelImpl value, $Res Function(_$SongModelImpl) then) =
      __$$SongModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String title,
      String? artist,
      String? album,
      @JsonKey(name: 'album_artist') String? albumArtist,
      int duration,
      @JsonKey(name: 'file_path') String filePath,
      @JsonKey(name: 'file_size') int fileSize,
      @JsonKey(name: 'mime_type') String? mimeType,
      @JsonKey(name: 'bit_rate') int? bitRate,
      @JsonKey(name: 'sample_rate') int? sampleRate,
      @JsonKey(name: 'track_number') int? trackNumber,
      @JsonKey(name: 'disc_number') int? discNumber,
      int? year,
      String? genre,
      @JsonKey(name: 'cover_path') String? coverPath,
      @JsonKey(name: 'lyrics_path') String? lyricsPath,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      @JsonKey(name: 'play_count') int playCount,
      @JsonKey(name: 'skip_count') int skipCount,
      double rating,
      @JsonKey(name: 'date_added') int dateAdded,
      @JsonKey(name: 'date_modified') int dateModified,
      @JsonKey(name: 'last_played') int? lastPlayed});
}

/// @nodoc
class __$$SongModelImplCopyWithImpl<$Res>
    extends _$SongModelCopyWithImpl<$Res, _$SongModelImpl>
    implements _$$SongModelImplCopyWith<$Res> {
  __$$SongModelImplCopyWithImpl(
      _$SongModelImpl _value, $Res Function(_$SongModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? album = freezed,
    Object? albumArtist = freezed,
    Object? duration = null,
    Object? filePath = null,
    Object? fileSize = null,
    Object? mimeType = freezed,
    Object? bitRate = freezed,
    Object? sampleRate = freezed,
    Object? trackNumber = freezed,
    Object? discNumber = freezed,
    Object? year = freezed,
    Object? genre = freezed,
    Object? coverPath = freezed,
    Object? lyricsPath = freezed,
    Object? isFavorite = null,
    Object? playCount = null,
    Object? skipCount = null,
    Object? rating = null,
    Object? dateAdded = null,
    Object? dateModified = null,
    Object? lastPlayed = freezed,
  }) {
    return _then(_$SongModelImpl(
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
      album: freezed == album
          ? _value.album
          : album // ignore: cast_nullable_to_non_nullable
              as String?,
      albumArtist: freezed == albumArtist
          ? _value.albumArtist
          : albumArtist // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      bitRate: freezed == bitRate
          ? _value.bitRate
          : bitRate // ignore: cast_nullable_to_non_nullable
              as int?,
      sampleRate: freezed == sampleRate
          ? _value.sampleRate
          : sampleRate // ignore: cast_nullable_to_non_nullable
              as int?,
      trackNumber: freezed == trackNumber
          ? _value.trackNumber
          : trackNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      discNumber: freezed == discNumber
          ? _value.discNumber
          : discNumber // ignore: cast_nullable_to_non_nullable
              as int?,
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
      lyricsPath: freezed == lyricsPath
          ? _value.lyricsPath
          : lyricsPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      skipCount: null == skipCount
          ? _value.skipCount
          : skipCount // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as int,
      dateModified: null == dateModified
          ? _value.dateModified
          : dateModified // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayed: freezed == lastPlayed
          ? _value.lastPlayed
          : lastPlayed // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongModelImpl implements _SongModel {
  const _$SongModelImpl(
      {this.id,
      required this.title,
      this.artist,
      this.album,
      @JsonKey(name: 'album_artist') this.albumArtist,
      this.duration = 0,
      @JsonKey(name: 'file_path') required this.filePath,
      @JsonKey(name: 'file_size') this.fileSize = 0,
      @JsonKey(name: 'mime_type') this.mimeType,
      @JsonKey(name: 'bit_rate') this.bitRate,
      @JsonKey(name: 'sample_rate') this.sampleRate,
      @JsonKey(name: 'track_number') this.trackNumber,
      @JsonKey(name: 'disc_number') this.discNumber,
      this.year,
      this.genre,
      @JsonKey(name: 'cover_path') this.coverPath,
      @JsonKey(name: 'lyrics_path') this.lyricsPath,
      @JsonKey(name: 'is_favorite') this.isFavorite = false,
      @JsonKey(name: 'play_count') this.playCount = 0,
      @JsonKey(name: 'skip_count') this.skipCount = 0,
      this.rating = 0.0,
      @JsonKey(name: 'date_added') required this.dateAdded,
      @JsonKey(name: 'date_modified') required this.dateModified,
      @JsonKey(name: 'last_played') this.lastPlayed});

  factory _$SongModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String title;
  @override
  final String? artist;
  @override
  final String? album;
  @override
  @JsonKey(name: 'album_artist')
  final String? albumArtist;
  @override
  @JsonKey()
  final int duration;
  @override
  @JsonKey(name: 'file_path')
  final String filePath;
  @override
  @JsonKey(name: 'file_size')
  final int fileSize;
  @override
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  @override
  @JsonKey(name: 'bit_rate')
  final int? bitRate;
  @override
  @JsonKey(name: 'sample_rate')
  final int? sampleRate;
  @override
  @JsonKey(name: 'track_number')
  final int? trackNumber;
  @override
  @JsonKey(name: 'disc_number')
  final int? discNumber;
  @override
  final int? year;
  @override
  final String? genre;
  @override
  @JsonKey(name: 'cover_path')
  final String? coverPath;
  @override
  @JsonKey(name: 'lyrics_path')
  final String? lyricsPath;
  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @override
  @JsonKey(name: 'play_count')
  final int playCount;
  @override
  @JsonKey(name: 'skip_count')
  final int skipCount;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey(name: 'date_added')
  final int dateAdded;
  @override
  @JsonKey(name: 'date_modified')
  final int dateModified;
  @override
  @JsonKey(name: 'last_played')
  final int? lastPlayed;

  @override
  String toString() {
    return 'SongModel(id: $id, title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, duration: $duration, filePath: $filePath, fileSize: $fileSize, mimeType: $mimeType, bitRate: $bitRate, sampleRate: $sampleRate, trackNumber: $trackNumber, discNumber: $discNumber, year: $year, genre: $genre, coverPath: $coverPath, lyricsPath: $lyricsPath, isFavorite: $isFavorite, playCount: $playCount, skipCount: $skipCount, rating: $rating, dateAdded: $dateAdded, dateModified: $dateModified, lastPlayed: $lastPlayed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.album, album) || other.album == album) &&
            (identical(other.albumArtist, albumArtist) ||
                other.albumArtist == albumArtist) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.bitRate, bitRate) || other.bitRate == bitRate) &&
            (identical(other.sampleRate, sampleRate) ||
                other.sampleRate == sampleRate) &&
            (identical(other.trackNumber, trackNumber) ||
                other.trackNumber == trackNumber) &&
            (identical(other.discNumber, discNumber) ||
                other.discNumber == discNumber) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.coverPath, coverPath) ||
                other.coverPath == coverPath) &&
            (identical(other.lyricsPath, lyricsPath) ||
                other.lyricsPath == lyricsPath) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.skipCount, skipCount) ||
                other.skipCount == skipCount) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.dateModified, dateModified) ||
                other.dateModified == dateModified) &&
            (identical(other.lastPlayed, lastPlayed) ||
                other.lastPlayed == lastPlayed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        artist,
        album,
        albumArtist,
        duration,
        filePath,
        fileSize,
        mimeType,
        bitRate,
        sampleRate,
        trackNumber,
        discNumber,
        year,
        genre,
        coverPath,
        lyricsPath,
        isFavorite,
        playCount,
        skipCount,
        rating,
        dateAdded,
        dateModified,
        lastPlayed
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SongModelImplCopyWith<_$SongModelImpl> get copyWith =>
      __$$SongModelImplCopyWithImpl<_$SongModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongModelImplToJson(
      this,
    );
  }
}

abstract class _SongModel implements SongModel {
  const factory _SongModel(
      {final int? id,
      required final String title,
      final String? artist,
      final String? album,
      @JsonKey(name: 'album_artist') final String? albumArtist,
      final int duration,
      @JsonKey(name: 'file_path') required final String filePath,
      @JsonKey(name: 'file_size') final int fileSize,
      @JsonKey(name: 'mime_type') final String? mimeType,
      @JsonKey(name: 'bit_rate') final int? bitRate,
      @JsonKey(name: 'sample_rate') final int? sampleRate,
      @JsonKey(name: 'track_number') final int? trackNumber,
      @JsonKey(name: 'disc_number') final int? discNumber,
      final int? year,
      final String? genre,
      @JsonKey(name: 'cover_path') final String? coverPath,
      @JsonKey(name: 'lyrics_path') final String? lyricsPath,
      @JsonKey(name: 'is_favorite') final bool isFavorite,
      @JsonKey(name: 'play_count') final int playCount,
      @JsonKey(name: 'skip_count') final int skipCount,
      final double rating,
      @JsonKey(name: 'date_added') required final int dateAdded,
      @JsonKey(name: 'date_modified') required final int dateModified,
      @JsonKey(name: 'last_played') final int? lastPlayed}) = _$SongModelImpl;

  factory _SongModel.fromJson(Map<String, dynamic> json) =
      _$SongModelImpl.fromJson;

  @override
  int? get id;
  @override
  String get title;
  @override
  String? get artist;
  @override
  String? get album;
  @override
  @JsonKey(name: 'album_artist')
  String? get albumArtist;
  @override
  int get duration;
  @override
  @JsonKey(name: 'file_path')
  String get filePath;
  @override
  @JsonKey(name: 'file_size')
  int get fileSize;
  @override
  @JsonKey(name: 'mime_type')
  String? get mimeType;
  @override
  @JsonKey(name: 'bit_rate')
  int? get bitRate;
  @override
  @JsonKey(name: 'sample_rate')
  int? get sampleRate;
  @override
  @JsonKey(name: 'track_number')
  int? get trackNumber;
  @override
  @JsonKey(name: 'disc_number')
  int? get discNumber;
  @override
  int? get year;
  @override
  String? get genre;
  @override
  @JsonKey(name: 'cover_path')
  String? get coverPath;
  @override
  @JsonKey(name: 'lyrics_path')
  String? get lyricsPath;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  @JsonKey(name: 'play_count')
  int get playCount;
  @override
  @JsonKey(name: 'skip_count')
  int get skipCount;
  @override
  double get rating;
  @override
  @JsonKey(name: 'date_added')
  int get dateAdded;
  @override
  @JsonKey(name: 'date_modified')
  int get dateModified;
  @override
  @JsonKey(name: 'last_played')
  int? get lastPlayed;
  @override
  @JsonKey(ignore: true)
  _$$SongModelImplCopyWith<_$SongModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
