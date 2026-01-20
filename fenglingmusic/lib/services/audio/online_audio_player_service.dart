import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/song_model.dart';
import '../../data/models/online_song.dart';
import 'audio_player_service_enhanced.dart';
import '../online/online_play_service.dart';
import '../online/play_cache_service.dart';

/// 在线音频播放器服务
///
/// TASK-089: 集成在线播放到播放器
/// 功能：
/// - 在线歌曲播放
/// - 与本地播放无缝切换
/// - 混合播放队列（本地+在线）
/// - 自动缓存在线歌曲
class OnlineAudioPlayerService extends AudioPlayerServiceEnhanced {
  /// 在线播放服务
  final OnlinePlayService _onlinePlayService = OnlinePlayService();

  /// 播放缓存服务
  final PlayCacheService _cacheService = PlayCacheService();

  /// 在线歌曲映射 - 存储在线歌曲信息（songId -> OnlineSong）
  final Map<String, OnlineSong> _onlineSongMap = {};

  /// 默认音质
  String _defaultQuality = 'standard';

  /// 是否启用自动缓存
  bool _autoCacheEnabled = true;

  /// 构造函数
  OnlineAudioPlayerService() {
    // 初始化缓存服务
    _cacheService.initialize();
  }

  /// 播放在线歌曲
  ///
  /// [song] 在线歌曲对象
  /// [quality] 音质等级，默认使用设置的默认音质
  ///
  /// 返回是否成功开始播放
  Future<bool> playOnlineSong(
    OnlineSong song, {
    String? quality,
  }) async {
    try {
      final selectedQuality = quality ?? _defaultQuality;
      debugPrint('🎵 [OnlineAudioPlayer] 开始播放在线歌曲: ${song.title}');

      // 1. 检查是否有缓存
      final cachedPath = _cacheService.getCachedPath(song);
      if (cachedPath != null) {
        debugPrint('📦 [OnlineAudioPlayer] 使用缓存播放: $cachedPath');
        return await _playFromPath(song, cachedPath);
      }

      // 2. 获取播放URL
      final url = await _onlinePlayService.getSongUrl(song, quality: selectedQuality);
      if (url == null || url.isEmpty) {
        debugPrint('❌ [OnlineAudioPlayer] 获取播放URL失败');
        return false;
      }

      debugPrint('✅ [OnlineAudioPlayer] 获取播放URL成功: $url');

      // 3. 播放在线URL
      final success = await _playFromUrl(song, url);

      // 4. 如果启用自动缓存，后台缓存歌曲
      if (success && _autoCacheEnabled) {
        _cacheInBackground(song, url);
      }

      return success;
    } catch (e) {
      debugPrint('❌ [OnlineAudioPlayer] playOnlineSong error: $e');
      return false;
    }
  }

  /// 从路径播放（本地文件或缓存）
  Future<bool> _playFromPath(OnlineSong song, String path) async {
    final songModel = _onlineSongToSongModel(song, path);
    _onlineSongMap[_getSongKey(songModel)] = song;
    return await super.play(songModel);
  }

  /// 从URL播放（在线流）
  Future<bool> _playFromUrl(OnlineSong song, String url) async {
    final songModel = _onlineSongToSongModel(song, url);
    _onlineSongMap[_getSongKey(songModel)] = song;
    return await super.play(songModel);
  }

  /// 后台缓存歌曲
  void _cacheInBackground(OnlineSong song, String url) {
    debugPrint('📥 [OnlineAudioPlayer] 开始后台缓存: ${song.title}');
    _cacheService.cacheSong(song, url, onProgress: (progress) {
      // 可以在这里发送缓存进度事件
      if (progress >= 1.0) {
        debugPrint('✅ [OnlineAudioPlayer] 后台缓存完成: ${song.title}');
      }
    }).catchError((e) {
      debugPrint('❌ [OnlineAudioPlayer] 后台缓存失败: $e');
    });
  }

