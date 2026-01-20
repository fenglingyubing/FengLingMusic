import '../../data/models/playlist_model.dart';
import '../../data/models/song_model.dart';

/// Playlist repository interface
/// Defines the contract for playlist data operations
abstract class IPlaylistRepository {
  /// Create a new playlist
  Future<int> createPlaylist(PlaylistModel playlist);

  /// Update a playlist
  Future<int> updatePlaylist(PlaylistModel playlist);

  /// Delete a playlist
  Future<int> deletePlaylist(int id);

  /// Get a playlist by ID
  Future<PlaylistModel?> getPlaylistById(int id);

  /// Get all playlists
  Future<List<PlaylistModel>> getAllPlaylists();

  /// Search playlists
  Future<List<PlaylistModel>> searchPlaylists(String query);

  /// Get playlist count
  Future<int> getPlaylistCount();

  /// Add a song to a playlist
  Future<void> addSongToPlaylist(int playlistId, int songId);

  /// Add multiple songs to a playlist
  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds);

  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(int playlistId, int songId);

  /// Clear all songs from a playlist
  Future<void> clearPlaylist(int playlistId);

  /// Move a song to a new position in a playlist
  Future<void> moveSongInPlaylist(int playlistId, int fromPosition, int toPosition);

  /// Get songs in a playlist
  Future<List<SongModel>> getPlaylistSongs(int playlistId);

  /// Check if a song is in a playlist
  Future<bool> isSongInPlaylist(int playlistId, int songId);
}
