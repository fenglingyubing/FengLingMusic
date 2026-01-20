import '../../domain/repositories/i_song_repository.dart';
import '../datasources/local/song_dao.dart';
import '../models/song_model.dart';

/// Song repository implementation
/// Implements the song repository interface using SongDAO
class SongRepositoryImpl implements ISongRepository {
  final SongDAO _songDAO;

  SongRepositoryImpl({SongDAO? songDAO}) : _songDAO = songDAO ?? SongDAO();

  @override
  Future<int> insertSong(SongModel song) async {
    return await _songDAO.insert(song);
  }

  @override
  Future<void> insertSongs(List<SongModel> songs) async {
    return await _songDAO.insertBatch(songs);
  }

  @override
  Future<int> updateSong(SongModel song) async {
    return await _songDAO.update(song);
  }

  @override
  Future<int> deleteSong(int id) async {
    return await _songDAO.delete(id);
  }

  @override
  Future<int> deleteSongs(List<int> ids) async {
    return await _songDAO.deleteBatch(ids);
  }

  @override
  Future<SongModel?> getSongById(int id) async {
    return await _songDAO.findById(id);
  }

  @override
  Future<SongModel?> getSongByFilePath(String filePath) async {
    return await _songDAO.findByFilePath(filePath);
  }

  @override
  Future<List<SongModel>> getAllSongs({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    return await _songDAO.findAll(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );
  }

  @override
  Future<List<SongModel>> getSongsByArtist(String artist) async {
    return await _songDAO.findByArtist(artist);
  }

  @override
  Future<List<SongModel>> getSongsByAlbum(String album) async {
    return await _songDAO.findByAlbum(album);
  }

  @override
  Future<List<SongModel>> getSongsByGenre(String genre) async {
    return await _songDAO.findByGenre(genre);
  }

  @override
  Future<List<SongModel>> getFavoriteSongs() async {
    return await _songDAO.findFavorites();
  }

  @override
  Future<List<SongModel>> getRecentlyAdded({int limit = 50}) async {
    return await _songDAO.findRecentlyAdded(limit: limit);
  }

  @override
  Future<List<SongModel>> getMostPlayed({int limit = 50}) async {
    return await _songDAO.findMostPlayed(limit: limit);
  }

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    return await _songDAO.search(query);
  }

  @override
  Future<void> toggleFavorite(int id) async {
    await _songDAO.toggleFavorite(id);
  }

  @override
  Future<void> incrementPlayCount(int id) async {
    await _songDAO.incrementPlayCount(id);
  }

  @override
  Future<void> updateRating(int id, double rating) async {
    await _songDAO.updateRating(id, rating);
  }

  @override
  Future<int> getSongCount() async {
    return await _songDAO.count();
  }

  @override
  Future<bool> filePathExists(String filePath) async {
    return await _songDAO.filePathExists(filePath);
  }

  @override
  Future<List<String>> getAllArtists() async {
    return await _songDAO.getAllArtists();
  }

  @override
  Future<List<String>> getAllAlbums() async {
    return await _songDAO.getAllAlbums();
  }

  @override
  Future<List<String>> getAllGenres() async {
    return await _songDAO.getAllGenres();
  }
}
