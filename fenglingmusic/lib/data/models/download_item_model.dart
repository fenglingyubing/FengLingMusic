import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_item_model.freezed.dart';
part 'download_item_model.g.dart';

/// Download item status
enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// DownloadItem data model
/// Represents an item in the download queue
@freezed
class DownloadItemModel with _$DownloadItemModel {
  const factory DownloadItemModel({
    int? id,
    required String title,
    String? artist,
    String? album,
    @JsonKey(name: 'source_url') required String sourceUrl,
    @JsonKey(name: 'target_path') required String targetPath,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'downloaded_size') @Default(0) int downloadedSize,
    @Default(DownloadStatus.pending) DownloadStatus status,
    @JsonKey(name: 'error_message') String? errorMessage,
    String? quality,
    @JsonKey(name: 'date_added') required int dateAdded,
    @JsonKey(name: 'date_started') int? dateStarted,
    @JsonKey(name: 'date_completed') int? dateCompleted,
  }) = _DownloadItemModel;

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadItemModelFromJson(json);

  factory DownloadItemModel.fromDatabase(Map<String, dynamic> map) {
    return DownloadItemModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      sourceUrl: map['source_url'] as String,
      targetPath: map['target_path'] as String,
      fileSize: map['file_size'] as int?,
      downloadedSize: map['downloaded_size'] as int? ?? 0,
      status: _statusFromString(map['status'] as String?),
      errorMessage: map['error_message'] as String?,
      quality: map['quality'] as String?,
      dateAdded: map['date_added'] as int,
      dateStarted: map['date_started'] as int?,
      dateCompleted: map['date_completed'] as int?,
    );
  }

  static DownloadStatus _statusFromString(String? status) {
    switch (status) {
      case 'downloading':
        return DownloadStatus.downloading;
      case 'paused':
        return DownloadStatus.paused;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      case 'cancelled':
        return DownloadStatus.cancelled;
      default:
        return DownloadStatus.pending;
    }
  }
}

extension DownloadItemModelExtension on DownloadItemModel {
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'source_url': sourceUrl,
      'target_path': targetPath,
      'file_size': fileSize,
      'downloaded_size': downloadedSize,
      'status': status.name,
      'error_message': errorMessage,
      'quality': quality,
      'date_added': dateAdded,
      'date_started': dateStarted,
      'date_completed': dateCompleted,
    };
  }

  /// Calculate download progress (0.0 - 1.0)
  double get progress {
    if (fileSize == null || fileSize! <= 0) return 0.0;
    return downloadedSize / fileSize!;
  }

  /// Get progress percentage (0-100)
  int get progressPercentage {
    return (progress * 100).round();
  }
}
