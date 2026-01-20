// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DownloadItemModelImpl _$$DownloadItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadItemModelImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      sourceUrl: json['source_url'] as String,
      targetPath: json['target_path'] as String,
      fileSize: (json['file_size'] as num?)?.toInt(),
      downloadedSize: (json['downloaded_size'] as num?)?.toInt() ?? 0,
      status: $enumDecodeNullable(_$DownloadStatusEnumMap, json['status']) ??
          DownloadStatus.pending,
      errorMessage: json['error_message'] as String?,
      quality: json['quality'] as String?,
      dateAdded: (json['date_added'] as num).toInt(),
      dateStarted: (json['date_started'] as num?)?.toInt(),
      dateCompleted: (json['date_completed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DownloadItemModelImplToJson(
        _$DownloadItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'source_url': instance.sourceUrl,
      'target_path': instance.targetPath,
      'file_size': instance.fileSize,
      'downloaded_size': instance.downloadedSize,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'error_message': instance.errorMessage,
      'quality': instance.quality,
      'date_added': instance.dateAdded,
      'date_started': instance.dateStarted,
      'date_completed': instance.dateCompleted,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.pending: 'pending',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.paused: 'paused',
  DownloadStatus.completed: 'completed',
  DownloadStatus.failed: 'failed',
  DownloadStatus.cancelled: 'cancelled',
};
