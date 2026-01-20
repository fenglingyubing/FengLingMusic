import '../../data/datasources/remote/netease_music_api.dart';
import '../../data/datasources/remote/qq_music_api.dart';
import '../../data/datasources/remote/kugou_music_api.dart';
import '../../data/models/online_song.dart';

/// 多平台搜索聚合服务
///
/// 支持同时搜索多个音乐平台，并将结果聚合、去重、排序
class MultiPlatformSearchService {
  final NeteaseMusicApi _neteaseApi = NeteaseMusicApi();
  final QQMusicApi _qqApi = QQMusicApi();
  final KugouMusicApi _kugouApi = KugouMusicApi();

  /// 支持的平台列表
  static const List<String> supportedPlatforms = ['netease', 'qq', 'kugou'];

  /// 搜索歌曲（多平台并发搜索）
  ///
  /// [keyword] 搜索关键词
  /// [platforms] 要搜索的平台列表，默认搜索所有平台
  /// [limit] 每个平台返回的结果数量
  /// [page] 页码
  Future<List<OnlineSong>> searchSongs({
    required String keyword,
    List<String>? platforms,
    int limit = 20,
    int page = 1,
  }) async {
    if (keyword.isEmpty) {
      return [];
    }

    // 如果未指定平台，则搜索所有平台
    final targetPlatforms = platforms ?? supportedPlatforms;

    // 并发搜索多个平台
    final futures = <Future<List<OnlineSong>>>[];

    for (final platform in targetPlatforms) {
      switch (platform) {
        case 'netease':
          futures.add(_searchNetease(keyword, limit, page));
          break;
        case 'qq':
          futures.add(_searchQQ(keyword, limit, page));
          break;
        case 'kugou':
          futures.add(_searchKugou(keyword, limit, page));
          break;
      }
    }

    // 等待所有搜索完成
    final results = await Future.wait(futures);

    // 合并结果
    final allSongs = <OnlineSong>[];
    for (final songs in results) {
      allSongs.addAll(songs);
    }

    // 去重和排序
    return _deduplicateAndSort(allSongs);
  }

  /// 搜索网易云音乐
  Future<List<OnlineSong>> _searchNetease(String keyword, int limit, int page) async {
    try {
      return await _neteaseApi.searchSongs(
        keyword: keyword,
        limit: limit,
        offset: (page - 1) * limit,
      );
    } catch (e) {
      print('❌ [MultiPlatformSearch] Netease search error: $e');
      return [];
    }
  }

  /// 搜索QQ音乐
  Future<List<OnlineSong>> _searchQQ(String keyword, int limit, int page) async {
    try {
      return await _qqApi.searchSongs(
        keyword: keyword,
        limit: limit,
        page: page,
      );
    } catch (e) {
      print('❌ [MultiPlatformSearch] QQ search error: $e');
      return [];
    }
  }

  /// 搜索酷狗音乐
  Future<List<OnlineSong>> _searchKugou(String keyword, int limit, int page) async {
    try {
      return await _kugouApi.searchSongs(
        keyword: keyword,
        limit: limit,
        page: page,
      );
    } catch (e) {
      print('❌ [MultiPlatformSearch] Kugou search error: $e');
      return [];
    }
  }

  /// 去重和排序
  ///
  /// 去重规则：歌曲名 + 艺术家名相同则认为是重复
  /// 排序规则：按平台优先级（网易云 > QQ音乐 > 酷狗）
  List<OnlineSong> _deduplicateAndSort(List<OnlineSong> songs) {
    // 使用Map进行去重，key为"歌曲名-艺术家名"
    final uniqueSongs = <String, OnlineSong>{};

    for (final song in songs) {
      final key = '${_normalize(song.title)}-${_normalize(song.artist)}';

      // 如果已存在，则保留优先级更高的平台
      if (!uniqueSongs.containsKey(key)) {
        uniqueSongs[key] = song;
      } else {
        final existing = uniqueSongs[key]!;
        if (_getPlatformPriority(song.platform) < _getPlatformPriority(existing.platform)) {
          uniqueSongs[key] = song;
        }
      }
    }

    // 转换为列表并排序
    final result = uniqueSongs.values.toList();

    result.sort((a, b) {
      // 首先按平台优先级排序
      final platformCompare = _getPlatformPriority(a.platform).compareTo(
        _getPlatformPriority(b.platform),
      );
      if (platformCompare != 0) return platformCompare;

      // 如果平台相同，按歌曲名排序
      return a.title.compareTo(b.title);
    });

    return result;
  }

  /// 标准化字符串（用于比较）
  String _normalize(String str) {
    return str.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');
  }

  /// 获取平台优先级（数字越小优先级越高）
  int _getPlatformPriority(String platform) {
    switch (platform) {
      case 'netease':
        return 1;
      case 'qq':
        return 2;
      case 'kugou':
        return 3;
      default:
        return 999;
    }
  }

  /// 根据平台获取对应的API实例
  dynamic getApiByPlatform(String platform) {
    switch (platform) {
      case 'netease':
        return _neteaseApi;
      case 'qq':
        return _qqApi;
      case 'kugou':
        return _kugouApi;
      default:
        return null;
    }
  }
}
