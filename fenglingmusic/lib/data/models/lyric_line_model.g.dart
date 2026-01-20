// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyric_line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LyricLineModelImpl _$$LyricLineModelImplFromJson(Map<String, dynamic> json) =>
    _$LyricLineModelImpl(
      timestamp: (json['timestamp'] as num).toInt(),
      text: json['text'] as String,
      translation: json['translation'] as String?,
    );

Map<String, dynamic> _$$LyricLineModelImplToJson(
        _$LyricLineModelImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'text': instance.text,
      'translation': instance.translation,
    };
