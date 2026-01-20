import '../../data/models/song_model.dart';

/// Song repository interface
/// Defines the contract for song data operations
abstract class ISongRepository {
  /// Insert a song
  Future<int> insertSong(SongModel song);

  /// Insert multiple songs
  Future<void> insertSongs(List<SongModel> songs);

  /// Update a song
  Future<int> updateSong(SongModel song);

  /// Delete a song
  Future<int> deleteSong(int id);

  /// Delete multiple songs
  Future<int> deleteSongs(List<int> ids);

  /// Get a song by ID
  Future<SongModel?> getSongById(int id);

  /// Get a song by file path
  Future<SongModel?> getSongByFilePath(String filePath);

  /// Get all songs
  Future<List<SongModel>> getAllSongs({
    int? limit,
    int? offset,
    String? orderBy,
  });

  /// Get songs by artist
  Future<List<SongModel>> getSongsByArtist(String artist);

  /// Get songs by album
  Future<List<SongModel>> getSongsByAlbum(String album);

  /// Get songs by genre
  Future<List<SongModel>> getSongsByGenre(String genre);

  /// Get favorite songs
  Future<List<SongModel>> getFavoriteSongs();

  /// Get recently added songs
  Future<List<SongModel>> getRecentlyAdded({int limit = 50});

  /// Get most played songs
  Future<List<SongModel>> getMostPlayed({int limit = 50});

  /// Search songs
  Future<List<SongModel>> searchSongs(String query);

  /// Toggle favorite status
  Future<void> toggleFavorite(int id);

  /// Increment play count
  Future<void> incrementPlayCount(int id);

  /// Update rating
  Future<void> updateRating(int id, double rating);

  /// Get total song count
  Future<int> getSongCount();

  /// Check if file path exists
  Future<bool> filePathExists(String filePath);

  /// Get all artists
  Future<List<String>> getAllArtists();

  /// Get all albums
  Future<List<String>> getAllAlbums();

  /// Get all genres
  Future<List<String>> getAllGenres();
}
