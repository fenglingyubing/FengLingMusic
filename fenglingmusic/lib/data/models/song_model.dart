import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

/// Song data model
/// Represents a music file with its metadata
@freezed
class SongModel with _$SongModel {
  const factory SongModel({
    int? id,
    required String title,
    String? artist,
    String? album,
    @JsonKey(name: 'album_artist') String? albumArtist,
    @Default(0) int duration,
    @JsonKey(name: 'file_path') required String filePath,
    @JsonKey(name: 'file_size') @Default(0) int fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    @JsonKey(name: 'bit_rate') int? bitRate,
    @JsonKey(name: 'sample_rate') int? sampleRate,
    @JsonKey(name: 'track_number') int? trackNumber,
    @JsonKey(name: 'disc_number') int? discNumber,
    int? year,
    String? genre,
    @JsonKey(name: 'cover_path') String? coverPath,
    @JsonKey(name: 'lyrics_path') String? lyricsPath,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    @JsonKey(name: 'play_count') @Default(0) int playCount,
    @JsonKey(name: 'skip_count') @Default(0) int skipCount,
    @Default(0.0) double rating,
    @JsonKey(name: 'date_added') required int dateAdded,
    @JsonKey(name: 'date_modified') required int dateModified,
    @JsonKey(name: 'last_played') int? lastPlayed,
  }) = _SongModel;

  factory SongModel.fromJson(Map<String, dynamic> json) =>
      _$SongModelFromJson(json);

  /// Create from database map
  factory SongModel.fromDatabase(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      albumArtist: map['album_artist'] as String?,
      duration: map['duration'] as int? ?? 0,
      filePath: map['file_path'] as String,
      fileSize: map['file_size'] as int? ?? 0,
      mimeType: map['mime_type'] as String?,
      bitRate: map['bit_rate'] as int?,
      sampleRate: map['sample_rate'] as int?,
      trackNumber: map['track_number'] as int?,
      discNumber: map['disc_number'] as int?,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
      coverPath: map['cover_path'] as String?,
      lyricsPath: map['lyrics_path'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      playCount: map['play_count'] as int? ?? 0,
      skipCount: map['skip_count'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      dateAdded: map['date_added'] as int,
      dateModified: map['date_modified'] as int,
      lastPlayed: map['last_played'] as int?,
    );
  }
}

extension SongModelExtension on SongModel {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'album_artist': albumArtist,
      'duration': duration,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'bit_rate': bitRate,
      'sample_rate': sampleRate,
      'track_number': trackNumber,
      'disc_number': discNumber,
      'year': year,
      'genre': genre,
      'cover_path': coverPath,
      'lyrics_path': lyricsPath,
      'is_favorite': isFavorite ? 1 : 0,
      'play_count': playCount,
      'skip_count': skipCount,
      'rating': rating,
      'date_added': dateAdded,
      'date_modified': dateModified,
      'last_played': lastPlayed,
    };
  }

  /// Get formatted duration (MM:SS)
  String get formattedDuration {
    final int minutes = duration ~/ 60;
    final int seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get display artist (fallback to 'Unknown Artist')
  String get displayArtist => artist ?? 'Unknown Artist';

  /// Get display album (fallback to 'Unknown Album')
  String get displayAlbum => album ?? 'Unknown Album';
}
