import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../data/models/online_song.dart';

/// 播放缓存服务
///
/// TASK-090: 实现播放缓存功能
/// 功能：
/// - 自动缓存播放的在线歌曲
/// - LRU 缓存策略
/// - 缓存大小限制
class PlayCacheService {
  /// Dio客户端用于下载
  final Dio _dio = Dio();

  /// LRU缓存队列 - 记录访问顺序，最近访问的在最后
  final List<String> _lruQueue = [];

  /// 缓存信息映射 - 存储歌曲ID和缓存文件信息
  final Map<String, _CacheEntry> _cacheMap = {};

  /// 缓存目录
  Directory? _cacheDir;

  /// 最大缓存大小（字节） - 默认500MB
  int _maxCacheSize = 500 * 1024 * 1024;

  /// 当前缓存总大小（字节）
  int _currentCacheSize = 0;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 单例模式
  static final PlayCacheService _instance = PlayCacheService._internal();
  factory PlayCacheService() => _instance;
  PlayCacheService._internal();

  /// 初始化缓存服务
  Future<void> initialize({int? maxCacheSizeMB}) async {
    if (_isInitialized) return;

    try {
      // 获取缓存目录
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/music_cache');

      // 创建缓存目录
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      // 设置最大缓存大小
      if (maxCacheSizeMB != null) {
        _maxCacheSize = maxCacheSizeMB * 1024 * 1024;
      }

      // 加载已有缓存信息
      await _loadCacheInfo();

      _isInitialized = true;
      debugPrint('✅ [PlayCacheService] 初始化完成');
      debugPrint('📁 [PlayCacheService] 缓存目录: ${_cacheDir!.path}');
      debugPrint('💾 [PlayCacheService] 最大缓存大小: ${_maxCacheSize ~/ 1024 ~/ 1024}MB');
      debugPrint('📊 [PlayCacheService] 当前缓存大小: ${_currentCacheSize ~/ 1024 ~/ 1024}MB');
    } catch (e) {
      debugPrint('❌ [PlayCacheService] 初始化失败: $e');
    }
  }