  /// 将OnlineSong转换为SongModel
  ///
  /// [song] 在线歌曲对象
  /// [audioSource] 音频源（URL或本地路径）
  SongModel _onlineSongToSongModel(OnlineSong song, String audioSource) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return SongModel(
      id: null, // 在线歌曲没有数据库ID
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration ~/ 1000, // 转换为秒
      filePath: audioSource, // URL或本地缓存路径
      fileSize: 0,
      coverPath: song.coverUrl,
      dateAdded: now,
      dateModified: now,
    );
  }

  /// 获取歌曲唯一键
  String _getSongKey(SongModel song) {
    return '${song.artist}_${song.title}';
  }

  /// 获取当前播放的在线歌曲（如果是在线歌曲）
  OnlineSong? getCurrentOnlineSong() {
    if (currentSong != null) {
      final key = _getSongKey(currentSong!);
      return _onlineSongMap[key];
    }
    return null;
  }

  /// 设置默认音质
  ///
  /// [quality] 音质等级：'standard', 'higher', 'lossless'
  void setDefaultQuality(String quality) {
    if (['standard', 'higher', 'lossless'].contains(quality)) {
      _defaultQuality = quality;
      debugPrint('⚙️ [OnlineAudioPlayer] 默认音质已设置为: $quality');
    }
  }

  /// 获取默认音质
  String getDefaultQuality() {
    return _defaultQuality;
  }

  /// 设置是否启用自动缓存
  ///
  /// [enabled] 是否启用
  void setAutoCacheEnabled(bool enabled) {
    _autoCacheEnabled = enabled;
    debugPrint('⚙️ [OnlineAudioPlayer] 自动缓存已${enabled ? "启用" : "禁用"}');
  }

  /// 是否启用了自动缓存
  bool isAutoCacheEnabled() {
    return _autoCacheEnabled;
  }

  /// 设置播放队列（支持混合本地和在线歌曲）
  ///
  /// 注意：需要先将OnlineSong转换为SongModel
  @override
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    // 清空在线歌曲映射（根据需要可以保留）
    // _onlineSongMap.clear();
    await super.setPlaylist(songs, startIndex: startIndex);
  }

  /// 添加在线歌曲到播放队列
  ///
  /// [song] 在线歌曲对象
  /// [quality] 音质等级
  Future<void> addOnlineSongToQueue(
    OnlineSong song, {
    String? quality,
  }) async {
    final selectedQuality = quality ?? _defaultQuality;

    // 检查缓存
    String? audioSource = _cacheService.getCachedPath(song);

    // 如果没有缓存，获取URL
    if (audioSource == null) {
      audioSource = await _onlinePlayService.getSongUrl(song, quality: selectedQuality);
      if (audioSource == null) {
        debugPrint('❌ [OnlineAudioPlayer] 无法获取歌曲URL: ${song.title}');
        return;
      }
    }

    final songModel = _onlineSongToSongModel(song, audioSource);
    _onlineSongMap[_getSongKey(songModel)] = song;
    addToQueue(songModel);

    debugPrint('➕ [OnlineAudioPlayer] 在线歌曲已添加到队列: ${song.title}');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  /// 清空播放缓存
  Future<void> clearPlayCache() async {
    await _cacheService.clearAllCache();
    debugPrint('🧹 [OnlineAudioPlayer] 播放缓存已清空');
  }

  /// 设置最大缓存大小
  ///
  /// [sizeMB] 最大缓存大小（MB）
  Future<void> setMaxCacheSize(int sizeMB) async {
    await _cacheService.setMaxCacheSize(sizeMB);
  }

  /// 检查歌曲是否已缓存
  ///
  /// [song] 在线歌曲对象
  bool isSongCached(OnlineSong song) {
    return _cacheService.isCached(song);
  }

  /// 手动缓存歌曲
  ///
  /// [song] 在线歌曲对象
  /// [quality] 音质等级
  /// [onProgress] 缓存进度回调
  Future<String?> cacheSong(
    OnlineSong song, {
    String? quality,
    Function(double)? onProgress,
  }) async {
    final selectedQuality = quality ?? _defaultQuality;
    final url = await _onlinePlayService.getSongUrl(song, quality: selectedQuality);

    if (url == null) {
      debugPrint('❌ [OnlineAudioPlayer] 无法获取歌曲URL用于缓存');
      return null;
    }

    return await _cacheService.cacheSong(song, url, onProgress: onProgress);
  }

  /// 删除歌曲缓存
  ///
  /// [song] 在线歌曲对象
  Future<void> removeSongCache(OnlineSong song) async {
    await _cacheService.removeCache(song);
  }

  @override
  Future<void> dispose() async {
    _onlineSongMap.clear();
    await super.dispose();
  }
}
