// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArtistModelImpl _$$ArtistModelImplFromJson(Map<String, dynamic> json) =>
    _$ArtistModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      coverPath: json['cover_path'] as String?,
      songCount: (json['song_count'] as num?)?.toInt() ?? 0,
      albumCount: (json['album_count'] as num?)?.toInt() ?? 0,
      dateAdded: (json['date_added'] as num).toInt(),
    );

Map<String, dynamic> _$$ArtistModelImplToJson(_$ArtistModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cover_path': instance.coverPath,
      'song_count': instance.songCount,
      'album_count': instance.albumCount,
      'date_added': instance.dateAdded,
    };
