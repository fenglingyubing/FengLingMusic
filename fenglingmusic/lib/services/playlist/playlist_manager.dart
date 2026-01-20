import '../../data/models/playlist_model.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/playlist_repository_impl.dart';

/// Playlist management service
/// Provides high-level operations for managing playlists
class PlaylistManager {
  final PlaylistRepositoryImpl _playlistRepository;

  PlaylistManager({PlaylistRepositoryImpl? playlistRepository})
      : _playlistRepository = playlistRepository ?? PlaylistRepositoryImpl();

  /// Create a new empty playlist
  ///
  /// [name] - The name of the playlist
  /// [description] - Optional description
  ///
  /// Returns the ID of the created playlist
  Future<int> createPlaylist({
    required String name,
    String? description,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Playlist name cannot be empty');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final playlist = PlaylistModel(
      name: name.trim(),
      description: description?.trim(),
      dateCreated: now,
      dateModified: now,
    );

    return await _playlistRepository.createPlaylist(playlist);
  }

  /// Create a playlist with initial songs
  ///
  /// [name] - The name of the playlist
  /// [songIds] - List of song IDs to add to the playlist
  /// [description] - Optional description
  ///
  /// Returns the ID of the created playlist
  Future<int> createPlaylistWithSongs({
    required String name,
    required List<int> songIds,
    String? description,
  }) async {
    final playlistId = await createPlaylist(
      name: name,
      description: description,
    );

    if (songIds.isNotEmpty) {
      await _playlistRepository.addSongsToPlaylist(playlistId, songIds);
    }

    return playlistId;
  }

  /// Delete a playlist
  ///
  /// [id] - The ID of the playlist to delete
  ///
  /// Returns true if deletion was successful
  Future<bool> deletePlaylist(int id) async {
    final result = await _playlistRepository.deletePlaylist(id);
    return result > 0;
  }

