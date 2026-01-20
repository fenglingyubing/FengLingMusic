// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaylistModelImpl _$$PlaylistModelImplFromJson(Map<String, dynamic> json) =>
    _$PlaylistModelImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      coverPath: json['cover_path'] as String?,
      songCount: (json['song_count'] as num?)?.toInt() ?? 0,
      totalDuration: (json['total_duration'] as num?)?.toInt() ?? 0,
      dateCreated: (json['date_created'] as num).toInt(),
      dateModified: (json['date_modified'] as num).toInt(),
    );

Map<String, dynamic> _$$PlaylistModelImplToJson(_$PlaylistModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cover_path': instance.coverPath,
      'song_count': instance.songCount,
      'total_duration': instance.totalDuration,
      'date_created': instance.dateCreated,
      'date_modified': instance.dateModified,
    };

_$PlaylistSongModelImpl _$$PlaylistSongModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlaylistSongModelImpl(
      id: (json['id'] as num?)?.toInt(),
      playlistId: (json['playlist_id'] as num).toInt(),
      songId: (json['song_id'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      dateAdded: (json['date_added'] as num).toInt(),
    );

Map<String, dynamic> _$$PlaylistSongModelImplToJson(
        _$PlaylistSongModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playlist_id': instance.playlistId,
      'song_id': instance.songId,
      'position': instance.position,
      'date_added': instance.dateAdded,
    };
