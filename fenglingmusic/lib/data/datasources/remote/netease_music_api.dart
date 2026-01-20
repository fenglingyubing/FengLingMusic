import '../../models/online_song.dart';
import '../../../services/network/dio_client.dart';

/// 网易云音乐API接口
///
/// 注意：这是演示实现，使用第三方API
/// 实际生产环境需要遵守相关平台的使用条款
class NeteaseMusicApi {
  final DioClient _dioClient = DioClient();

  // 使用第三方API网关（示例）
  static const String _baseUrl = 'https://netease-cloud-music-api-example.vercel.app';

  /// 搜索歌曲
  ///
  /// [keyword] 搜索关键词
  /// [limit] 返回结果数量
  /// [offset] 偏移量，用于分页
  Future<List<OnlineSong>> searchSongs({
    required String keyword,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/search',
        queryParameters: {
          'keywords': keyword,
          'limit': limit,
          'offset': offset,
          'type': 1, // 1: 单曲
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = response.data['result'];
        if (result != null && result['songs'] != null) {
          final List songs = result['songs'];
          return songs
              .map((song) => OnlineSong.fromJson(song, 'netease'))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ [NeteaseMusicApi] Search error: $e');
      return [];
    }
  }

  /// 获取歌曲详情
  ///
  /// [songId] 歌曲ID
  Future<OnlineSong?> getSongDetail(String songId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/song/detail',
        queryParameters: {
          'ids': songId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final songs = response.data['songs'];
        if (songs != null && songs.isNotEmpty) {
          return OnlineSong.fromJson(songs[0], 'netease');
        }
      }

      return null;
    } catch (e) {
      print('❌ [NeteaseMusicApi] Get song detail error: $e');
      return null;
    }
  }

  /// 获取歌曲播放地址
  ///
  /// [songId] 歌曲ID
  /// [quality] 音质等级 (standard, higher, lossless)
  Future<String?> getSongUrl(String songId, {String quality = 'standard'}) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/song/url',
        queryParameters: {
          'id': songId,
          'br': _getQualityBitrate(quality),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data.isNotEmpty) {
          return data[0]['url'];
        }
      }

      return null;
    } catch (e) {
      print('❌ [NeteaseMusicApi] Get song url error: $e');
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
          'id': songId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'lyric': response.data['lrc']?['lyric'] ?? '',
          'tlyric': response.data['tlyric']?['lyric'] ?? '', // 翻译歌词
        };
      }

      return {'lyric': '', 'tlyric': ''};
    } catch (e) {
      print('❌ [NeteaseMusicApi] Get lyrics error: $e');
      return {'lyric': '', 'tlyric': ''};
    }
  }

  /// 根据音质获取比特率
  int _getQualityBitrate(String quality) {
    switch (quality) {
      case 'lossless':
        return 999000; // 无损
      case 'higher':
        return 320000; // 320k
      case 'standard':
      default:
        return 128000; // 128k
    }
  }
}
