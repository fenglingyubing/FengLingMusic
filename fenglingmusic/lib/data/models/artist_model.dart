import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist_model.freezed.dart';
part 'artist_model.g.dart';

/// Artist data model
@freezed
class ArtistModel with _$ArtistModel {
  const factory ArtistModel({
    int? id,
    required String name,
    @JsonKey(name: 'cover_path') String? coverPath,
    @JsonKey(name: 'song_count') @Default(0) int songCount,
    @JsonKey(name: 'album_count') @Default(0) int albumCount,
    @JsonKey(name: 'date_added') required int dateAdded,
  }) = _ArtistModel;

  factory ArtistModel.fromJson(Map<String, dynamic> json) =>
      _$ArtistModelFromJson(json);

  factory ArtistModel.fromDatabase(Map<String, dynamic> map) {
    return ArtistModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      coverPath: map['cover_path'] as String?,
      songCount: map['song_count'] as int? ?? 0,
      albumCount: map['album_count'] as int? ?? 0,
      dateAdded: map['date_added'] as int,
    );
  }
}

extension ArtistModelExtension on ArtistModel {
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'cover_path': coverPath,
      'song_count': songCount,
      'album_count': albumCount,
      'date_added': dateAdded,
    };
  }
}
