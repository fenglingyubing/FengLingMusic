import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../data/models/play_mode.dart';

/// TASK-119 & TASK-120: Android AudioHandler Implementation
///
/// 实现Android后台播放服务，包括：
/// - 前台服务通知
/// - 媒体会话管理
/// - 播放状态同步
/// - 媒体按钮响应
class FengLingAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  /// just_audio播放器实例
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 播放队列
  final List<MediaItem> _queue = [];

  /// 当前播放索引
  int _currentIndex = -1;

  /// 播放模式
  PlayMode _playMode = PlayMode.sequential;

  /// 当前歌曲流控制器
  final StreamController<SongModel?> _currentSongController =
      StreamController<SongModel?>.broadcast();

  /// 播放模式流控制器
  final StreamController<PlayMode> _playModeController =
      StreamController<PlayMode>.broadcast();

  FengLingAudioHandler() {
    _init();
  }

  void _init() {
    // 监听播放状态变化，同步到AudioService
    _audioPlayer.playbackEventStream.listen((event) {
      _broadcastPlaybackState();
    });

    // 监听播放完成事件
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    // 监听当前歌曲索引变化
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _queue.length) {
        mediaItem.add(_queue[index]);
      }
    });
  }

  /// 广播播放状态到系统
  void _broadcastPlaybackState() {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _getProcessingState(),
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: _currentIndex,
    ));
  }

  /// 获取处理状态
  AudioProcessingState _getProcessingState() {
    if (_audioPlayer.processingState == ProcessingState.loading ||
        _audioPlayer.processingState == ProcessingState.buffering) {
      return AudioProcessingState.loading;
    } else if (_audioPlayer.processingState == ProcessingState.ready) {
      return AudioProcessingState.ready;
    } else if (_audioPlayer.processingState == ProcessingState.completed) {
      return AudioProcessingState.completed;
    } else {
      return AudioProcessingState.idle;
    }
  }

  // ========== MediaHandler Methods ==========

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    final nextIndex = _getNextIndex();
    if (nextIndex != -1) {
      await skipToQueueItem(nextIndex);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final prevIndex = _getPreviousIndex();
    if (prevIndex != -1) {
      await skipToQueueItem(prevIndex);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      final mediaItem = _queue[index];

      // 设置音频源
      await _audioPlayer.setFilePath(mediaItem.extras!['filePath'] as String);

      // 更新当前媒体项
      this.mediaItem.add(mediaItem);

      // 开始播放
      await play();

      // 通知歌曲变化
      _notifySongChange();
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    queue.add(List.from(_queue));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    _queue.addAll(mediaItems);
    queue.add(List.from(_queue));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    _queue.insert(index, mediaItem);

    // 如果插入位置在当前播放位置之前，调整索引
    if (index <= _currentIndex) {
      _currentIndex++;
    }

    queue.add(List.from(_queue));
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = _queue.indexOf(mediaItem);
    if (index != -1) {
      await removeQueueItemAt(index);
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);

      // 如果移除的是当前播放的歌曲
      if (index == _currentIndex) {
        if (_queue.isNotEmpty) {
          if (_currentIndex >= _queue.length) {
            _currentIndex = _queue.length - 1;
          }
          await skipToQueueItem(_currentIndex);
        } else {
          await stop();
          _currentIndex = -1;
        }
      } else if (index < _currentIndex) {
        _currentIndex--;
      }

      queue.add(List.from(_queue));
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    super.setRepeatMode(repeatMode);

    // 转换为内部播放模式
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _playMode = PlayMode.sequential;
        break;
      case AudioServiceRepeatMode.one:
        _playMode = PlayMode.repeatOne;
        break;
      case AudioServiceRepeatMode.all:
        _playMode = PlayMode.repeatAll;
        break;
      case AudioServiceRepeatMode.group:
        _playMode = PlayMode.repeatAll;
        break;
    }

    _playModeController.add(_playMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    super.setShuffleMode(shuffleMode);

    if (shuffleMode == AudioServiceShuffleMode.all) {
      _playMode = PlayMode.shuffle;
      _playModeController.add(_playMode);
    }
  }

  // ========== Custom Methods ==========

  /// 设置播放列表
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    _queue.clear();
    _queue.addAll(songs.map((song) => _songToMediaItem(song)));
    _currentIndex = startIndex;

    // 更新队列
    queue.add(List.from(_queue));

    // 播放起始歌曲
    if (_queue.isNotEmpty && startIndex < _queue.length) {
      await skipToQueueItem(startIndex);
    }
  }

  /// 将SongModel转换为MediaItem
  MediaItem _songToMediaItem(SongModel song) {
    return MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      duration: Duration(milliseconds: song.duration),
      artUri: song.albumArtPath != null ? Uri.file(song.albumArtPath!) : null,
      extras: {
        'filePath': song.filePath,
        'songId': song.id,
      },
    );
  }

  /// 获取下一曲索引
  int _getNextIndex() {
    if (_queue.isEmpty) return -1;

    switch (_playMode) {
      case PlayMode.sequential:
        return _currentIndex + 1 < _queue.length ? _currentIndex + 1 : -1;
      case PlayMode.repeatAll:
        return (_currentIndex + 1) % _queue.length;
      case PlayMode.repeatOne:
        return _currentIndex;
      case PlayMode.shuffle:
        if (_queue.length == 1) return 0;
        int randomIndex;
        do {
          randomIndex = DateTime.now().millisecondsSinceEpoch % _queue.length;
        } while (randomIndex == _currentIndex);
        return randomIndex;
    }
  }

  /// 获取上一曲索引
  int _getPreviousIndex() {
    if (_queue.isEmpty) return -1;

    switch (_playMode) {
      case PlayMode.sequential:
        return _currentIndex > 0 ? _currentIndex - 1 : -1;
      case PlayMode.repeatAll:
        return _currentIndex > 0 ? _currentIndex - 1 : _queue.length - 1;
      case PlayMode.repeatOne:
        return _currentIndex;
      case PlayMode.shuffle:
        if (_queue.length == 1) return 0;
        int randomIndex;
        do {
          randomIndex = DateTime.now().millisecondsSinceEpoch % _queue.length;
        } while (randomIndex == _currentIndex);
        return randomIndex;
    }
  }

  /// 通知歌曲变化
  void _notifySongChange() {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      final mediaItem = _queue[_currentIndex];
      final song = SongModel(
        id: mediaItem.extras!['songId'] as int,
        title: mediaItem.title,
        artist: mediaItem.artist ?? 'Unknown Artist',
        album: mediaItem.album ?? 'Unknown Album',
        duration: mediaItem.duration?.inMilliseconds ?? 0,
        filePath: mediaItem.extras!['filePath'] as String,
        albumArtPath: mediaItem.artUri?.path,
        isFavorite: false,
        playCount: 0,
        addedDate: DateTime.now(),
      );
      _currentSongController.add(song);
    } else {
      _currentSongController.add(null);
    }
  }

  // ========== Getters ==========

  AudioPlayer get audioPlayer => _audioPlayer;
  int get currentIndex => _currentIndex;
  PlayMode get playMode => _playMode;
  List<MediaItem> get currentQueue => List.from(_queue);
  Stream<SongModel?> get currentSongStream => _currentSongController.stream;
  Stream<PlayMode> get playModeStream => _playModeController.stream;

  // ========== Cleanup ==========

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _audioPlayer.dispose();
      await _currentSongController.close();
      await _playModeController.close();
    }
    return super.customAction(name, extras);
  }
}
