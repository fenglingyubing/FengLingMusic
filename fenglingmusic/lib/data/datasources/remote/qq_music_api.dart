import '../../models/online_song.dart';
import '../../../services/network/dio_client.dart';

/// QQ音乐API接口
///
/// 注意：这是演示实现，使用第三方API
/// 实际生产环境需要遵守相关平台的使用条款
class QQMusicApi {
  final DioClient _dioClient = DioClient();

  // 使用第三方API网关（示例）
  static const String _baseUrl = 'https://qq-music-api-example.vercel.app';

  /// 搜索歌曲
  ///
  /// [keyword] 搜索关键词
  /// [limit] 返回结果数量
  /// [page] 页码
  Future<List<OnlineSong>> searchSongs({
    required String keyword,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/search',
        queryParameters: {
          'key': keyword,
          'pageSize': limit,
          'pageNo': page,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['list'] != null) {
          final List songs = data['list'];
          return songs
              .map((song) => _parseSong(song))
              .where((song) => song != null)
              .cast<OnlineSong>()
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ [QQMusicApi] Search error: $e');
      return [];
    }
  }

  /// 解析歌曲数据
  OnlineSong? _parseSong(Map<String, dynamic> json) {
    try {
      return OnlineSong(
        id: json['songmid']?.toString() ?? json['id']?.toString() ?? '',
        title: json['songname'] ?? json['name'] ?? '',
        artist: _parseArtist(json),
        album: json['albumname'] ?? json['album'] ?? '',
        duration: (json['interval'] ?? 0) * 1000, // 转换为毫秒
        coverUrl: _parseCoverUrl(json),
        platform: 'qq',
      );
    } catch (e) {
      print('❌ [QQMusicApi] Parse song error: $e');
      return null;
    }
  }

  /// 解析艺术家
  String _parseArtist(Map<String, dynamic> json) {
    if (json['singer'] != null) {
      if (json['singer'] is List) {
        final singers = json['singer'] as List;
        return singers.map((s) => s['name']).join(', ');
      } else if (json['singer'] is String) {
        return json['singer'];
      }
    }
    return json['singername'] ?? 'Unknown';
  }

  /// 解析封面URL
  String? _parseCoverUrl(Map<String, dynamic> json) {
    final albumMid = json['albummid'] ?? json['album_mid'];
    if (albumMid != null) {
      return 'https://y.qq.com/music/photo_new/T002R300x300M000$albumMid.jpg';
    }
    return null;
  }

  /// 获取歌曲详情
  ///
  /// [songId] 歌曲ID
  Future<OnlineSong?> getSongDetail(String songId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/song',
        queryParameters: {
          'songmid': songId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          return _parseSong(data);
        }
      }

      return null;
    } catch (e) {
      print('❌ [QQMusicApi] Get song detail error: $e');
      return null;
    }
  }

  /// 获取歌曲播放地址
  ///
  /// [songId] 歌曲ID
  /// [quality] 音质等级 (standard, high, lossless)
  Future<String?> getSongUrl(String songId, {String quality = 'standard'}) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/song/url',
        queryParameters: {
          'id': songId,
          'type': _getQualityType(quality),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']?['url'];
      }

      return null;
    } catch (e) {
      print('❌ [QQMusicApi] Get song url error: $e');
      return null;
    }
  }

  /// 获取歌词
  ///
  /// [songId] 歌曲ID
  Future<Map<String, String>> getLyrics(String songId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/lyric',
        queryParameters: {
          'songmid': songId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'lyric': response.data['data']?['lyric'] ?? '',
          'tlyric': response.data['data']?['trans'] ?? '',
        };
      }

      return {'lyric': '', 'tlyric': ''};
    } catch (e) {
      print('❌ [QQMusicApi] Get lyrics error: $e');
      return {'lyric': '', 'tlyric': ''};
    }
  }

  /// 根据音质获取类型标识
  String _getQualityType(String quality) {
    switch (quality) {
      case 'lossless':
        return 'flac';
      case 'high':
        return '320';
      case 'standard':
      default:
        return '128';
    }
  }
}
