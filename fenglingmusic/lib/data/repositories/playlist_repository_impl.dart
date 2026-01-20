import '../../domain/repositories/i_playlist_repository.dart';
import '../datasources/local/playlist_dao.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

/// Playlist repository implementation
/// Implements the playlist repository interface using PlaylistDAO
class PlaylistRepositoryImpl implements IPlaylistRepository {
  final PlaylistDAO _playlistDAO;

  PlaylistRepositoryImpl({PlaylistDAO? playlistDAO})
      : _playlistDAO = playlistDAO ?? PlaylistDAO();

  @override
  Future<int> createPlaylist(PlaylistModel playlist) async {
    return await _playlistDAO.insert(playlist);
  }

  @override
  Future<int> updatePlaylist(PlaylistModel playlist) async {
    return await _playlistDAO.update(playlist);
  }

  @override
  Future<int> deletePlaylist(int id) async {
    return await _playlistDAO.delete(id);
  }

  @override
  Future<PlaylistModel?> getPlaylistById(int id) async {
    return await _playlistDAO.findById(id);
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    return await _playlistDAO.findAll();
  }

  @override
  Future<List<PlaylistModel>> searchPlaylists(String query) async {
    return await _playlistDAO.search(query);
  }

  @override
  Future<int> getPlaylistCount() async {
    return await _playlistDAO.count();
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _playlistDAO.addSong(playlistId, songId);
  }

  @override
  Future<void> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    await _playlistDAO.addSongsBatch(playlistId, songIds);
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _playlistDAO.removeSong(playlistId, songId);
  }

  @override
  Future<void> clearPlaylist(int playlistId) async {
    await _playlistDAO.clearPlaylist(playlistId);
  }

  @override
  Future<void> moveSongInPlaylist(
    int playlistId,
    int fromPosition,
    int toPosition,
  ) async {
    await _playlistDAO.moveSong(playlistId, fromPosition, toPosition);
  }

  @override
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    return await _playlistDAO.getPlaylistSongs(playlistId);
  }

  @override
  Future<bool> isSongInPlaylist(int playlistId, int songId) async {
    return await _playlistDAO.containsSong(playlistId, songId);
  }
}
