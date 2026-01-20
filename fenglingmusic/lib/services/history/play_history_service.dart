import '../../data/datasources/local/play_history_dao.dart';
import '../../data/datasources/local/song_dao.dart';
import '../../data/models/play_history_model.dart';
import '../../data/models/song_model.dart';

/// Service for managing play history
/// Handles recording, retrieving, and analyzing playback history
class PlayHistoryService {
  final PlayHistoryDAO _historyDao = PlayHistoryDAO();
  final SongDAO _songDao = SongDAO();

  /// Record a play event
  /// Call this when a song starts playing
  Future<void> recordPlay({
    required int songId,
    int playDuration = 0,
    double completionRate = 0.0,
    String? source,
  }) async {
    final history = PlayHistoryModel(
      songId: songId,
      playTimestamp: DateTime.now().millisecondsSinceEpoch,
      playDuration: playDuration,
      completionRate: completionRate,
      source: source,
    );

    await _historyDao.insert(history);

    // Update song play count if completion rate is high enough
    if (completionRate >= 0.5) {
      await _songDao.incrementPlayCount(songId);
    }
  }

  /// Record a skip event
  /// Call this when user skips to next song before completion
  Future<void> recordSkip(int songId) async {
    await _songDao.incrementSkipCount(songId);
  }

  /// Get recently played songs
  Future<List<SongModel>> getRecentlyPlayed({int limit = 50}) async {
    return await _historyDao.getRecentlyPlayed(limit: limit);
  }

  /// Get most played songs with play count
  Future<List<Map<String, dynamic>>> getMostPlayed({int limit = 50}) async {
    return await _historyDao.getMostPlayed(limit: limit);
  }

  /// Get play count for a specific song
  Future<int> getPlayCountForSong(int songId) async {
    return await _historyDao.getPlayCountForSong(songId);
  }

  /// Get total play time for a song (in seconds)
  Future<int> getTotalPlayTimeForSong(int songId) async {
    return await _historyDao.getTotalPlayTimeForSong(songId);
  }

  /// Get average completion rate for a song
  Future<double> getAverageCompletionRate(int songId) async {
    return await _historyDao.getAverageCompletionRate(songId);
  }

  /// Get play history for a date range
  Future<List<PlayHistoryModel>> getHistoryByDateRange({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) async {
    return await _historyDao.findByDateRange(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
      limit: limit,
    );
  }

  /// Get play statistics by date
  Future<List<Map<String, dynamic>>> getPlayStatsByDate({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _historyDao.getPlayStatsByDate(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
  }

  /// Get listening time by date (in seconds)
  Future<List<Map<String, dynamic>>> getListeningTimeByDate({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _historyDao.getListeningTimeByDate(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
  }

  /// Get top artists by play count
  Future<List<Map<String, dynamic>>> getTopArtists({int limit = 10}) async {
    return await _historyDao.getTopArtists(limit: limit);
  }

  /// Get top albums by play count
  Future<List<Map<String, dynamic>>> getTopAlbums({int limit = 10}) async {
    return await _historyDao.getTopAlbums(limit: limit);
  }

  /// Delete old history (older than specified days)
  Future<int> deleteOldHistory({int daysToKeep = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await _historyDao.deleteOlderThan(
      cutoffDate.millisecondsSinceEpoch,
    );
  }

  /// Clear all play history
  Future<int> clearAllHistory() async {
    return await _historyDao.deleteAll();
  }

  /// Get total play history count
  Future<int> getHistoryCount() async {
    return await _historyDao.count();
  }

  /// Get play history for a specific song
  Future<List<PlayHistoryModel>> getHistoryForSong(
    int songId, {
    int? limit,
  }) async {
    return await _historyDao.findBySongId(songId, limit: limit);
  }
}
