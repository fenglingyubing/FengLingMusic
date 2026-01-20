import '../../models/online_song.dart';
import '../../../services/network/dio_client.dart';

/// 酷狗音乐API接口
///
/// 注意：这是演示实现，使用第三方API
/// 实际生产环境需要遵守相关平台的使用条款
class KugouMusicApi {
  final DioClient _dioClient = DioClient();

  // 使用第三方API网关（示例）
  static const String _baseUrl = 'https://kugou-music-api-example.vercel.app';

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
          'keyword': keyword,
          'pagesize': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['info'] != null) {
          final List songs = data['info'];
          return songs
              .map((song) => _parseSong(song))
              .where((song) => song != null)
              .cast<OnlineSong>()
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ [KugouMusicApi] Search error: $e');
      return [];
    }
  }

  /// 解析歌曲数据
  OnlineSong? _parseSong(Map<String, dynamic> json) {
    try {
      return OnlineSong(
        id: json['hash']?.toString() ?? json['audio_id']?.toString() ?? '',
        title: json['songname'] ?? json['filename']?.split(' - ').last ?? '',
        artist: _parseArtist(json),
        album: json['album_name'] ?? '',
        duration: (json['duration'] ?? 0) * 1000, // 转换为毫秒
        coverUrl: json['img'] ?? json['album_img'],
        platform: 'kugou',
      );
    } catch (e) {
      print('❌ [KugouMusicApi] Parse song error: $e');
      return null;
    }
  }

  /// 解析艺术家
  String _parseArtist(Map<String, dynamic> json) {
    if (json['singername'] != null) {
      return json['singername'];
    }

    final filename = json['filename'];
    if (filename != null && filename.contains(' - ')) {
      return filename.split(' - ').first;
    }

    return 'Unknown';
  }

  /// 获取歌曲详情
  ///
  /// [songId] 歌曲ID (hash)
  Future<OnlineSong?> getSongDetail(String songId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/song/detail',
        queryParameters: {
          'hash': songId,
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
      print('❌ [KugouMusicApi] Get song detail error: $e');
      return null;
    }
  }

  /// 获取歌曲播放地址
  ///
  /// [songId] 歌曲ID (hash)
  /// [quality] 音质等级 (standard, high, lossless)
  Future<String?> getSongUrl(String songId, {String quality = 'standard'}) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/song/url',
        queryParameters: {
          'hash': songId,
          'type': _getQualityType(quality),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']?['play_url'] ?? response.data['data']?['url'];
      }

      return null;
    } catch (e) {
      print('❌ [KugouMusicApi] Get song url error: $e');
      return null;
    }
  }

  /// 获取歌词
  ///
  /// [songId] 歌曲ID (hash)
  Future<Map<String, String>> getLyrics(String songId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/lyric',
        queryParameters: {
          'hash': songId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'lyric': response.data['data']?['lyrics'] ?? '',
          'tlyric': '', // 酷狗一般不提供翻译歌词
        };
      }

      return {'lyric': '', 'tlyric': ''};
    } catch (e) {
      print('❌ [KugouMusicApi] Get lyrics error: $e');
      return {'lyric': '', 'tlyric': ''};
    }
  }

  /// 根据音质获取类型标识
  String _getQualityType(String quality) {
    switch (quality) {
      case 'lossless':
        return 'flac';
      case 'high':
        return 'high';
      case 'standard':
      default:
        return 'normal';
    }
  }
}
