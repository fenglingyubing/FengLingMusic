import 'package:freezed_annotation/freezed_annotation.dart';

part 'album_model.freezed.dart';
part 'album_model.g.dart';

/// Album data model
@freezed
class AlbumModel with _$AlbumModel {
  const factory AlbumModel({
    int? id,
    required String title,
    String? artist,
    @JsonKey(name: 'album_artist') String? albumArtist,
    int? year,
    String? genre,
    @JsonKey(name: 'cover_path') String? coverPath,
    @JsonKey(name: 'song_count') @Default(0) int songCount,
    @JsonKey(name: 'total_duration') @Default(0) int totalDuration,
    @JsonKey(name: 'date_added') required int dateAdded,
  }) = _AlbumModel;

  factory AlbumModel.fromJson(Map<String, dynamic> json) =>
      _$AlbumModelFromJson(json);

  factory AlbumModel.fromDatabase(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      albumArtist: map['album_artist'] as String?,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
      coverPath: map['cover_path'] as String?,
      songCount: map['song_count'] as int? ?? 0,
      totalDuration: map['total_duration'] as int? ?? 0,
      dateAdded: map['date_added'] as int,
    );
  }
}

extension AlbumModelExtension on AlbumModel {
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'artist': artist,
      'album_artist': albumArtist,
      'year': year,
      'genre': genre,
      'cover_path': coverPath,
      'song_count': songCount,
      'total_duration': totalDuration,
      'date_added': dateAdded,
    };
  }

  String get displayArtist => albumArtist ?? artist ?? 'Unknown Artist';
}
