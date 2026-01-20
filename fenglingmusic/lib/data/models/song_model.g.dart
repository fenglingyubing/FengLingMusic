// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongModelImpl _$$SongModelImplFromJson(Map<String, dynamic> json) =>
    _$SongModelImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      albumArtist: json['album_artist'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      filePath: json['file_path'] as String,
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      mimeType: json['mime_type'] as String?,
      bitRate: (json['bit_rate'] as num?)?.toInt(),
      sampleRate: (json['sample_rate'] as num?)?.toInt(),
      trackNumber: (json['track_number'] as num?)?.toInt(),
      discNumber: (json['disc_number'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      coverPath: json['cover_path'] as String?,
      lyricsPath: json['lyrics_path'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      playCount: (json['play_count'] as num?)?.toInt() ?? 0,
      skipCount: (json['skip_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      dateAdded: (json['date_added'] as num).toInt(),
      dateModified: (json['date_modified'] as num).toInt(),
      lastPlayed: (json['last_played'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SongModelImplToJson(_$SongModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'album_artist': instance.albumArtist,
      'duration': instance.duration,
      'file_path': instance.filePath,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'bit_rate': instance.bitRate,
      'sample_rate': instance.sampleRate,
      'track_number': instance.trackNumber,
      'disc_number': instance.discNumber,
      'year': instance.year,
      'genre': instance.genre,
      'cover_path': instance.coverPath,
      'lyrics_path': instance.lyricsPath,
      'is_favorite': instance.isFavorite,
      'play_count': instance.playCount,
      'skip_count': instance.skipCount,
      'rating': instance.rating,
      'date_added': instance.dateAdded,
      'date_modified': instance.dateModified,
      'last_played': instance.lastPlayed,
    };
