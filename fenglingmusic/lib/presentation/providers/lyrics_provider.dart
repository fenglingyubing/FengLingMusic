import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/lyric_line_model.dart';
import '../../data/models/song_model.dart';
import '../../data/models/online_song.dart';
import '../../services/lyrics/lyrics_service.dart';
import '../../services/audio/audio_player_service.dart';

/// Lyrics service provider
final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService();
});

/// Lyrics state
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

  LyricsState copyWith({
    List<LyricLineModel>? lyrics,
    int? currentLineIndex,
    bool? isLoading,
    String? error,
  }) {
    return LyricsState(
      lyrics: lyrics ?? this.lyrics,
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get current lyric line
  LyricLineModel? get currentLine {
    if (currentLineIndex >= 0 && currentLineIndex < lyrics.length) {
      return lyrics[currentLineIndex];
    }
    return null;
  }

  /// Check if lyrics are available
  bool get hasLyrics => lyrics.isNotEmpty;
}

/// Lyrics controller
///
/// 管理歌词加载、同步和状态
class LyricsController extends StateNotifier<LyricsState> {
  final LyricsService _lyricsService;
  final AudioPlayerService _audioPlayerService;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<SongModel?>? _songSubscription;

  SongModel? _currentSong;
  OnlineSong? _currentOnlineSong;

  LyricsController(this._lyricsService, this._audioPlayerService)
      : super(const LyricsState()) {
    _initialize();
  }

  /// Initialize the controller
  Future<void> _initialize() async {
    // Initialize lyrics service with cache directory
    final cacheDir = await getApplicationSupportDirectory();
    await _lyricsService.initialize('${cacheDir.path}/lyrics');

    // Listen to position changes for lyrics synchronization
    _positionSubscription = _audioPlayerService.positionStream.listen(_onPositionChanged);

    // Listen to song changes to load new lyrics
    _songSubscription = _audioPlayerService.currentSongStream.listen(_onSongChanged);

    // Load lyrics for current song if any
    final currentSong = _audioPlayerService.currentSong;
    if (currentSong != null) {
      await loadLyrics(song: currentSong);
    }
  }

  /// Handle position changes - sync lyrics
  void _onPositionChanged(Duration position) {
    if (!state.hasLyrics) return;

    final int positionMs = position.inMilliseconds;

    // Find the current lyric line based on position
    int newLineIndex = -1;
    for (int i = state.lyrics.length - 1; i >= 0; i--) {
      if (positionMs >= state.lyrics[i].timestamp) {
        newLineIndex = i;
        break;
      }
    }

    // Update current line if changed
    if (newLineIndex != state.currentLineIndex) {
      state = state.copyWith(currentLineIndex: newLineIndex);
    }
  }

  /// Handle song changes - load new lyrics
  Future<void> _onSongChanged(SongModel? song) async {
    if (song == null) {
      clearLyrics();
      return;
    }

    _currentSong = song;
    _currentOnlineSong = null;
    await loadLyrics(song: song);
  }

  /// Load lyrics for a song
  ///
  /// [song] Local song
  /// [onlineSong] Online song (for online playback)
  Future<void> loadLyrics({
    SongModel? song,
    OnlineSong? onlineSong,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final lyrics = await _lyricsService.getLyrics(
        song: song,
        onlineSong: onlineSong,
      );

      _currentSong = song;
      _currentOnlineSong = onlineSong;

      state = state.copyWith(
        lyrics: lyrics,
        currentLineIndex: -1,
        isLoading: false,
      );

      // Sync to current position
      final position = _audioPlayerService.position;
      _onPositionChanged(position);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load lyrics: $e',
      );
    }
  }

  /// Reload current lyrics
  Future<void> reloadLyrics() async {
    if (_currentSong != null || _currentOnlineSong != null) {
      await loadLyrics(
        song: _currentSong,
        onlineSong: _currentOnlineSong,
      );
    }
  }

  /// Clear lyrics
  void clearLyrics() {
    state = const LyricsState();
    _currentSong = null;
    _currentOnlineSong = null;
  }

  /// Seek to a specific lyric line
  ///
  /// [index] Index of the lyric line
  Future<void> seekToLine(int index) async {
    if (index < 0 || index >= state.lyrics.length) return;

    final timestamp = state.lyrics[index].timestamp;
    await _audioPlayerService.seek(Duration(milliseconds: timestamp));
  }

  /// Get line index at specific timestamp
  int getLineIndexAtTime(int timestampMs) {
    for (int i = state.lyrics.length - 1; i >= 0; i--) {
      if (timestampMs >= state.lyrics[i].timestamp) {
        return i;
      }
    }
    return -1;
  }

  /// Clear lyrics cache
  Future<void> clearCache() async {
    await _lyricsService.clearAllCache();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _songSubscription?.cancel();
    super.dispose();
  }
}

/// Lyrics controller provider
final lyricsControllerProvider = StateNotifierProvider<LyricsController, LyricsState>((ref) {
  // Get dependencies
  final lyricsService = ref.watch(lyricsServiceProvider);

  // TODO: Replace with actual audio player service provider
  // This is a placeholder - you need to provide the actual audio player service
  throw UnimplementedError('Audio player service provider not configured');

  // When implemented, should be:
  // final audioPlayerService = ref.watch(audioPlayerServiceProvider);
  // return LyricsController(lyricsService, audioPlayerService);
});

/// Current lyric line provider (convenience)
final currentLyricLineProvider = Provider<LyricLineModel?>((ref) {
  final state = ref.watch(lyricsControllerProvider);
  return state.currentLine;
});

/// Has lyrics provider (convenience)
final hasLyricsProvider = Provider<bool>((ref) {
  final state = ref.watch(lyricsControllerProvider);
  return state.hasLyrics;
});
