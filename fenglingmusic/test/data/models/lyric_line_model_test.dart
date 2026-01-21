import 'package:flutter_test/flutter_test.dart';
import 'package:fenglingmusic/data/models/lyric_line_model.dart';

void main() {
  group('LyricLineModel', () {
    group('Constructor', () {
      test('should create LyricLineModel with required fields', () {
        final line = LyricLineModel(
          timestamp: 12500,
          text: 'Test lyrics',
        );

        expect(line.timestamp, 12500);
        expect(line.text, 'Test lyrics');
        expect(line.translation, isNull);
      });

      test('should create LyricLineModel with translation', () {
        final line = LyricLineModel(
          timestamp: 12500,
          text: 'Test lyrics',
          translation: 'Translation text',
        );

        expect(line.timestamp, 12500);
        expect(line.text, 'Test lyrics');
        expect(line.translation, 'Translation text');
      });
    });

    group('formattedTimestamp', () {
      test('should format timestamp correctly', () {
        final line1 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
        );
        expect(line1.formattedTimestamp, '00:12.50');

        final line2 = LyricLineModel(
          timestamp: 125450,
          text: 'Test',
        );
        expect(line2.formattedTimestamp, '02:05.45');

        final line3 = LyricLineModel(
          timestamp: 3661999,
          text: 'Test',
        );
        expect(line3.formattedTimestamp, '61:01.99');
      });

      test('should handle zero timestamp', () {
        final line = LyricLineModel(
          timestamp: 0,
          text: 'Test',
        );

        expect(line.formattedTimestamp, '00:00.00');
      });

      test('should handle very small timestamps', () {
        final line = LyricLineModel(
          timestamp: 99,
          text: 'Test',
        );

        expect(line.formattedTimestamp, '00:00.09');
      });

      test('should pad single digits with zeros', () {
        final line = LyricLineModel(
          timestamp: 5099,
          text: 'Test',
        );

        expect(line.formattedTimestamp, '00:05.09');
      });

      test('should handle large timestamps', () {
        final line = LyricLineModel(
          timestamp: 5999999,
          text: 'Test',
        );

        expect(line.formattedTimestamp, '99:59.99');
      });
    });

    group('copyWith()', () {
      test('should create copy with modified fields', () {
        final original = LyricLineModel(
          timestamp: 12500,
          text: 'Original text',
        );

        final copy = original.copyWith(
          text: 'New text',
        );

        expect(copy.timestamp, 12500);
        expect(copy.text, 'New text');
        expect(copy.translation, isNull);
      });

      test('should create copy with translation added', () {
        final original = LyricLineModel(
          timestamp: 12500,
          text: 'Original text',
        );

        final copy = original.copyWith(
          translation: 'New translation',
        );

        expect(copy.timestamp, 12500);
        expect(copy.text, 'Original text');
        expect(copy.translation, 'New translation');
      });

      test('should maintain immutability', () {
        final original = LyricLineModel(
          timestamp: 12500,
          text: 'Original',
        );

        final modified = original.copyWith(text: 'Modified');

        expect(original.text, 'Original');
        expect(modified.text, 'Modified');
      });
    });

    group('Equality', () {
      test('should be equal with same values', () {
        final line1 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
        );

        final line2 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
        );

        expect(line1, equals(line2));
      });

      test('should be equal with same values including translation', () {
        final line1 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
          translation: 'Translation',
        );

        final line2 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
          translation: 'Translation',
        );

        expect(line1, equals(line2));
      });

      test('should not be equal with different timestamps', () {
        final line1 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
        );

        final line2 = LyricLineModel(
          timestamp: 15000,
          text: 'Test',
        );

        expect(line1, isNot(equals(line2)));
      });

      test('should not be equal with different text', () {
        final line1 = LyricLineModel(
          timestamp: 12500,
          text: 'Test 1',
        );

        final line2 = LyricLineModel(
          timestamp: 12500,
          text: 'Test 2',
        );

        expect(line1, isNot(equals(line2)));
      });

      test('should not be equal with different translations', () {
        final line1 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
          translation: 'Translation 1',
        );

        final line2 = LyricLineModel(
          timestamp: 12500,
          text: 'Test',
          translation: 'Translation 2',
        );

        expect(line1, isNot(equals(line2)));
      });
    });

    group('JSON Serialization', () {
      test('should convert to JSON', () {
        final line = LyricLineModel(
          timestamp: 12500,
          text: 'Test lyrics',
          translation: 'Translation',
        );

        final json = line.toJson();

        expect(json['timestamp'], 12500);
        expect(json['text'], 'Test lyrics');
        expect(json['translation'], 'Translation');
      });

      test('should convert from JSON', () {
        final json = {
          'timestamp': 12500,
          'text': 'Test lyrics',
          'translation': 'Translation',
        };

        final line = LyricLineModel.fromJson(json);

        expect(line.timestamp, 12500);
        expect(line.text, 'Test lyrics');
        expect(line.translation, 'Translation');
      });

      test('should handle null translation in JSON', () {
        final json = {
          'timestamp': 12500,
          'text': 'Test lyrics',
        };

        final line = LyricLineModel.fromJson(json);

        expect(line.timestamp, 12500);
        expect(line.text, 'Test lyrics');
        expect(line.translation, isNull);
      });
    });
  });
}
