import 'dart:async';
import 'package:audio_service/audio_service.dart';
import '../../data/models/song_model.dart';
import '../../data/models/play_mode.dart';
import 'audio_player_service.dart';
import 'android_audio_handler.dart';

/// TASK-119, TASK-120, TASK-121, TASK-122, TASK-123
/// Android平台音频服务实现
///
/// 功能包括：
/// - 后台播放服务
/// - 媒体通知
/// - 锁屏控制
/// - 耳机线控支持
class AndroidAudioPlayerService implements AudioPlayerService {
  FengLingAudioHandler? _audioHandler;
  bool _initialized = false;

  /// 初始化Audio Service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _audioHandler = await AudioService.init(
        builder: () => FengLingAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.fenglingmusic.channel.audio',
          androidNotificationChannelName: 'FengLing Music',
          androidNotificationChannelDescription: 'FengLing Music Player Controls',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: false,
          androidNotificationClickStartsActivity: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          fastForwardInterval: Duration(seconds: 10),
          rewindInterval: Duration(seconds: 10),
        ),
      );
      _initialized = true;
    } catch (e) {
      print('Error initializing AudioService: $e');
      rethrow;
    }
  }

  FengLingAudioHandler get _handler {
    if (_audioHandler == null) {
      throw StateError('AudioService not initialized. Call initialize() first.');
    }
    return _audioHandler!;
  }

  // ========== TASK-025: 基础播放控制 ==========

  @override
  Future<bool> play(SongModel song) async {
    try {
      // 如果队列为空，创建一个包含当前歌曲的队列
      if (_handler.currentQueue.isEmpty) {
        await _handler.setPlaylist([song]);
      } else {
        // 查找歌曲在队列中的位置
        final index = _handler.currentQueue.indexWhere(
          (item) => item.extras!['songId'] == song.id,
        );

        if (index != -1) {
          // 歌曲在队列中，跳转到该歌曲
          await _handler.skipToQueueItem(index);
        } else {
          // 歌曲不在队列中，添加并播放
          await _handler.addQueueItem(_handler._songToMediaItem(song));
          await _handler.skipToQueueItem(_handler.currentQueue.length - 1);
        }
      }

      await _handler.play();
      return true;
    } catch (e) {
      print('Error playing song: $e');
      return false;
    }
  }

  @override
  Future<void> pause() async {
    await _handler.pause();
  }

  @override
  Future<void> resume() async {
    await _handler.play();
  }

  @override
  Future<void> stop() async {
    await _handler.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _handler.seek(position);
  }

  // ========== 音量控制 ==========

  @override
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _handler.audioPlayer.setVolume(clampedVolume);
  }

  @override
  double getVolume() {
    return _handler.audioPlayer.volume;
  }

  // ========== TASK-026: 播放队列管理 ==========

  @override
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    await _handler.setPlaylist(songs, startIndex: startIndex);
  }

  @override
  void addToQueue(SongModel song) {
    _handler.addQueueItem(_handler._songToMediaItem(song));
  }

  @override
  void insertToQueue(int index, SongModel song) {
    _handler.insertQueueItem(index, _handler._songToMediaItem(song));
  }

  @override
  void removeFromQueue(int index) {
    _handler.removeQueueItemAt(index);
  }

  @override
  void clearQueue() {
    // 清空队列并停止播放
    final queueLength = _handler.currentQueue.length;
    for (int i = queueLength - 1; i >= 0; i--) {
      _handler.removeQueueItemAt(i);
    }
  }

  @override
  List<SongModel> getQueue() {
    return _handler.currentQueue.map((item) {
      return SongModel(
        id: item.extras!['songId'] as int,
        title: item.title,
        artist: item.artist ?? 'Unknown Artist',
        album: item.album ?? 'Unknown Album',
        duration: item.duration?.inMilliseconds ?? 0,
        filePath: item.extras!['filePath'] as String,
        albumArtPath: item.artUri?.path,
        isFavorite: false,
        playCount: 0,
        addedDate: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> skipToNext() async {
    await _handler.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _handler.skipToPrevious();
  }

  @override
  Future<void> skipToIndex(int index) async {
    await _handler.skipToQueueItem(index);
  }

  // ========== 播放模式 ==========

  @override
  void setPlayMode(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequential:
        _handler.setRepeatMode(AudioServiceRepeatMode.none);
        _handler.setShuffleMode(AudioServiceShuffleMode.none);
        break;
      case PlayMode.repeatAll:
        _handler.setRepeatMode(AudioServiceRepeatMode.all);
        _handler.setShuffleMode(AudioServiceShuffleMode.none);
        break;
      case PlayMode.repeatOne:
        _handler.setRepeatMode(AudioServiceRepeatMode.one);
        _handler.setShuffleMode(AudioServiceShuffleMode.none);
        break;
      case PlayMode.shuffle:
        _handler.setRepeatMode(AudioServiceRepeatMode.none);
        _handler.setShuffleMode(AudioServiceShuffleMode.all);
        break;
    }
  }

  @override
  PlayMode getPlayMode() {
    return _handler.playMode;
  }

  // ========== 状态获取 ==========

  @override
  bool get isPlaying => _handler.audioPlayer.playing;

  @override
  SongModel? get currentSong {
    final index = _handler.currentIndex;
    if (index >= 0 && index < _handler.currentQueue.length) {
      final item = _handler.currentQueue[index];
      return SongModel(
        id: item.extras!['songId'] as int,
        title: item.title,
        artist: item.artist ?? 'Unknown Artist',
        album: item.album ?? 'Unknown Album',
        duration: item.duration?.inMilliseconds ?? 0,
        filePath: item.extras!['filePath'] as String,
        albumArtPath: item.artUri?.path,
        isFavorite: false,
        playCount: 0,
        addedDate: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Duration get position => _handler.audioPlayer.position;

  @override
  Duration get duration => _handler.audioPlayer.duration ?? Duration.zero;

  @override
  int get currentIndex => _handler.currentIndex;

  // ========== TASK-027: 状态流（Stream）==========

  @override
  Stream<bool> get playingStream => _handler.audioPlayer.playingStream;

  @override
  Stream<SongModel?> get currentSongStream => _handler.currentSongStream;

  @override
  Stream<Duration> get positionStream => _handler.audioPlayer.positionStream;

  @override
  Stream<Duration> get durationStream =>
      _handler.audioPlayer.durationStream.map((duration) => duration ?? Duration.zero);

  @override
  Stream<List<SongModel>> get queueStream =>
      _handler.queue.map((queue) => queue.map((item) {
        return SongModel(
          id: item.extras!['songId'] as int,
          title: item.title,
          artist: item.artist ?? 'Unknown Artist',
          album: item.album ?? 'Unknown Album',
          duration: item.duration?.inMilliseconds ?? 0,
          filePath: item.extras!['filePath'] as String,
          albumArtPath: item.artUri?.path,
          isFavorite: false,
          playCount: 0,
          addedDate: DateTime.now(),
        );
      }).toList());

  @override
  Stream<PlayMode> get playModeStream => _handler.playModeStream;

  // ========== 资源管理 ==========

  @override
  Future<void> dispose() async {
    await _handler.customAction('dispose');
  }
}
