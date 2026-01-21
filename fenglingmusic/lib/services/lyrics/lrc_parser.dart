import '../../data/models/lyric_line_model.dart';

/// LRC 歌词解析器
///
/// 支持标准 LRC 格式和增强 LRC 格式
/// 标准格式: [mm:ss.xx]歌词文本
/// 增强格式: [mm:ss.xx]<mm:ss.xx>单词<mm:ss.xx>单词...
class LrcParser {
  /// 解析 LRC 格式歌词字符串
  ///
  /// [lrcContent] LRC 格式的歌词文本
  /// [translationContent] 可选的翻译歌词文本
  /// 返回解析后的歌词行列表，按时间戳排序
  static List<LyricLineModel> parse(String lrcContent, {String? translationContent}) {
    if (lrcContent.isEmpty) {
      return [];
    }

    // 解析主歌词
    final List<LyricLineModel> lyrics = _parseLines(lrcContent);

    // 如果有翻译，解析并合并
    if (translationContent != null && translationContent.isNotEmpty) {
      final List<LyricLineModel> translations = _parseLines(translationContent);
      _mergeTranslations(lyrics, translations);
    }

    // 按时间戳排序
    lyrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return lyrics;
  }

  /// 解析单个歌词内容的行
  static List<LyricLineModel> _parseLines(String content) {
    final List<LyricLineModel> lines = [];
    final List<String> rawLines = content.split('\n');

    for (String line in rawLines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 匹配时间标签: [mm:ss.xx] 或 [mm:ss]
      final RegExp timeTagRegex = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{2,3})?\]');
      final Iterable<RegExpMatch> matches = timeTagRegex.allMatches(line);

      if (matches.isEmpty) {
        // 可能是元数据标签 [ti:title] [ar:artist] 等，跳过
        continue;
      }

      // 移除所有时间标签，获取歌词文本
      String text = line.replaceAll(timeTagRegex, '').trim();

      // 移除增强 LRC 的单词时间标签 <mm:ss.xx>
      text = text.replaceAll(RegExp(r'<\d{2}:\d{2}\.\d{2,3}>'), '').trim();

      // 一行可能有多个时间标签（表示同一歌词在不同时间重复）
      for (RegExpMatch match in matches) {
        final int minutes = int.parse(match.group(1)!);
        final int seconds = int.parse(match.group(2)!);
        final int milliseconds = match.group(3) != null
            ? int.parse(match.group(3)!.padRight(3, '0').substring(0, 3))
            : 0;

        final int timestamp = minutes * 60000 + seconds * 1000 + milliseconds;

        lines.add(LyricLineModel(
          timestamp: timestamp,
          text: text.isEmpty ? '♪' : text, // 空行显示音乐符号
        ));
      }
    }

    return lines;
  }

  /// 合并翻译到主歌词
  static void _mergeTranslations(
    List<LyricLineModel> lyrics,
    List<LyricLineModel> translations,
  ) {
    // 创建时间戳到翻译的映射
    final Map<int, String> translationMap = {
      for (var line in translations) line.timestamp: line.text
    };

    // 为主歌词添加翻译（允许小范围时间差异）
    for (int i = 0; i < lyrics.length; i++) {
      final int timestamp = lyrics[i].timestamp;
      String? translation;

      // 精确匹配
      if (translationMap.containsKey(timestamp)) {
        translation = translationMap[timestamp];
      } else {
        // 容错匹配：在 ±500ms 范围内查找
        for (int offset = -500; offset <= 500; offset += 100) {
          if (translationMap.containsKey(timestamp + offset)) {
            translation = translationMap[timestamp + offset];
            break;
          }
        }
      }

      if (translation != null && translation != '♪') {
        lyrics[i] = lyrics[i].copyWith(translation: translation);
      }
    }
  }

  /// 从 LRC 文件内容中提取元数据
  ///
  /// 返回包含歌曲元数据的 Map
  /// 常见标签: ti (标题), ar (艺术家), al (专辑), by (制作者)
  static Map<String, String> extractMetadata(String lrcContent) {
    final Map<String, String> metadata = {};
    final List<String> lines = lrcContent.split('\n');

    final RegExp metadataRegex = RegExp(r'\[(\w+):(.*)\]');

    for (String line in lines) {
      final RegExpMatch? match = metadataRegex.firstMatch(line.trim());
      if (match != null) {
        final String key = match.group(1)!.toLowerCase();
        final String value = match.group(2)!.trim();

        // 只保存元数据标签（非时间标签）
        if (!RegExp(r'\d{2}:\d{2}').hasMatch(key)) {
          metadata[key] = value;
        }
      }
    }

    return metadata;
  }

  /// 验证 LRC 内容是否有效
  static bool isValidLrc(String content) {
    if (content.isEmpty) return false;

    // 至少包含一个时间标签
    return RegExp(r'\[\d{2}:\d{2}\.?\d{0,3}\]').hasMatch(content);
  }
}
