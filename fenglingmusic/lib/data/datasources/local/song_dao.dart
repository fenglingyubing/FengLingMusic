import 'package:sqflite/sqflite.dart';
import '../../models/song_model.dart';
import 'database_helper.dart';

/// Data Access Object for Songs
/// Handles all database operations related to songs
class SongDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a song into the database
  Future<int> insert(SongModel song) async {
    final Database db = await _dbHelper.database;
    return await db.insert(
      'songs',
      song.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple songs (batch operation)
  Future<void> insertBatch(List<SongModel> songs) async {
    final Database db = await _dbHelper.database;
    final Batch batch = db.batch();

    for (final song in songs) {
      batch.insert(
        'songs',
        song.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Update a song
  Future<int> update(SongModel song) async {
    final Database db = await _dbHelper.database;
    return await db.update(
      'songs',
      song.toDatabase(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  /// Delete a song by ID
  Future<int> delete(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete multiple songs
  Future<int> deleteBatch(List<int> ids) async {
    final Database db = await _dbHelper.database;
    final String placeholders = ids.map((id) => '?').join(',');
    return await db.delete(
      'songs',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// Get a song by ID
  Future<SongModel?> findById(int id) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return SongModel.fromDatabase(results.first);
  }

  /// Get a song by file path
  Future<SongModel?> findByFilePath(String filePath) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'file_path = ?',
      whereArgs: [filePath],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return SongModel.fromDatabase(results.first);
  }

  /// Get all songs
  Future<List<SongModel>> findAll({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      orderBy: orderBy ?? 'title ASC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get songs by artist
  Future<List<SongModel>> findByArtist(String artist, {
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'artist = ?',
      whereArgs: [artist],
      orderBy: 'album ASC, track_number ASC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get songs by album
  Future<List<SongModel>> findByAlbum(String album, {
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'album = ?',
      whereArgs: [album],
      orderBy: 'disc_number ASC, track_number ASC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get songs by genre
  Future<List<SongModel>> findByGenre(String genre, {
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'genre = ?',
      whereArgs: [genre],
      orderBy: 'title ASC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get favorite songs
  Future<List<SongModel>> findFavorites({
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'is_favorite = 1',
      orderBy: 'date_modified DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get recently added songs
  Future<List<SongModel>> findRecentlyAdded({
    int limit = 50,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      orderBy: 'date_added DESC',
      limit: limit,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get most played songs
  Future<List<SongModel>> findMostPlayed({
    int limit = 50,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'play_count > 0',
      orderBy: 'play_count DESC',
      limit: limit,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Search songs by text
  Future<List<SongModel>> search(String query, {
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final String searchPattern = '%$query%';

    final List<Map<String, dynamic>> results = await db.query(
      'songs',
      where: 'title LIKE ? OR artist LIKE ? OR album LIKE ?',
      whereArgs: [searchPattern, searchPattern, searchPattern],
      orderBy: 'title ASC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(int id) async {
    final Database db = await _dbHelper.database;

    // Get current favorite status
    final song = await findById(id);
    if (song == null) return 0;

    // Toggle the status
    return await db.update(
      'songs',
      {
        'is_favorite': song.isFavorite ? 0 : 1,
        'date_modified': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increment play count
  Future<int> incrementPlayCount(int id) async {
    final Database db = await _dbHelper.database;
    return await db.rawUpdate('''
      UPDATE songs
      SET play_count = play_count + 1,
          last_played = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, id]);
  }

  /// Increment skip count
  Future<int> incrementSkipCount(int id) async {
    final Database db = await _dbHelper.database;
    return await db.rawUpdate('''
      UPDATE songs
      SET skip_count = skip_count + 1
      WHERE id = ?
    ''', [id]);
  }

  /// Update rating
  Future<int> updateRating(int id, double rating) async {
    final Database db = await _dbHelper.database;
    return await db.update(
      'songs',
      {
        'rating': rating,
        'date_modified': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total song count
  Future<int> count() async {
    final Database db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total duration of all songs
  Future<int> getTotalDuration() async {
    final Database db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(duration) as total FROM songs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if a file path already exists
  Future<bool> filePathExists(String filePath) async {
    final Database db = await _dbHelper.database;
    final result = await db.query(
      'songs',
      columns: ['id'],
      where: 'file_path = ?',
      whereArgs: [filePath],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Get all unique artists
  Future<List<String>> getAllArtists() async {
    final Database db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT artist
      FROM songs
      WHERE artist IS NOT NULL AND artist != ''
      ORDER BY artist ASC
    ''');
    return results.map((map) => map['artist'] as String).toList();
  }

  /// Get all unique albums
  Future<List<String>> getAllAlbums() async {
    final Database db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT album
      FROM songs
      WHERE album IS NOT NULL AND album != ''
      ORDER BY album ASC
    ''');
    return results.map((map) => map['album'] as String).toList();
  }

  /// Get all unique genres
  Future<List<String>> getAllGenres() async {
    final Database db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT genre
      FROM songs
      WHERE genre IS NOT NULL AND genre != ''
      ORDER BY genre ASC
    ''');
    return results.map((map) => map['genre'] as String).toList();
  }
}
