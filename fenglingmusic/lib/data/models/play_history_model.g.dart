// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayHistoryModelImpl _$$PlayHistoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlayHistoryModelImpl(
      id: (json['id'] as num?)?.toInt(),
      songId: (json['song_id'] as num).toInt(),
      playTimestamp: (json['play_timestamp'] as num).toInt(),
      playDuration: (json['play_duration'] as num?)?.toInt() ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$$PlayHistoryModelImplToJson(
        _$PlayHistoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'song_id': instance.songId,
      'play_timestamp': instance.playTimestamp,
      'play_duration': instance.playDuration,
      'completion_rate': instance.completionRate,
      'source': instance.source,
    };
