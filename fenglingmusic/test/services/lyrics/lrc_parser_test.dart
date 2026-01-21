import 'package:flutter_test/flutter_test.dart';
import 'package:fenglingmusic/services/lyrics/lrc_parser.dart';
import 'package:fenglingmusic/data/models/lyric_line_model.dart';

void main() {
  group('LrcParser', () {
    group('parse()', () {
      test('should parse standard LRC format', () {
        const lrcContent = '''
[00:12.50]Line 1
[00:17.20]Line 2
[00:21.10]Line 3
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 3);
        expect(result[0].timestamp, 12500);
        expect(result[0].text, 'Line 1');
        expect(result[1].timestamp, 17200);
        expect(result[1].text, 'Line 2');
        expect(result[2].timestamp, 21100);
        expect(result[2].text, 'Line 3');
      });

      test('should parse LRC format without milliseconds', () {
        const lrcContent = '''
[00:12]Line 1
[00:17]Line 2
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 2);
        expect(result[0].timestamp, 12000);
        expect(result[0].text, 'Line 1');
        expect(result[1].timestamp, 17000);
        expect(result[1].text, 'Line 2');
      });

      test('should handle multiple timestamps per line', () {
        const lrcContent = '''
[00:12.50][00:50.30]Repeated line
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 2);
        expect(result[0].timestamp, 12500);
        expect(result[0].text, 'Repeated line');
        expect(result[1].timestamp, 50300);
        expect(result[1].text, 'Repeated line');
      });

      test('should replace empty lines with music symbol', () {
        const lrcContent = '''
[00:12.50]
[00:17.20]Line with text
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 2);
        expect(result[0].text, '♪');
        expect(result[1].text, 'Line with text');
      });

      test('should skip metadata tags', () {
        const lrcContent = '''
[ti:Song Title]
[ar:Artist Name]
[al:Album Name]
[00:12.50]Actual lyrics
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 1);
        expect(result[0].text, 'Actual lyrics');
      });

      test('should parse enhanced LRC format', () {
        const lrcContent = '''
[00:12.50]<00:12.50>Word1<00:13.00>Word2
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 1);
        expect(result[0].text, 'Word1Word2');
      });

      test('should sort lyrics by timestamp', () {
        const lrcContent = '''
[00:21.10]Line 3
[00:12.50]Line 1
[00:17.20]Line 2
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 3);
        expect(result[0].text, 'Line 1');
        expect(result[1].text, 'Line 2');
        expect(result[2].text, 'Line 3');
      });

      test('should return empty list for empty content', () {
        const lrcContent = '';

        final result = LrcParser.parse(lrcContent);

        expect(result, isEmpty);
      });

      test('should merge translations with exact match', () {
        const lrcContent = '''
[00:12.50]English line 1
[00:17.20]English line 2
''';
        const translationContent = '''
[00:12.50]中文翻译 1
[00:17.20]中文翻译 2
''';

        final result = LrcParser.parse(lrcContent, translationContent: translationContent);

        expect(result.length, 2);
        expect(result[0].text, 'English line 1');
        expect(result[0].translation, '中文翻译 1');
        expect(result[1].text, 'English line 2');
        expect(result[1].translation, '中文翻译 2');
      });

      test('should merge translations with time tolerance', () {
        const lrcContent = '''
[00:12.50]English line
''';
        const translationContent = '''
[00:12.30]中文翻译
''';

        final result = LrcParser.parse(lrcContent, translationContent: translationContent);

        expect(result.length, 1);
        expect(result[0].translation, '中文翻译');
      });

      test('should not merge music symbol translations', () {
        const lrcContent = '''
[00:12.50]
''';
        const translationContent = '''
[00:12.50]♪
''';

        final result = LrcParser.parse(lrcContent, translationContent: translationContent);

        expect(result.length, 1);
        expect(result[0].translation, isNull);
      });
    });

    group('extractMetadata()', () {
      test('should extract common metadata tags', () {
        const lrcContent = '''
[ti:Song Title]
[ar:Artist Name]
[al:Album Name]
[by:Creator]
[00:12.50]Lyrics
''';

        final metadata = LrcParser.extractMetadata(lrcContent);

        expect(metadata['ti'], 'Song Title');
        expect(metadata['ar'], 'Artist Name');
        expect(metadata['al'], 'Album Name');
        expect(metadata['by'], 'Creator');
      });

      test('should extract only metadata tags', () {
        const lrcContent = '''
[ti:Song Title]
[ar:Artist]
[al:Album]
''';

        final metadata = LrcParser.extractMetadata(lrcContent);

        expect(metadata['ti'], 'Song Title');
        expect(metadata['ar'], 'Artist');
        expect(metadata['al'], 'Album');
        expect(metadata.length, 3);
      });

      test('should handle empty content', () {
        const lrcContent = '';

        final metadata = LrcParser.extractMetadata(lrcContent);

        expect(metadata, isEmpty);
      });

      test('should convert metadata keys to lowercase', () {
        const lrcContent = '''
[TI:Song Title]
[AR:Artist Name]
''';

        final metadata = LrcParser.extractMetadata(lrcContent);

        expect(metadata['ti'], 'Song Title');
        expect(metadata['ar'], 'Artist Name');
      });
    });

    group('isValidLrc()', () {
      test('should return true for valid LRC content', () {
        const lrcContent = '[00:12.50]Line 1';

        final result = LrcParser.isValidLrc(lrcContent);

        expect(result, true);
      });

      test('should return true for LRC without milliseconds', () {
        const lrcContent = '[00:12]Line 1';

        final result = LrcParser.isValidLrc(lrcContent);

        expect(result, true);
      });

      test('should return false for empty content', () {
        const lrcContent = '';

        final result = LrcParser.isValidLrc(lrcContent);

        expect(result, false);
      });

      test('should return false for content without time tags', () {
        const lrcContent = 'Just some text without time tags';

        final result = LrcParser.isValidLrc(lrcContent);

        expect(result, false);
      });

      test('should return true for content with metadata and time tags', () {
        const lrcContent = '''
[ti:Song Title]
[00:12.50]Line 1
''';

        final result = LrcParser.isValidLrc(lrcContent);

        expect(result, true);
      });
    });

    group('Edge cases', () {
      test('should handle very long timestamps', () {
        const lrcContent = '[99:59.99]Long song';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 1);
        expect(result[0].timestamp, 5999990);
      });

      test('should handle 3-digit milliseconds', () {
        const lrcContent = '[00:12.999]Line';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 1);
        expect(result[0].timestamp, 12999);
      });

      test('should handle mixed line endings', () {
        const lrcContent = '[00:12.50]Line 1\r\n[00:17.20]Line 2\n[00:21.10]Line 3';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 3);
      });

      test('should handle lines with only whitespace', () {
        const lrcContent = '''
[00:12.50]Line 1

[00:17.20]Line 2
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 2);
        expect(result[0].text, 'Line 1');
        expect(result[1].text, 'Line 2');
      });

      test('should handle special characters in lyrics', () {
        const lrcContent = '[00:12.50]Special chars: @#\$%^&*()';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 1);
        expect(result[0].text, 'Special chars: @#\$%^&*()');
      });

      test('should handle unicode characters', () {
        const lrcContent = '''
[00:12.50]中文歌词
[00:17.20]日本語の歌詞
[00:21.10]한국어 가사
''';

        final result = LrcParser.parse(lrcContent);

        expect(result.length, 3);
        expect(result[0].text, '中文歌词');
        expect(result[1].text, '日本語の歌詞');
        expect(result[2].text, '한국어 가사');
      });
    });
  });
}
