import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/playlist_model.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/playlist_repository_impl.dart';
import '../../domain/repositories/i_playlist_repository.dart';

/// Provider for playlist repository
final playlistRepositoryProvider = Provider<IPlaylistRepository>((ref) {
  return PlaylistRepositoryImpl();
});

/// Provider for all playlists
final playlistsProvider = StreamProvider<List<PlaylistModel>>((ref) async* {
  final repository = ref.watch(playlistRepositoryProvider);

  // Initial load
  yield await repository.getAllPlaylists();

  // Poll for updates every 2 seconds
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    yield await repository.getAllPlaylists();
  }
});

/// Provider for a specific playlist
final playlistProvider = FutureProvider.family<PlaylistModel?, int>((ref, id) async {
  final repository = ref.watch(playlistRepositoryProvider);
  return await repository.getPlaylistById(id);
});

/// Provider for songs in a playlist
final playlistSongsProvider = FutureProvider.family<List<SongModel>, int>((ref, playlistId) async {
  final repository = ref.watch(playlistRepositoryProvider);
  return await repository.getPlaylistSongs(playlistId);
});

/// State notifier for playlist operations
class PlaylistNotifier extends StateNotifier<AsyncValue<List<PlaylistModel>>> {
  final IPlaylistRepository _repository;

  PlaylistNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    state = const AsyncValue.loading();
    try {
      final playlists = await _repository.getAllPlaylists();
      state = AsyncValue.data(playlists);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> createPlaylist({
    required String name,
    String? description,
    String? coverPath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final playlist = PlaylistModel(
      name: name,
      description: description,
      coverPath: coverPath,
      dateCreated: now,
      dateModified: now,
    );

    final id = await _repository.createPlaylist(playlist);
    await loadPlaylists();
    return id;
  }

  Future<void> updatePlaylist(PlaylistModel playlist) async {
    await _repository.updatePlaylist(
      playlist.copyWith(dateModified: DateTime.now().millisecondsSinceEpoch),
    );
    await loadPlaylists();
  }

  Future<void> deletePlaylist(int id) async {
    await _repository.deletePlaylist(id);
    await loadPlaylists();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _repository.addSongToPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    await _repository.addSongsToPlaylist(playlistId, songIds);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _repository.removeSongFromPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> clearPlaylist(int playlistId) async {
    await _repository.clearPlaylist(playlistId);
    await loadPlaylists();
  }

  Future<void> reorderSong(int playlistId, int oldIndex, int newIndex) async {
    await _repository.moveSongInPlaylist(playlistId, oldIndex, newIndex);
  }
}

/// Provider for playlist notifier
final playlistNotifierProvider = StateNotifierProvider<PlaylistNotifier, AsyncValue<List<PlaylistModel>>>((ref) {
  final repository = ref.watch(playlistRepositoryProvider);
  return PlaylistNotifier(repository);
});
