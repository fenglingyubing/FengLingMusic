import 'package:flutter_test/flutter_test.dart';
import 'package:fenglingmusic/data/models/song_model.dart';

void main() {
  group('SongModel', () {
    group('fromDatabase()', () {
      test('should create SongModel from database map with all fields', () {
        final map = {
          'id': 1,
          'title': 'Test Song',
          'artist': 'Test Artist',
          'album': 'Test Album',
          'album_artist': 'Test Album Artist',
          'duration': 180,
          'file_path': '/path/to/song.mp3',
          'file_size': 3000000,
          'mime_type': 'audio/mpeg',
          'bit_rate': 320000,
          'sample_rate': 44100,
          'track_number': 5,
          'disc_number': 1,
          'year': 2024,
          'genre': 'Rock',
          'cover_path': '/path/to/cover.jpg',
          'lyrics_path': '/path/to/lyrics.lrc',
          'is_favorite': 1,
          'play_count': 10,
          'skip_count': 2,
          'rating': 4.5,
          'date_added': 1700000000000,
          'date_modified': 1700000000000,
          'last_played': 1700000000000,
        };

        final song = SongModel.fromDatabase(map);

        expect(song.id, 1);
        expect(song.title, 'Test Song');
        expect(song.artist, 'Test Artist');
        expect(song.album, 'Test Album');
        expect(song.albumArtist, 'Test Album Artist');
        expect(song.duration, 180);
        expect(song.filePath, '/path/to/song.mp3');
        expect(song.fileSize, 3000000);
        expect(song.mimeType, 'audio/mpeg');
        expect(song.bitRate, 320000);
        expect(song.sampleRate, 44100);
        expect(song.trackNumber, 5);
        expect(song.discNumber, 1);
        expect(song.year, 2024);
        expect(song.genre, 'Rock');
        expect(song.coverPath, '/path/to/cover.jpg');
        expect(song.lyricsPath, '/path/to/lyrics.lrc');
        expect(song.isFavorite, true);
        expect(song.playCount, 10);
        expect(song.skipCount, 2);
        expect(song.rating, 4.5);
        expect(song.dateAdded, 1700000000000);
        expect(song.dateModified, 1700000000000);
        expect(song.lastPlayed, 1700000000000);
      });

      test('should handle null optional fields', () {
        final map = {
          'title': 'Test Song',
          'file_path': '/path/to/song.mp3',
          'date_added': 1700000000000,
          'date_modified': 1700000000000,
        };

        final song = SongModel.fromDatabase(map);

        expect(song.id, isNull);
        expect(song.title, 'Test Song');
        expect(song.artist, isNull);
        expect(song.album, isNull);
        expect(song.duration, 0);
        expect(song.isFavorite, false);
        expect(song.playCount, 0);
        expect(song.skipCount, 0);
        expect(song.rating, 0.0);
      });

      test('should convert is_favorite integer to boolean', () {
        final mapTrue = {
          'title': 'Test Song',
          'file_path': '/path/to/song.mp3',
          'is_favorite': 1,
          'date_added': 1700000000000,
          'date_modified': 1700000000000,
        };

        final mapFalse = {
          'title': 'Test Song',
          'file_path': '/path/to/song.mp3',
          'is_favorite': 0,
          'date_added': 1700000000000,
          'date_modified': 1700000000000,
        };

        final songTrue = SongModel.fromDatabase(mapTrue);
        final songFalse = SongModel.fromDatabase(mapFalse);

        expect(songTrue.isFavorite, true);
        expect(songFalse.isFavorite, false);
      });
    });

    group('toDatabase()', () {
      test('should convert SongModel to database map', () {
        final song = SongModel(
          id: 1,
          title: 'Test Song',
          artist: 'Test Artist',
          album: 'Test Album',
          duration: 180,
          filePath: '/path/to/song.mp3',
          fileSize: 3000000,
          isFavorite: true,
          playCount: 10,
          dateAdded: 1700000000000,
          dateModified: 1700000000000,
        );

        final map = song.toDatabase();

        expect(map['id'], 1);
        expect(map['title'], 'Test Song');
        expect(map['artist'], 'Test Artist');
        expect(map['album'], 'Test Album');
        expect(map['duration'], 180);
        expect(map['file_path'], '/path/to/song.mp3');
        expect(map['file_size'], 3000000);
        expect(map['is_favorite'], 1);
        expect(map['play_count'], 10);
        expect(map['date_added'], 1700000000000);
        expect(map['date_modified'], 1700000000000);
      });

      test('should convert isFavorite boolean to integer', () {
        final songTrue = SongModel(
          title: 'Test Song',
          filePath: '/path/to/song.mp3',
          isFavorite: true,
          dateAdded: 1700000000000,
          dateModified: 1700000000000,
        );

        final songFalse = SongModel(
          title: 'Test Song',
          filePath: '/path/to/song.mp3',
          isFavorite: false,
          dateAdded: 1700000000000,
          dateModified: 1700000000000,
        );

        expect(songTrue.toDatabase()['is_favorite'], 1);
        expect(songFalse.toDatabase()['is_favorite'], 0);
      });

      test('should not include id if null', () {
        final song = SongModel(
          title: 'Test Song',
          filePath: '/path/to/song.mp3',
          dateAdded: 1700000000000,
          dateModified: 1700000000000,
        );

        final map = song.toDatabase();

        expect(map.containsKey('id'), false);
      });

      test('should include null values for optional fields', () {
        final song = SongModel(
          title: 'Test Song',
          filePath: '/path/to/song.mp3',
          artist: null,
          album: null,
          dateAdded: 1700000000000,
          dateModified: 1700000000000,
        );

        final map = song.toDatabase();

        expect(map['artist'], isNull);
        expect(map['album'], isNull);
      });
    });

    group('formattedDuration', () {
      test('should format duration correctly', () {
        final song1 = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 65,
          dateAdded: 0,
          dateModified: 0,
        );
        expect(song1.formattedDuration, '01:05');

        final song2 = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 125,
          dateAdded: 0,
          dateModified: 0,
        );
        expect(song2.formattedDuration, '02:05');

        final song3 = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 3661,
          dateAdded: 0,
          dateModified: 0,
        );
        expect(song3.formattedDuration, '61:01');
      });

      test('should handle zero duration', () {
        final song = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 0,
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song.formattedDuration, '00:00');
      });

      test('should pad single digits with zero', () {
        final song = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 9,
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song.formattedDuration, '00:09');
      });
    });

    group('displayArtist', () {
      test('should return artist if present', () {
        final song = SongModel(
          title: 'Test',
          filePath: '/test',
          artist: 'Test Artist',
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song.displayArtist, 'Test Artist');
      });

      test('should return "Unknown Artist" if artist is null', () {
        final song = SongModel(
          title: 'Test',
          filePath: '/test',
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song.displayArtist, 'Unknown Artist');
      });
    });

    group('displayAlbum', () {
      test('should return album if present', () {
        final song = SongModel(
          title: 'Test',
          filePath: '/test',
          album: 'Test Album',
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song.displayAlbum, 'Test Album');
      });

      test('should return "Unknown Album" if album is null', () {
        final song = SongModel(
          title: 'Test',
          filePath: '/test',
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song.displayAlbum, 'Unknown Album');
      });
    });

    group('copyWith()', () {
      test('should create copy with modified fields', () {
        final original = SongModel(
          id: 1,
          title: 'Original Title',
          artist: 'Original Artist',
          filePath: '/original/path',
          duration: 100,
          dateAdded: 1700000000000,
          dateModified: 1700000000000,
        );

        final copy = original.copyWith(
          title: 'New Title',
          duration: 200,
        );

        expect(copy.id, 1);
        expect(copy.title, 'New Title');
        expect(copy.artist, 'Original Artist');
        expect(copy.filePath, '/original/path');
        expect(copy.duration, 200);
      });

      test('should maintain immutability', () {
        final original = SongModel(
          title: 'Original',
          filePath: '/path',
          dateAdded: 0,
          dateModified: 0,
        );

        final modified = original.copyWith(title: 'Modified');

        expect(original.title, 'Original');
        expect(modified.title, 'Modified');
      });
    });

    group('Equality', () {
      test('should be equal with same values', () {
        final song1 = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 100,
          dateAdded: 0,
          dateModified: 0,
        );

        final song2 = SongModel(
          title: 'Test',
          filePath: '/test',
          duration: 100,
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song1, equals(song2));
      });

      test('should not be equal with different values', () {
        final song1 = SongModel(
          title: 'Test 1',
          filePath: '/test1',
          dateAdded: 0,
          dateModified: 0,
        );

        final song2 = SongModel(
          title: 'Test 2',
          filePath: '/test2',
          dateAdded: 0,
          dateModified: 0,
        );

        expect(song1, isNot(equals(song2)));
      });
    });
  });
}
