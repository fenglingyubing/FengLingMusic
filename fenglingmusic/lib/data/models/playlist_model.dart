import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_model.freezed.dart';
part 'playlist_model.g.dart';

/// Playlist data model
/// Represents a user-created playlist
@freezed
class PlaylistModel with _$PlaylistModel {
  const factory PlaylistModel({
    int? id,
    required String name,
    String? description,
    @JsonKey(name: 'cover_path') String? coverPath,
    @JsonKey(name: 'song_count') @Default(0) int songCount,
    @JsonKey(name: 'total_duration') @Default(0) int totalDuration,
    @JsonKey(name: 'date_created') required int dateCreated,
    @JsonKey(name: 'date_modified') required int dateModified,
  }) = _PlaylistModel;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistModelFromJson(json);

  /// Create from database map
  factory PlaylistModel.fromDatabase(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverPath: map['cover_path'] as String?,
      songCount: map['song_count'] as int? ?? 0,
      totalDuration: map['total_duration'] as int? ?? 0,
      dateCreated: map['date_created'] as int,
      dateModified: map['date_modified'] as int,
    );
  }
}

extension PlaylistModelExtension on PlaylistModel {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'cover_path': coverPath,
      'song_count': songCount,
      'total_duration': totalDuration,
      'date_created': dateCreated,
      'date_modified': dateModified,
    };
  }

  /// Get formatted total duration (HH:MM:SS or MM:SS)
  String get formattedDuration {
    final int hours = totalDuration ~/ 3600;
    final int minutes = (totalDuration % 3600) ~/ 60;
    final int seconds = totalDuration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

/// PlaylistSong data model
/// Links songs to playlists with position information
@freezed
class PlaylistSongModel with _$PlaylistSongModel {
  const factory PlaylistSongModel({
    int? id,
    @JsonKey(name: 'playlist_id') required int playlistId,
    @JsonKey(name: 'song_id') required int songId,
    required int position,
    @JsonKey(name: 'date_added') required int dateAdded,
  }) = _PlaylistSongModel;

  factory PlaylistSongModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSongModelFromJson(json);

  /// Create from database map
  factory PlaylistSongModel.fromDatabase(Map<String, dynamic> map) {
    return PlaylistSongModel(
      id: map['id'] as int?,
      playlistId: map['playlist_id'] as int,
      songId: map['song_id'] as int,
      position: map['position'] as int,
      dateAdded: map['date_added'] as int,
    );
  }
}

extension PlaylistSongModelExtension on PlaylistSongModel {
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'playlist_id': playlistId,
      'song_id': songId,
      'position': position,
      'date_added': dateAdded,
    };
  }
}
