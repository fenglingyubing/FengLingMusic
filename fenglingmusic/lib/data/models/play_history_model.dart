import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_history_model.freezed.dart';
part 'play_history_model.g.dart';

/// PlayHistory data model
/// Tracks when and how songs are played
@freezed
class PlayHistoryModel with _$PlayHistoryModel {
  const factory PlayHistoryModel({
    int? id,
    @JsonKey(name: 'song_id') required int songId,
    @JsonKey(name: 'play_timestamp') required int playTimestamp,
    @JsonKey(name: 'play_duration') @Default(0) int playDuration,
    @JsonKey(name: 'completion_rate') @Default(0.0) double completionRate,
    String? source,
  }) = _PlayHistoryModel;

  factory PlayHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryModelFromJson(json);

  factory PlayHistoryModel.fromDatabase(Map<String, dynamic> map) {
    return PlayHistoryModel(
      id: map['id'] as int?,
      songId: map['song_id'] as int,
      playTimestamp: map['play_timestamp'] as int,
      playDuration: map['play_duration'] as int? ?? 0,
      completionRate: (map['completion_rate'] as num?)?.toDouble() ?? 0.0,
      source: map['source'] as String?,
    );
  }
}

extension PlayHistoryModelExtension on PlayHistoryModel {
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'song_id': songId,
      'play_timestamp': playTimestamp,
      'play_duration': playDuration,
      'completion_rate': completionRate,
      'source': source,
    };
  }
}
