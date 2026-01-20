import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/song_model.dart';
import '../../data/datasources/local/song_dao.dart';

part 'favorites_provider.g.dart';

/// Provider for managing favorite songs
@riverpod
class Favorites extends _$Favorites {
  final SongDAO _songDao = SongDAO();

  @override
  FutureOr<List<SongModel>> build() async {
    return await _songDao.findFavorites();
  }

  /// Load favorites from database
  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _songDao.findFavorites();
    });
  }

  /// Toggle favorite status of a song
  Future<void> toggleFavorite(int songId) async {
    // Optimistically update the UI
    state.whenData((favorites) {
      final index = favorites.indexWhere((song) => song.id == songId);
      if (index != -1) {
        // Remove from favorites if already favorited
        state = AsyncValue.data(
          List.from(favorites)..removeAt(index),
        );
      }
    });

    // Update database
    await _songDao.toggleFavorite(songId);

    // Reload to ensure consistency
    await loadFavorites();
  }

  /// Add a song to favorites
  Future<void> addFavorite(int songId) async {
    final song = await _songDao.findById(songId);
    if (song != null && !song.isFavorite) {
      await _songDao.toggleFavorite(songId);
      await loadFavorites();
    }
  }

  /// Remove a song from favorites
  Future<void> removeFavorite(int songId) async {
    final song = await _songDao.findById(songId);
    if (song != null && song.isFavorite) {
      await _songDao.toggleFavorite(songId);
      await loadFavorites();
    }
  }

  /// Get favorite count
  Future<int> getFavoriteCount() async {
    return state.value?.length ?? 0;
  }

  /// Check if a song is favorited
  bool isFavorite(int songId) {
    return state.value?.any((song) => song.id == songId) ?? false;
  }
}