  /// 加载已有缓存信息
  Future<void> _loadCacheInfo() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) return;

      final files = await _cacheDir!.list().toList();
      _currentCacheSize = 0;

      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;
          final songId = fileName.replaceAll('.mp3', '');

          _cacheMap[songId] = _CacheEntry(
            songId: songId,
            filePath: file.path,
            size: stat.size,
            cachedTime: stat.modified,
          );

          _lruQueue.add(songId);
          _currentCacheSize += stat.size;
        }
      }

      debugPrint('📦 [PlayCacheService] 加载了 ${_cacheMap.length} 个缓存文件');
    } catch (e) {
      debugPrint('❌ [PlayCacheService] 加载缓存信息失败: $e');
    }
  }

  /// 缓存在线歌曲
  ///
  /// [song] 在线歌曲对象
  /// [url] 播放URL
  /// [onProgress] 下载进度回调（0.0-1.0）
  ///
  /// 返回缓存文件路径，失败返回null
  Future<String?> cacheSong(
    OnlineSong song,
    String url, {
    Function(double)? onProgress,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final songId = '${song.platform}_${song.id}';

      // 检查是否已缓存
      if (_cacheMap.containsKey(songId)) {
        _updateLRU(songId);
        debugPrint('✅ [PlayCacheService] 歌曲已缓存: ${song.title}');
        return _cacheMap[songId]!.filePath;
      }

      // 生成缓存文件路径
      final fileName = '$songId.mp3';
      final filePath = '${_cacheDir!.path}/$fileName';
      final file = File(filePath);

      // 下载文件
      debugPrint('⬇️ [PlayCacheService] 开始缓存: ${song.title}');
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // 检查文件是否下载成功
      if (!await file.exists()) {
        debugPrint('❌ [PlayCacheService] 文件下载失败: ${song.title}');
        return null;
      }

      final stat = await file.stat();
      final fileSize = stat.size;

      // 检查缓存空间
      while (_currentCacheSize + fileSize > _maxCacheSize && _lruQueue.isNotEmpty) {
        await _evictLRU();
      }

      // 添加到缓存
      _cacheMap[songId] = _CacheEntry(
        songId: songId,
        filePath: filePath,
        size: fileSize,
        cachedTime: DateTime.now(),
      );
      _lruQueue.add(songId);
      _currentCacheSize += fileSize;

      debugPrint('✅ [PlayCacheService] 缓存成功: ${song.title}');
      debugPrint('📊 [PlayCacheService] 当前缓存: ${_currentCacheSize ~/ 1024 ~/ 1024}MB / ${_maxCacheSize ~/ 1024 ~/ 1024}MB');

      return filePath;
    } catch (e) {
      debugPrint('❌ [PlayCacheService] 缓存失败: $e');
      return null;
    }
  }

  /// 获取缓存文件路径
  ///
  /// [song] 在线歌曲对象
  ///
  /// 返回缓存文件路径，未缓存返回null
  String? getCachedPath(OnlineSong song) {
    final songId = '${song.platform}_${song.id}';
    if (_cacheMap.containsKey(songId)) {
      _updateLRU(songId);
      return _cacheMap[songId]!.filePath;
    }
    return null;
  }

  /// 检查歌曲是否已缓存
  ///
  /// [song] 在线歌曲对象
  bool isCached(OnlineSong song) {
    final songId = '${song.platform}_${song.id}';
    return _cacheMap.containsKey(songId);
  }

  /// 删除指定歌曲的缓存
  ///
  /// [song] 在线歌曲对象
  Future<void> removeCache(OnlineSong song) async {
    final songId = '${song.platform}_${song.id}';
    if (_cacheMap.containsKey(songId)) {
      await _removeEntry(songId);
      debugPrint('🗑️ [PlayCacheService] 已删除缓存: ${song.title}');
    }
  }

  /// 清空所有缓存
  Future<void> clearAllCache() async {
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }

      _cacheMap.clear();
      _lruQueue.clear();
      _currentCacheSize = 0;

      debugPrint('🧹 [PlayCacheService] 已清空所有缓存');
    } catch (e) {
      debugPrint('❌ [PlayCacheService] 清空缓存失败: $e');
    }
  }

  /// 设置最大缓存大小
  ///
  /// [sizeMB] 最大缓存大小（MB）
  Future<void> setMaxCacheSize(int sizeMB) async {
    _maxCacheSize = sizeMB * 1024 * 1024;

    // 如果当前缓存超过新的限制，清理多余缓存
    while (_currentCacheSize > _maxCacheSize && _lruQueue.isNotEmpty) {
      await _evictLRU();
    }

    debugPrint('⚙️ [PlayCacheService] 最大缓存大小已设置为: ${sizeMB}MB');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'totalFiles': _cacheMap.length,
      'currentSizeMB': _currentCacheSize / 1024 / 1024,
      'maxSizeMB': _maxCacheSize / 1024 / 1024,
      'usagePercent': (_currentCacheSize / _maxCacheSize * 100).toStringAsFixed(2),
    };
  }

  /// 更新LRU队列
  void _updateLRU(String songId) {
    _lruQueue.remove(songId);
    _lruQueue.add(songId);
  }

  /// 驱逐LRU队列中最旧的条目
  Future<void> _evictLRU() async {
    if (_lruQueue.isEmpty) return;

    final oldestId = _lruQueue.removeAt(0);
    await _removeEntry(oldestId);
    debugPrint('🗑️ [PlayCacheService] LRU驱逐: $oldestId');
  }

  /// 删除缓存条目
  Future<void> _removeEntry(String songId) async {
    if (!_cacheMap.containsKey(songId)) return;

    final entry = _cacheMap[songId]!;

    try {
      final file = File(entry.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      _currentCacheSize -= entry.size;
      _cacheMap.remove(songId);
      _lruQueue.remove(songId);
    } catch (e) {
      debugPrint('❌ [PlayCacheService] 删除缓存条目失败: $e');
    }
  }
}

/// 缓存条目信息
class _CacheEntry {
  final String songId;
  final String filePath;
  final int size;
  final DateTime cachedTime;

  _CacheEntry({
    required this.songId,
    required this.filePath,
    required this.size,
    required this.cachedTime,
  });
}
