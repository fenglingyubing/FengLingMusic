import 'dart:io';
import 'package:path/path.dart' as path;
import '../../data/models/lyric_line_model.dart';
import '../../data/models/song_model.dart';
import '../../data/models/online_song.dart';
import '../../data/datasources/remote/netease_music_api.dart';
import '../../data/datasources/remote/qq_music_api.dart';
import '../../data/datasources/remote/kugou_music_api.dart';
import 'lrc_parser.dart';

/// 歌词服务
///
/// 负责获取、缓存和管理歌词
/// 支持：
/// - 在线歌词获取（多平台聚合）
/// - 本地 LRC 文件读取
/// - 歌词缓存
class LyricsService {
  final NeteaseMusicApi _neteaseApi = NeteaseMusicApi();
  final QQMusicApi _qqApi = QQMusicApi();
  final KugouMusicApi _kugouApi = KugouMusicApi();

  // 内存缓存：歌曲ID -> 歌词列表
  final Map<String, List<LyricLineModel>> _lyricsCache = {};

  // 缓存目录路径（需要在初始化时设置）
  String? _cacheDir;

  /// 初始化服务
  ///
  /// [cacheDir] 歌词缓存目录路径
  Future<void> initialize(String cacheDir) async {
    _cacheDir = cacheDir;
    final dir = Directory(cacheDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// 获取歌词
  ///
  /// 优先级：内存缓存 -> 本地 LRC 文件 -> 缓存文件 -> 在线获取
  ///
  /// [song] 本地歌曲
  /// [onlineSong] 在线歌曲信息（用于在线歌词获取）
  /// 返回解析后的歌词行列表
  Future<List<LyricLineModel>> getLyrics({
    SongModel? song,
    OnlineSong? onlineSong,
  }) async {
    // 生成唯一的缓存键
    final String cacheKey = _generateCacheKey(song, onlineSong);

    // 1. 检查内存缓存
    if (_lyricsCache.containsKey(cacheKey)) {
      print('✅ [LyricsService] Lyrics from memory cache: $cacheKey');
      return _lyricsCache[cacheKey]!;
    }

    // 2. 本地歌曲：尝试读取同名 LRC 文件
    if (song != null) {
      final List<LyricLineModel>? localLyrics = await _loadLocalLrcFile(song);
      if (localLyrics != null && localLyrics.isNotEmpty) {
        _lyricsCache[cacheKey] = localLyrics;
        print('✅ [LyricsService] Lyrics from local LRC file');
        return localLyrics;
      }
    }

    // 3. 检查缓存文件
    final List<LyricLineModel>? cachedLyrics = await _loadCachedLyrics(cacheKey);
    if (cachedLyrics != null && cachedLyrics.isNotEmpty) {
      _lyricsCache[cacheKey] = cachedLyrics;
      print('✅ [LyricsService] Lyrics from cache file');
      return cachedLyrics;
    }

    // 4. 在线获取
    if (onlineSong != null) {
      final List<LyricLineModel>? onlineLyrics = await _fetchOnlineLyrics(onlineSong);
      if (onlineLyrics != null && onlineLyrics.isNotEmpty) {
        _lyricsCache[cacheKey] = onlineLyrics;
        await _saveLyricsToCache(cacheKey, onlineLyrics);
        print('✅ [LyricsService] Lyrics from online source');
        return onlineLyrics;
      }
    } else if (song != null) {
      // 本地歌曲，尝试通过歌名和艺术家搜索在线歌词
      final List<LyricLineModel>? searchedLyrics = await _searchAndFetchLyrics(song);
      if (searchedLyrics != null && searchedLyrics.isNotEmpty) {
        _lyricsCache[cacheKey] = searchedLyrics;
        await _saveLyricsToCache(cacheKey, searchedLyrics);
        print('✅ [LyricsService] Lyrics from online search');
        return searchedLyrics;
      }
    }

    // 5. 无歌词
    print('⚠️  [LyricsService] No lyrics available');
    return [];
  }

  /// 读取本地 LRC 文件
  Future<List<LyricLineModel>?> _loadLocalLrcFile(SongModel song) async {
    try {
      // 获取音频文件路径，推断 LRC 文件路径
      final String audioPath = song.filePath;
      final String lrcPath = audioPath.replaceAll(
        RegExp(r'\.(mp3|flac|wav|m4a|ogg)$', caseSensitive: false),
        '.lrc',
      );

      final File lrcFile = File(lrcPath);
      if (!await lrcFile.exists()) {
        return null;
      }

      final String content = await lrcFile.readAsString();
      if (!LrcParser.isValidLrc(content)) {
        return null;
      }

      return LrcParser.parse(content);
    } catch (e) {
      print('❌ [LyricsService] Load local LRC file error: $e');
      return null;
    }
  }

  /// 从缓存文件加载歌词
  Future<List<LyricLineModel>?> _loadCachedLyrics(String cacheKey) async {
    if (_cacheDir == null) return null;

    try {
      final File cacheFile = File(path.join(_cacheDir!, '$cacheKey.lrc'));
      if (!await cacheFile.exists()) {
        return null;
      }

      final String content = await cacheFile.readAsString();
      if (!LrcParser.isValidLrc(content)) {
        return null;
      }

      return LrcParser.parse(content);
    } catch (e) {
      print('❌ [LyricsService] Load cached lyrics error: $e');
      return null;
    }
  }

  /// 保存歌词到缓存文件
  Future<void> _saveLyricsToCache(
    String cacheKey,
    List<LyricLineModel> lyrics,
  ) async {
    if (_cacheDir == null) return;

    try {
      // 将歌词转换回 LRC 格式保存
      final StringBuffer lrcContent = StringBuffer();
      for (var line in lyrics) {
        lrcContent.writeln('${line.formattedTimestamp}${line.text}');
        if (line.translation != null) {
          // 翻译保存为注释或单独标记
          lrcContent.writeln('// Translation: ${line.translation}');
        }
      }

      final File cacheFile = File(path.join(_cacheDir!, '$cacheKey.lrc'));
      await cacheFile.writeAsString(lrcContent.toString());
      print('✅ [LyricsService] Lyrics saved to cache');
    } catch (e) {
      print('❌ [LyricsService] Save lyrics to cache error: $e');
    }
  }

  /// 从在线源获取歌词
  Future<List<LyricLineModel>?> _fetchOnlineLyrics(OnlineSong song) async {
    try {
      Map<String, String> lyricsData = {};

      // 根据平台选择API
      switch (song.platform) {
        case 'netease':
          lyricsData = await _neteaseApi.getLyrics(song.id);
          break;
        case 'qq':
          lyricsData = await _qqApi.getLyrics(song.id);
          break;
        case 'kugou':
          lyricsData = await _kugouApi.getLyrics(song.id);
          break;
        default:
          // 尝试所有平台
          lyricsData = await _neteaseApi.getLyrics(song.id);
          if (lyricsData['lyric']?.isEmpty ?? true) {
            lyricsData = await _qqApi.getLyrics(song.id);
          }
          if (lyricsData['lyric']?.isEmpty ?? true) {
            lyricsData = await _kugouApi.getLyrics(song.id);
          }
      }

      final String lyricContent = lyricsData['lyric'] ?? '';
      final String translationContent = lyricsData['tlyric'] ?? '';

      if (lyricContent.isEmpty) {
        return null;
      }

      return LrcParser.parse(lyricContent, translationContent: translationContent);
    } catch (e) {
      print('❌ [LyricsService] Fetch online lyrics error: $e');
      return null;
    }
  }

  /// 通过搜索获取本地歌曲的在线歌词
  Future<List<LyricLineModel>?> _searchAndFetchLyrics(SongModel song) async {
    try {
      // 构建搜索关键词
      final String keyword = '${song.artist ?? ''} ${song.title}'.trim();
      if (keyword.isEmpty) {
        return null;
      }

      // 从网易云搜索（通常歌词最全）
      final List<OnlineSong> searchResults = await _neteaseApi.searchSongs(
        keyword: keyword,
        limit: 1,
      );

      if (searchResults.isEmpty) {
        return null;
      }

      // 使用第一个搜索结果获取歌词
      return await _fetchOnlineLyrics(searchResults.first);
    } catch (e) {
      print('❌ [LyricsService] Search and fetch lyrics error: $e');
      return null;
    }
  }

  /// 生成缓存键
  String _generateCacheKey(SongModel? song, OnlineSong? onlineSong) {
    if (onlineSong != null) {
      return 'online_${onlineSong.platform}_${onlineSong.id}';
    } else if (song != null) {
      // 使用歌曲路径的hash作为缓存键
      return 'local_${song.filePath.hashCode.abs()}';
    }
    return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 清除内存缓存
  void clearMemoryCache() {
    _lyricsCache.clear();
    print('✅ [LyricsService] Memory cache cleared');
  }

  /// 清除所有缓存（包括文件）
  Future<void> clearAllCache() async {
    clearMemoryCache();

    if (_cacheDir != null) {
      try {
        final Directory dir = Directory(_cacheDir!);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          await dir.create();
          print('✅ [LyricsService] All cache cleared');
        }
      } catch (e) {
        print('❌ [LyricsService] Clear cache error: $e');
      }
    }
  }

  /// 预加载歌词
  ///
  /// 用于提前加载播放列表中的歌词
  Future<void> preloadLyrics({
    List<SongModel>? songs,
    List<OnlineSong>? onlineSongs,
  }) async {
    if (songs != null) {
      for (var song in songs) {
        await getLyrics(song: song);
      }
    }
    if (onlineSongs != null) {
      for (var song in onlineSongs) {
        await getLyrics(onlineSong: song);
      }
    }
  }
}
