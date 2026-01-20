import 'package:sqflite/sqflite.dart';
import '../../models/play_history_model.dart';
import '../../models/song_model.dart';
import 'database_helper.dart';

/// Data Access Object for Play History
/// Handles all database operations related to play history
class PlayHistoryDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a play history record
  Future<int> insert(PlayHistoryModel history) async {
    final Database db = await _dbHelper.database;
    return await db.insert(
      'play_history',
      history.toDatabase(),
    );
  }

  /// Insert multiple play history records (batch operation)
  Future<void> insertBatch(List<PlayHistoryModel> histories) async {
    final Database db = await _dbHelper.database;
    final Batch batch = db.batch();

    for (final history in histories) {
      batch.insert('play_history', history.toDatabase());
    }

    await batch.commit(noResult: true);
  }

  /// Delete a play history record
  Future<int> delete(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'play_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all play history for a specific song
  Future<int> deleteBySongId(int songId) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'play_history',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
  }

  /// Delete play history older than a specific timestamp
  Future<int> deleteOlderThan(int timestamp) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'play_history',
      where: 'play_timestamp < ?',
      whereArgs: [timestamp],
    );
  }

  /// Clear all play history
  Future<int> deleteAll() async {
    final Database db = await _dbHelper.database;
    return await db.delete('play_history');
  }

  /// Get a play history record by ID
  Future<PlayHistoryModel?> findById(int id) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'play_history',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return PlayHistoryModel.fromDatabase(results.first);
  }

  /// Get all play history
  Future<List<PlayHistoryModel>> findAll({
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'play_history',
      orderBy: 'play_timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => PlayHistoryModel.fromDatabase(map)).toList();
  }

  /// Get play history for a specific song
  Future<List<PlayHistoryModel>> findBySongId(int songId, {
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'play_history',
      where: 'song_id = ?',
      whereArgs: [songId],
      orderBy: 'play_timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => PlayHistoryModel.fromDatabase(map)).toList();
  }

  /// Get recently played songs (with song details)
  Future<List<SongModel>> getRecentlyPlayed({
    int limit = 50,
  }) async {
    final Database db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT DISTINCT s.*, ph.play_timestamp
      FROM songs s
      INNER JOIN play_history ph ON s.id = ph.song_id
      ORDER BY ph.play_timestamp DESC
      LIMIT ?
    ''', [limit]);

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get most played songs
  Future<List<Map<String, dynamic>>> getMostPlayed({
    int limit = 50,
  }) async {
    final Database db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT s.*, COUNT(ph.id) as play_count
      FROM songs s
      INNER JOIN play_history ph ON s.id = ph.song_id
      GROUP BY s.id
      ORDER BY play_count DESC
      LIMIT ?
    ''', [limit]);
  }

  /// Get play count for a song
  Future<int> getPlayCountForSong(int songId) async {
    final Database db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM play_history
      WHERE song_id = ?
    ''', [songId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total play time for a song (in seconds)
  Future<int> getTotalPlayTimeForSong(int songId) async {
    final Database db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT SUM(play_duration) as total
      FROM play_history
      WHERE song_id = ?
    ''', [songId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get average completion rate for a song
  Future<double> getAverageCompletionRate(int songId) async {
    final Database db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT AVG(completion_rate) as avg_rate
      FROM play_history
      WHERE song_id = ?
    ''', [songId]);

    if (result.isEmpty) return 0.0;
    return (result.first['avg_rate'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get play history count
  Future<int> count() async {
    final Database db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM play_history');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get play history for a date range
  Future<List<PlayHistoryModel>> findByDateRange(
    int startTimestamp,
    int endTimestamp, {
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.query(
      'play_history',
      where: 'play_timestamp >= ? AND play_timestamp <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'play_timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => PlayHistoryModel.fromDatabase(map)).toList();
  }

  /// Get play statistics by date
  Future<List<Map<String, dynamic>>> getPlayStatsByDate(
    int startTimestamp,
    int endTimestamp,
  ) async {
    final Database db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT
        DATE(play_timestamp / 1000, 'unixepoch') as date,
        COUNT(*) as play_count,
        COUNT(DISTINCT song_id) as unique_songs
      FROM play_history
      WHERE play_timestamp >= ? AND play_timestamp <= ?
      GROUP BY date
      ORDER BY date DESC
    ''', [startTimestamp, endTimestamp]);
  }

  /// Get listening time by date (in seconds)
  Future<List<Map<String, dynamic>>> getListeningTimeByDate(
    int startTimestamp,
    int endTimestamp,
  ) async {
    final Database db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT
        DATE(play_timestamp / 1000, 'unixepoch') as date,
        SUM(play_duration) as total_duration
      FROM play_history
      WHERE play_timestamp >= ? AND play_timestamp <= ?
      GROUP BY date
      ORDER BY date DESC
    ''', [startTimestamp, endTimestamp]);
  }

  /// Get top artists by play count
  Future<List<Map<String, dynamic>>> getTopArtists({
    int limit = 10,
  }) async {
    final Database db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT s.artist, COUNT(ph.id) as play_count
      FROM songs s
      INNER JOIN play_history ph ON s.id = ph.song_id
      WHERE s.artist IS NOT NULL AND s.artist != ''
      GROUP BY s.artist
      ORDER BY play_count DESC
      LIMIT ?
    ''', [limit]);
  }

  /// Get top albums by play count
  Future<List<Map<String, dynamic>>> getTopAlbums({
    int limit = 10,
  }) async {
    final Database db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT s.album, s.artist, COUNT(ph.id) as play_count
      FROM songs s
      INNER JOIN play_history ph ON s.id = ph.song_id
      WHERE s.album IS NOT NULL AND s.album != ''
      GROUP BY s.album, s.artist
      ORDER BY play_count DESC
      LIMIT ?
    ''', [limit]);
  }
}
