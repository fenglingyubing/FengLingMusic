import 'package:sqflite/sqflite.dart';
import '../../models/playlist_model.dart';
import '../../models/song_model.dart';
import 'database_helper.dart';

/// Data Access Object for Playlists
/// Handles all database operations related to playlists
class PlaylistDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a playlist
  Future<int> insert(PlaylistModel playlist) async {
    final Database db = await _dbHelper.database;
    return await db.insert(
      'playlists',
      playlist.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update a playlist
  Future<int> update(PlaylistModel playlist) async {
    final Database db = await _dbHelper.database;
    return await db.update(
      'playlists',
      playlist.toDatabase(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  /// Delete a playlist
  Future<int> delete(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a playlist by ID
  Future<PlaylistModel?> findById(int id) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return PlaylistModel.fromDatabase(results.first);
  }

  /// Get all playlists
  Future<List<PlaylistModel>> findAll({
    int? limit,
    int? offset,
  }) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'playlists',
      orderBy: 'date_created DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => PlaylistModel.fromDatabase(map)).toList();
  }

  /// Search playlists by name
  Future<List<PlaylistModel>> search(String query) async {
    final Database db = await _dbHelper.database;
    final String searchPattern = '%$query%';

    final List<Map<String, dynamic>> results = await db.query(
      'playlists',
      where: 'name LIKE ?',
      whereArgs: [searchPattern],
      orderBy: 'name ASC',
    );

    return results.map((map) => PlaylistModel.fromDatabase(map)).toList();
  }

  /// Get playlist count
  Future<int> count() async {
    final Database db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM playlists');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Add a song to a playlist
  Future<int> addSong(int playlistId, int songId) async {
    final Database db = await _dbHelper.database;

    // Get the current max position in the playlist
    final maxPosResult = await db.rawQuery('''
      SELECT MAX(position) as max_pos
      FROM playlist_songs
      WHERE playlist_id = ?
    ''', [playlistId]);

    final int nextPosition = (Sqflite.firstIntValue(maxPosResult) ?? -1) + 1;

    // Insert the song
    final playlistSong = PlaylistSongModel(
      playlistId: playlistId,
      songId: songId,
      position: nextPosition,
      dateAdded: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await db.insert(
      'playlist_songs',
      playlistSong.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Update playlist statistics
    if (result > 0) {
      await _updatePlaylistStats(playlistId);
    }

    return result;
  }

  /// Add multiple songs to a playlist (batch operation)
  Future<void> addSongsBatch(int playlistId, List<int> songIds) async {
    final Database db = await _dbHelper.database;

    // Get the current max position
    final maxPosResult = await db.rawQuery('''
      SELECT MAX(position) as max_pos
      FROM playlist_songs
      WHERE playlist_id = ?
    ''', [playlistId]);

    int position = (Sqflite.firstIntValue(maxPosResult) ?? -1) + 1;
    final int now = DateTime.now().millisecondsSinceEpoch;

    final Batch batch = db.batch();

    for (final songId in songIds) {
      final playlistSong = PlaylistSongModel(
        playlistId: playlistId,
        songId: songId,
        position: position++,
        dateAdded: now,
      );

      batch.insert(
        'playlist_songs',
        playlistSong.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);

    // Update playlist statistics
    await _updatePlaylistStats(playlistId);
  }

  /// Remove a song from a playlist
  Future<int> removeSong(int playlistId, int songId) async {
    final Database db = await _dbHelper.database;

    final result = await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );

    if (result > 0) {
      // Reorder remaining songs
      await _reorderPlaylistSongs(playlistId);
      // Update playlist statistics
      await _updatePlaylistStats(playlistId);
    }

    return result;
  }

  /// Remove a song at specific position
  Future<int> removeSongAtPosition(int playlistId, int position) async {
    final Database db = await _dbHelper.database;

    final result = await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND position = ?',
      whereArgs: [playlistId, position],
    );

    if (result > 0) {
      await _reorderPlaylistSongs(playlistId);
      await _updatePlaylistStats(playlistId);
    }

    return result;
  }

  /// Clear all songs from a playlist
  Future<int> clearPlaylist(int playlistId) async {
    final Database db = await _dbHelper.database;

    final result = await db.delete(
      'playlist_songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    await _updatePlaylistStats(playlistId);
    return result;
  }

  /// Move a song to a new position in the playlist
  Future<void> moveSong(int playlistId, int fromPosition, int toPosition) async {
    final Database db = await _dbHelper.database;

    if (fromPosition == toPosition) return;

    await db.transaction((txn) async {
      if (fromPosition < toPosition) {
        // Moving down
        await txn.rawUpdate('''
          UPDATE playlist_songs
          SET position = position - 1
          WHERE playlist_id = ? AND position > ? AND position <= ?
        ''', [playlistId, fromPosition, toPosition]);
      } else {
        // Moving up
        await txn.rawUpdate('''
          UPDATE playlist_songs
          SET position = position + 1
          WHERE playlist_id = ? AND position >= ? AND position < ?
        ''', [playlistId, toPosition, fromPosition]);
      }

      // Update the moved song's position
      await txn.rawUpdate('''
        UPDATE playlist_songs
        SET position = ?
        WHERE playlist_id = ? AND position = ?
      ''', [toPosition, playlistId, fromPosition]);
    });
  }

  /// Get songs in a playlist
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    final Database db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT s.*
      FROM songs s
      INNER JOIN playlist_songs ps ON s.id = ps.song_id
      WHERE ps.playlist_id = ?
      ORDER BY ps.position ASC
    ''', [playlistId]);

    return results.map((map) => SongModel.fromDatabase(map)).toList();
  }

  /// Get playlist songs with position info
  Future<List<PlaylistSongModel>> getPlaylistSongModels(int playlistId) async {
    final Database db = await _dbHelper.database;

    final results = await db.query(
      'playlist_songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'position ASC',
    );

    return results.map((map) => PlaylistSongModel.fromDatabase(map)).toList();
  }

  /// Check if a song is in a playlist
  Future<bool> containsSong(int playlistId, int songId) async {
    final Database db = await _dbHelper.database;

    final result = await db.query(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Update playlist statistics (song count and total duration)
  Future<void> _updatePlaylistStats(int playlistId) async {
    final Database db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count, SUM(s.duration) as total_duration
      FROM playlist_songs ps
      INNER JOIN songs s ON ps.song_id = s.id
      WHERE ps.playlist_id = ?
    ''', [playlistId]);

    if (result.isNotEmpty) {
      final int count = Sqflite.firstIntValue(result) ?? 0;
      final int totalDuration = (result.first['total_duration'] as int?) ?? 0;

      await db.update(
        'playlists',
        {
          'song_count': count,
          'total_duration': totalDuration,
          'date_modified': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    }
  }

  /// Reorder playlist songs after deletion
  Future<void> _reorderPlaylistSongs(int playlistId) async {
    final Database db = await _dbHelper.database;

    // Get all songs ordered by position
    final results = await db.query(
      'playlist_songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'position ASC',
    );

    // Update positions sequentially
    final Batch batch = db.batch();
    for (int i = 0; i < results.length; i++) {
      batch.update(
        'playlist_songs',
        {'position': i},
        where: 'id = ?',
        whereArgs: [results[i]['id']],
      );
    }

    await batch.commit(noResult: true);
  }
}
