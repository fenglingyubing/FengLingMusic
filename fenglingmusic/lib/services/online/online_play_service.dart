import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/online_song.dart';
import '../../data/datasources/remote/netease_music_api.dart';
import '../../data/datasources/remote/qq_music_api.dart';
import '../../data/datasources/remote/kugou_music_api.dart';

/// 在线播放服务
///
/// TASK-088: 实现在线歌曲 URL 获取
/// 功能：
/// - 获取播放地址
/// - 多音质支持
/// - URL 有效期处理
class OnlinePlayService {
  final NeteaseMusicApi _neteaseApi = NeteaseMusicApi();
  final QQMusicApi _qqApi = QQMusicApi();
  final KugouMusicApi _kugouApi = KugouMusicApi();

  /// URL缓存 - 存储已获取的URL和过期时间
  final Map<String, _UrlCacheEntry> _urlCache = {};

  /// URL默认有效期（秒） - 一般在线音乐URL有效期为30分钟左右
  static const int _urlValidDuration = 30 * 60; // 30分钟

  /// 获取在线歌曲播放URL
  ///
  /// [song] 在线歌曲对象
  /// [quality] 音质等级：'standard'(标准), 'higher'(高品质), 'lossless'(无损)
  /// [forceRefresh] 是否强制刷新URL，忽略缓存
  ///
  /// 返回播放URL，如果获取失败则返回null
  Future<String?> getSongUrl(
    OnlineSong song, {
    String quality = 'standard',
    bool forceRefresh = false,
  }) async {
    try {
      // 生成缓存键
      final cacheKey = '${song.platform}_${song.id}_$quality';

      // 检查缓存
      if (!forceRefresh && _urlCache.containsKey(cacheKey)) {
        final cacheEntry = _urlCache[cacheKey]!;
        if (!cacheEntry.isExpired()) {
          debugPrint('✅ [OnlinePlayService] 使用缓存的URL: $cacheKey');
          return cacheEntry.url;
        } else {
          debugPrint('⏰ [OnlinePlayService] URL缓存已过期: $cacheKey');
          _urlCache.remove(cacheKey);
        }
      }

      // 根据平台获取URL
      String? url;
      switch (song.platform.toLowerCase()) {
        case 'netease':
          url = await _neteaseApi.getSongUrl(song.id, quality: quality);
          break;
        case 'qq':
          url = await _qqApi.getSongUrl(song.id, quality: quality);
          break;
        case 'kugou':
          url = await _kugouApi.getSongUrl(song.id, quality: quality);
          break;
        default:
          debugPrint('❌ [OnlinePlayService] 不支持的平台: ${song.platform}');
          return null;
      }

      // 缓存URL
      if (url != null && url.isNotEmpty) {
        _urlCache[cacheKey] = _UrlCacheEntry(
          url: url,
          expiryTime: DateTime.now().add(Duration(seconds: _urlValidDuration)),
        );
        debugPrint('✅ [OnlinePlayService] 获取播放URL成功: ${song.title} - $quality');
      } else {
        debugPrint('❌ [OnlinePlayService] 获取播放URL失败: ${song.title}');
      }

      return url;
    } catch (e) {
      debugPrint('❌ [OnlinePlayService] getSongUrl error: $e');
      return null;
    }
  }

  /// 批量获取多个音质的URL
  ///
  /// [song] 在线歌曲对象
  /// [qualities] 音质列表
  ///
  /// 返回音质和URL的映射
  Future<Map<String, String?>> getSongUrls(
    OnlineSong song,
    List<String> qualities,
  ) async {
    final Map<String, String?> urls = {};

    for (final quality in qualities) {
      final url = await getSongUrl(song, quality: quality);
      urls[quality] = url;
    }

    return urls;
  }

  /// 检查URL是否仍然有效
  ///
  /// [song] 在线歌曲对象
  /// [quality] 音质等级
  ///
  /// 返回true表示缓存的URL仍然有效
  bool isUrlValid(OnlineSong song, String quality) {
    final cacheKey = '${song.platform}_${song.id}_$quality';
    if (_urlCache.containsKey(cacheKey)) {
      return !_urlCache[cacheKey]!.isExpired();
    }
    return false;
  }

  /// 清除所有过期的URL缓存
  void clearExpiredUrls() {
    _urlCache.removeWhere((key, entry) => entry.isExpired());
    debugPrint('🧹 [OnlinePlayService] 已清理过期URL缓存');
  }

  /// 清除指定歌曲的URL缓存
  void clearSongUrlCache(OnlineSong song) {
    _urlCache.removeWhere((key, entry) => key.startsWith('${song.platform}_${song.id}_'));
    debugPrint('🧹 [OnlinePlayService] 已清理歌曲URL缓存: ${song.title}');
  }

  /// 清除所有URL缓存
  void clearAllUrlCache() {
    _urlCache.clear();
    debugPrint('🧹 [OnlinePlayService] 已清理所有URL缓存');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    int validCount = 0;
    int expiredCount = 0;

    for (final entry in _urlCache.values) {
      if (entry.isExpired()) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return {
      'total': _urlCache.length,
      'valid': validCount,
      'expired': expiredCount,
    };
  }
}

/// URL缓存条目
class _UrlCacheEntry {
  final String url;
  final DateTime expiryTime;

  _UrlCacheEntry({
    required this.url,
    required this.expiryTime,
  });

  /// 检查是否已过期
  bool isExpired() {
    return DateTime.now().isAfter(expiryTime);
  }

  /// 剩余有效时间（秒）
  int remainingSeconds() {
    final remaining = expiryTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }
}
