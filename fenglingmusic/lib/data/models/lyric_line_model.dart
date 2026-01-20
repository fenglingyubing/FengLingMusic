import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyric_line_model.freezed.dart';
part 'lyric_line_model.g.dart';

/// LyricLine data model
/// Represents a single line of lyrics with timing information
@freezed
class LyricLineModel with _$LyricLineModel {
  const factory LyricLineModel({
    required int timestamp,
    required String text,
    String? translation,
  }) = _LyricLineModel;

  factory LyricLineModel.fromJson(Map<String, dynamic> json) =>
      _$LyricLineModelFromJson(json);
}

extension LyricLineModelExtension on LyricLineModel {
  /// Get formatted timestamp (MM:SS.mm)
  String get formattedTimestamp {
    final int totalMs = timestamp;
    final int minutes = totalMs ~/ 60000;
    final int seconds = (totalMs % 60000) ~/ 1000;
    final int milliseconds = (totalMs % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}';
  }
}
