import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../data/models/play_mode.dart';
import 'audio_player_service.dart';

/// AudioPlayerService 的实现类
///
/// 使用 just_audio 包提供完整的音频播放功能
/// 包含：
/// - TASK-025: 基础播放功能（播放、暂停、停止、跳转、音量）
/// - TASK-026: 播放队列管理
/// - TASK-027: 播放状态管理（Stream）
class AudioPlayerServiceImpl implements AudioPlayerService {
  /// just_audio 播放器实例
  final AudioPlayer _audioPlayer;

  /// 播放队列
  final List<SongModel> _queue = [];

  /// 当前播放模式
  PlayMode _playMode = PlayMode.sequential;

  /// 当前播放索引
  int _currentIndex = -1;

  /// 当前播放的歌曲
  SongModel? _currentSong;

  /// 当前歌曲流控制器
  final StreamController<SongModel?> _currentSongController =
      StreamController<SongModel?>.broadcast();

  /// 播放队列流控制器
  final StreamController<List<SongModel>> _queueController =
      StreamController<List<SongModel>>.broadcast();

  /// 播放模式流控制器
  final StreamController<PlayMode> _playModeController =
      StreamController<PlayMode>.broadcast();

  /// 构造函数
  AudioPlayerServiceImpl() : _audioPlayer = AudioPlayer() {
    // 监听播放完成事件，自动播放下一曲
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
    });
  }

  // ========== TASK-025: 基础播放控制 ==========

  @override
  Future<bool> play(SongModel song) async {
    try {
      _currentSong = song;
      _currentSongController.add(song);

      // 设置音频源
      await _audioPlayer.setFilePath(song.filePath);

      // 开始播放
      await _audioPlayer.play();

      return true;
    } catch (e) {
      debugPrint('Error playing song: $e');
      return false;
    }
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _currentSongController.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // ========== 音量控制 ==========

  @override
  Future<void> setVolume(double volume) async {
    // 确保音量在 0.0 - 1.0 范围内
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clampedVolume);
  }

  @override
  double getVolume() {
    return _audioPlayer.volume;
  }

  // ========== TASK-026: 播放队列管理 ==========

  @override
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    _queue.clear();
    _queue.addAll(songs);
    _currentIndex = startIndex;
    _queueController.add(List.from(_queue));

    // 如果有歌曲，播放起始歌曲
    if (_queue.isNotEmpty && startIndex < _queue.length) {
      await play(_queue[startIndex]);
    }
  }

  @override
  void addToQueue(SongModel song) {
    _queue.add(song);
    _queueController.add(List.from(_queue));
  }

  @override
  void insertToQueue(int index, SongModel song) {
    if (index >= 0 && index <= _queue.length) {
      _queue.insert(index, song);

      // 如果插入位置在当前播放位置之前，需要调整当前索引
      if (index <= _currentIndex) {
        _currentIndex++;
      }

      _queueController.add(List.from(_queue));
    }
  }

  @override
  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);

      // 如果移除的是当前播放的歌曲
      if (index == _currentIndex) {
        // 如果还有歌曲，播放下一曲
        if (_queue.isNotEmpty) {
          // 调整索引，确保不越界
          if (_currentIndex >= _queue.length) {
            _currentIndex = _queue.length - 1;
          }
          play(_queue[_currentIndex]);
        } else {
          stop();
          _currentIndex = -1;
        }
      } else if (index < _currentIndex) {
        // 如果移除的歌曲在当前播放位置之前，调整索引
        _currentIndex--;
      }

      _queueController.add(List.from(_queue));
    }
  }

  @override
  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    stop();
    _queueController.add(List.from(_queue));
  }

  @override
  List<SongModel> getQueue() {
    return List.from(_queue);
  }

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    int nextIndex = _getNextIndex();
    if (nextIndex != -1) {
      _currentIndex = nextIndex;
      await play(_queue[_currentIndex]);
    } else {
      // 没有下一曲，停止播放
      await stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;

    int previousIndex = _getPreviousIndex();
    if (previousIndex != -1) {
      _currentIndex = previousIndex;
      await play(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      await play(_queue[_currentIndex]);
    }
  }

  // ========== 播放模式 ==========

  @override
  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    _playModeController.add(mode);
  }

  @override
  PlayMode getPlayMode() {
    return _playMode;
  }

  // ========== 状态获取 ==========

  @override
  bool get isPlaying => _audioPlayer.playing;

  @override
  SongModel? get currentSong => _currentSong;

  @override
  Duration get position => _audioPlayer.position;

  @override
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  @override
  int get currentIndex => _currentIndex;

  // ========== TASK-027: 状态流（Stream）==========

  @override
  Stream<bool> get playingStream =>
      _audioPlayer.playingStream;

  @override
  Stream<SongModel?> get currentSongStream => _currentSongController.stream;

  @override
  Stream<Duration> get positionStream =>
      _audioPlayer.positionStream;

  @override
  Stream<Duration> get durationStream =>
      _audioPlayer.durationStream.map((duration) => duration ?? Duration.zero);

  @override
  Stream<List<SongModel>> get queueStream => _queueController.stream;

  @override
  Stream<PlayMode> get playModeStream => _playModeController.stream;

  // ========== 内部辅助方法 ==========

  /// 获取下一曲的索引
  ///
  /// 根据播放模式返回下一曲的索引
  /// 返回 -1 表示没有下一曲
  int _getNextIndex() {
    if (_queue.isEmpty) return -1;

    switch (_playMode) {
      case PlayMode.sequential:
        // 顺序播放：如果是最后一曲，返回 -1
        return _currentIndex + 1 < _queue.length ? _currentIndex + 1 : -1;

      case PlayMode.repeatAll:
        // 列表循环：循环到第一曲
        return (_currentIndex + 1) % _queue.length;

      case PlayMode.repeatOne:
        // 单曲循环：返回当前索引
        return _currentIndex;

      case PlayMode.shuffle:
        // 随机播放：随机选择一曲（不包括当前曲）
        if (_queue.length == 1) return 0;
        int randomIndex;
        do {
          randomIndex = DateTime.now().millisecondsSinceEpoch % _queue.length;
        } while (randomIndex == _currentIndex);
        return randomIndex;
    }
  }

  /// 获取上一曲的索引
  ///
  /// 返回 -1 表示没有上一曲
  int _getPreviousIndex() {
    if (_queue.isEmpty) return -1;

    switch (_playMode) {
      case PlayMode.sequential:
        // 顺序播放：如果是第一曲，返回 -1
        return _currentIndex > 0 ? _currentIndex - 1 : -1;

      case PlayMode.repeatAll:
        // 列表循环：循环到最后一曲
        return _currentIndex > 0 ? _currentIndex - 1 : _queue.length - 1;

      case PlayMode.repeatOne:
        // 单曲循环：返回当前索引
        return _currentIndex;

      case PlayMode.shuffle:
        // 随机播放：随机选择一曲（不包括当前曲）
        if (_queue.length == 1) return 0;
        int randomIndex;
        do {
          randomIndex = DateTime.now().millisecondsSinceEpoch % _queue.length;
        } while (randomIndex == _currentIndex);
        return randomIndex;
    }
  }

  /// 当前歌曲播放完成时的回调
  void _onSongCompleted() {
    // 自动播放下一曲
    skipToNext();
  }

  // ========== 资源管理 ==========

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _currentSongController.close();
    await _queueController.close();
    await _playModeController.close();
  }
}