  /// Rename a playlist
  ///
  /// [id] - The ID of the playlist
  /// [newName] - The new name for the playlist
  ///
  /// Returns true if rename was successful
  Future<bool> renamePlaylist(int id, String newName) async {
    if (newName.trim().isEmpty) {
      throw Exception('Playlist name cannot be empty');
    }

    final playlist = await _playlistRepository.getPlaylistById(id);
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final updatedPlaylist = playlist.copyWith(
      name: newName.trim(),
      dateModified: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await _playlistRepository.updatePlaylist(updatedPlaylist);
    return result > 0;
  }

  /// Update playlist description
  ///
  /// [id] - The ID of the playlist
  /// [description] - The new description (null to remove)
  ///
  /// Returns true if update was successful
  Future<bool> updateDescription(int id, String? description) async {
    final playlist = await _playlistRepository.getPlaylistById(id);
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final updatedPlaylist = playlist.copyWith(
      description: description?.trim(),
      dateModified: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await _playlistRepository.updatePlaylist(updatedPlaylist);
    return result > 0;
  }

  /// Get a playlist by ID
  Future<PlaylistModel?> getPlaylist(int id) async {
    return await _playlistRepository.getPlaylistById(id);
  }

  /// Get all playlists
  Future<List<PlaylistModel>> getAllPlaylists() async {
    return await _playlistRepository.getAllPlaylists();
  }

  /// Search playlists by name
  Future<List<PlaylistModel>> searchPlaylists(String query) async {
    if (query.trim().isEmpty) {
      return await getAllPlaylists();
    }
    return await _playlistRepository.searchPlaylists(query.trim());
  }

  /// Get total number of playlists
  Future<int> getPlaylistCount() async {
    return await _playlistRepository.getPlaylistCount();
  }

  /// Add a song to a playlist
  ///
  /// [playlistId] - The ID of the playlist
  /// [songId] - The ID of the song to add
  ///
  /// Returns true if the song was added successfully
  Future<bool> addSong(int playlistId, int songId) async {
    try {
      // Check if song is already in playlist
      final exists = await _playlistRepository.isSongInPlaylist(
        playlistId,
        songId,
      );

      if (exists) {
        return false; // Song already in playlist
      }

      await _playlistRepository.addSongToPlaylist(playlistId, songId);
      return true;
    } catch (e) {
      print('Error adding song to playlist: $e');
      return false;
    }
  }

  /// Add multiple songs to a playlist
  ///
  /// [playlistId] - The ID of the playlist
  /// [songIds] - List of song IDs to add
  ///
  /// Returns the number of songs successfully added
  Future<int> addSongs(int playlistId, List<int> songIds) async {
    if (songIds.isEmpty) {
      return 0;
    }

    try {
      // Filter out songs that are already in the playlist
      final List<int> newSongIds = [];

      for (final songId in songIds) {
        final exists = await _playlistRepository.isSongInPlaylist(
          playlistId,
          songId,
        );

        if (!exists) {
          newSongIds.add(songId);
        }
      }

      if (newSongIds.isNotEmpty) {
        await _playlistRepository.addSongsToPlaylist(playlistId, newSongIds);
      }

      return newSongIds.length;
    } catch (e) {
      print('Error adding songs to playlist: $e');
      return 0;
    }
  }

  /// Remove a song from a playlist
  ///
  /// [playlistId] - The ID of the playlist
  /// [songId] - The ID of the song to remove
  ///
  /// Returns true if the song was removed successfully
  Future<bool> removeSong(int playlistId, int songId) async {
    try {
      await _playlistRepository.removeSongFromPlaylist(playlistId, songId);
      return true;
    } catch (e) {
      print('Error removing song from playlist: $e');
      return false;
    }
  }

  /// Remove multiple songs from a playlist
  ///
  /// [playlistId] - The ID of the playlist
  /// [songIds] - List of song IDs to remove
  ///
  /// Returns the number of songs successfully removed
  Future<int> removeSongs(int playlistId, List<int> songIds) async {
    int removed = 0;

    for (final songId in songIds) {
      try {
        await _playlistRepository.removeSongFromPlaylist(playlistId, songId);
        removed++;
      } catch (e) {
        print('Error removing song $songId from playlist: $e');
      }
    }

    return removed;
  }

  /// Clear all songs from a playlist
  ///
  /// [playlistId] - The ID of the playlist
  ///
  /// Returns true if the playlist was cleared successfully
  Future<bool> clearPlaylist(int playlistId) async {
    try {
      await _playlistRepository.clearPlaylist(playlistId);
      return true;
    } catch (e) {
      print('Error clearing playlist: $e');
      return false;
    }
  }

  /// Move a song to a new position in the playlist
  ///
  /// [playlistId] - The ID of the playlist
  /// [fromPosition] - The current position of the song (0-indexed)
  /// [toPosition] - The new position for the song (0-indexed)
  ///
  /// Returns true if the song was moved successfully
  Future<bool> reorderSong(
    int playlistId,
    int fromPosition,
    int toPosition,
  ) async {
    try {
      await _playlistRepository.moveSongInPlaylist(
        playlistId,
        fromPosition,
        toPosition,
      );
      return true;
    } catch (e) {
      print('Error reordering song: $e');
      return false;
    }
  }

  /// Get all songs in a playlist
  ///
  /// [playlistId] - The ID of the playlist
  ///
  /// Returns a list of songs ordered by their position in the playlist
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    return await _playlistRepository.getPlaylistSongs(playlistId);
  }

  /// Check if a song is in a playlist
  ///
  /// [playlistId] - The ID of the playlist
  /// [songId] - The ID of the song
  ///
  /// Returns true if the song is in the playlist
  Future<bool> containsSong(int playlistId, int songId) async {
    return await _playlistRepository.isSongInPlaylist(playlistId, songId);
  }

  /// Get playlist with songs count and duration
  ///
  /// [playlistId] - The ID of the playlist
  ///
  /// Returns the playlist model with updated statistics
  Future<PlaylistModel?> getPlaylistWithStats(int playlistId) async {
    return await _playlistRepository.getPlaylistById(playlistId);
  }

  /// Duplicate a playlist
  ///
  /// [playlistId] - The ID of the playlist to duplicate
  /// [newName] - The name for the duplicated playlist (optional)
  ///
  /// Returns the ID of the duplicated playlist
  Future<int> duplicatePlaylist(int playlistId, {String? newName}) async {
    final playlist = await _playlistRepository.getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final songs = await _playlistRepository.getPlaylistSongs(playlistId);
    final songIds = songs.map((song) => song.id!).toList();

    final duplicateName = newName ?? '${playlist.name} (Copy)';

    return await createPlaylistWithSongs(
      name: duplicateName,
      songIds: songIds,
      description: playlist.description,
    );
  }

  /// Merge multiple playlists into a new playlist
  ///
  /// [playlistIds] - List of playlist IDs to merge
  /// [newName] - The name for the merged playlist
  /// [removeDuplicates] - Whether to remove duplicate songs (default: true)
  ///
  /// Returns the ID of the merged playlist
  Future<int> mergePlaylists(
    List<int> playlistIds, {
    required String newName,
    bool removeDuplicates = true,
  }) async {
    if (playlistIds.isEmpty) {
      throw Exception('No playlists to merge');
    }

    // Collect all songs from all playlists
    final Set<int> allSongIds = {};
    final List<int> orderedSongIds = [];

    for (final playlistId in playlistIds) {
      final songs = await _playlistRepository.getPlaylistSongs(playlistId);

      for (final song in songs) {
        if (song.id != null) {
          if (removeDuplicates) {
            if (!allSongIds.contains(song.id)) {
              allSongIds.add(song.id!);
              orderedSongIds.add(song.id!);
            }
          } else {
            orderedSongIds.add(song.id!);
          }
        }
      }
    }

    return await createPlaylistWithSongs(
      name: newName,
      songIds: orderedSongIds,
    );
  }
}
