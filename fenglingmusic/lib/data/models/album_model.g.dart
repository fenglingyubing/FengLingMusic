// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlbumModelImpl _$$AlbumModelImplFromJson(Map<String, dynamic> json) =>
    _$AlbumModelImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      artist: json['artist'] as String?,
      albumArtist: json['album_artist'] as String?,
      year: (json['year'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      coverPath: json['cover_path'] as String?,
      songCount: (json['song_count'] as num?)?.toInt() ?? 0,
      totalDuration: (json['total_duration'] as num?)?.toInt() ?? 0,
      dateAdded: (json['date_added'] as num).toInt(),
    );

Map<String, dynamic> _$$AlbumModelImplToJson(_$AlbumModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album_artist': instance.albumArtist,
      'year': instance.year,
      'genre': instance.genre,
      'cover_path': instance.coverPath,
      'song_count': instance.songCount,
      'total_duration': instance.totalDuration,
      'date_added': instance.dateAdded,
    };
