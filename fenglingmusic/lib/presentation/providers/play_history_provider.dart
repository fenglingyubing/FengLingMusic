import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/song_model.dart';
import '../../data/models/play_history_model.dart';
import '../../services/history/play_history_service.dart';

part 'play_history_provider.g.dart';

/// Provider for play history service
final playHistoryServiceProvider = Provider<PlayHistoryService>((ref) {
  return PlayHistoryService();
});

/// Provider for recently played songs
@riverpod
class RecentlyPlayed extends _$RecentlyPlayed {
  @override
  FutureOr<List<SongModel>> build() async {
    final service = ref.read(playHistoryServiceProvider);
    return await service.getRecentlyPlayed(limit: 50);
  }

  /// Load recently played songs
  Future<void> loadRecentlyPlayed({int limit = 50}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(playHistoryServiceProvider);
      return await service.getRecentlyPlayed(limit: limit);
    });
  }

  /// Refresh the list
  Future<void> refresh() async {
    await loadRecentlyPlayed();
  }
}

/// Provider for most played songs with play counts
@riverpod
class MostPlayed extends _$MostPlayed {
  @override
  FutureOr<List<Map<String, dynamic>>> build() async {
    final service = ref.read(playHistoryServiceProvider);
    final rawData = await service.getMostPlayed(limit: 50);

    // Transform the data to include song models
    return rawData.map((data) {
      final song = SongModel.fromDatabase(data);
      return {
        'song': song,
        'play_count': data['play_count'] as int,
      };
    }).toList();
  }

  /// Load most played songs
  Future<void> loadMostPlayed({int limit = 50}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(playHistoryServiceProvider);
      final rawData = await service.getMostPlayed(limit: limit);

      return rawData.map((data) {
        final song = SongModel.fromDatabase(data);
        return {
          'song': song,
          'play_count': data['play_count'] as int,
        };
      }).toList();
    });
  }

  /// Refresh the list
  Future<void> refresh() async {
    await loadMostPlayed();
  }
}

/// Provider for recording play events
@riverpod
class PlayRecorder extends _$PlayRecorder {
  @override
  void build() {
    // No initial state needed
  }

  /// Record a play event
  Future<void> recordPlay({
    required int songId,
    int playDuration = 0,
    double completionRate = 0.0,
    String? source,
  }) async {
    final service = ref.read(playHistoryServiceProvider);
    await service.recordPlay(
      songId: songId,
      playDuration: playDuration,
      completionRate: completionRate,
      source: source,
    );

    // Invalidate the recently played and most played providers to refresh them
    ref.invalidate(recentlyPlayedProvider);
    ref.invalidate(mostPlayedProvider);
  }

  /// Record a skip event
  Future<void> recordSkip(int songId) async {
    final service = ref.read(playHistoryServiceProvider);
    await service.recordSkip(songId);
  }
}

/// Provider for play statistics
@riverpod
class PlayStatistics extends _$PlayStatistics {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    final service = ref.read(playHistoryServiceProvider);

    // Get various statistics
    final historyCount = await service.getHistoryCount();
    final topArtists = await service.getTopArtists(limit: 5);
    final topAlbums = await service.getTopAlbums(limit: 5);

    // Get listening time for the last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final listeningTimeData = await service.getListeningTimeByDate(
      start: startDate,
      end: endDate,
    );

    final totalListeningTime = listeningTimeData.fold<int>(
      0,
      (sum, data) => sum + ((data['total_duration'] as num?)?.toInt() ?? 0),
    );

    return {
      'total_plays': historyCount,
      'top_artists': topArtists,
      'top_albums': topAlbums,
      'total_listening_time_seconds': totalListeningTime,
      'listening_time_by_date': listeningTimeData,
    };
  }

  /// Refresh statistics
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider for getting play count of a specific song
@riverpod
Future<int> songPlayCount(SongPlayCountRef ref, int songId) async {
  final service = ref.read(playHistoryServiceProvider);
  return await service.getPlayCountForSong(songId);
}

/// Provider for getting total play time of a specific song
@riverpod
Future<int> songTotalPlayTime(SongTotalPlayTimeRef ref, int songId) async {
  final service = ref.read(playHistoryServiceProvider);
  return await service.getTotalPlayTimeForSong(songId);
}

/// Provider for clearing history
@riverpod
class HistoryManager extends _$HistoryManager {
  @override
  void build() {
    // No initial state needed
  }

  /// Delete old history (older than specified days)
  Future<int> deleteOldHistory({int daysToKeep = 90}) async {
    final service = ref.read(playHistoryServiceProvider);
    final count = await service.deleteOldHistory(daysToKeep: daysToKeep);

    // Invalidate all history-related providers
    ref.invalidate(recentlyPlayedProvider);
    ref.invalidate(mostPlayedProvider);
    ref.invalidate(playStatisticsProvider);

    return count;
  }

  /// Clear all history
  Future<int> clearAllHistory() async {
    final service = ref.read(playHistoryServiceProvider);
    final count = await service.clearAllHistory();

    // Invalidate all history-related providers
    ref.invalidate(recentlyPlayedProvider);
    ref.invalidate(mostPlayedProvider);
    ref.invalidate(playStatisticsProvider);

    return count;
  }
}
