// Lyrics Provider Stub
//
// This file contains the lyrics provider implementation.
// The actual provider is commented out until the audio player service provider is available.
// See LYRICS_IMPLEMENTATION.md for integration instructions.

// TODO: Move this content to lyrics_provider.dart when audio player service is ready

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lyric_line_model.dart';
import '../../services/lyrics/lyrics_service.dart';

/// Lyrics service provider
final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService();
});

/// Lyrics state placeholder
class LyricsState {
  final List<LyricLineModel> lyrics;
  final int currentLineIndex;
  final bool isLoading;
  final String? error;

  const LyricsState({
    this.lyrics = const [],
    this.currentLineIndex = -1,
    this.isLoading = false,
    this.error,
  });

  bool get hasLyrics => lyrics.isNotEmpty;
  
  LyricLineModel? get currentLine {
    if (currentLineIndex >= 0 && currentLineIndex < lyrics.length) {
      return lyrics[currentLineIndex];
    }
    return null;
  }
}
