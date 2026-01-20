import '../../data/datasources/local/song_dao.dart';
import '../../data/models/song_model.dart';

/// Result type for categorized search results
class SearchResults {
  final List<SongModel> songs;
  final List<String> artists;
  final List<String> albums;
  final int totalCount;

  SearchResults({
    required this.songs,
    required this.artists,
    required this.albums,
  }) : totalCount = songs.length + artists.length + albums.length;

  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => totalCount > 0;
}

/// Local search service for searching songs, artists, and albums
/// Implements fuzzy matching and result sorting for optimal UX
class LocalSearchService {
  final SongDAO _songDAO = SongDAO();

  /// Search across songs, artists, and albums with fuzzy matching
  ///
  /// [query] - Search term (supports partial matching)
  /// [limit] - Maximum results per category (default: 20)
  ///
  /// Returns [SearchResults] with categorized results
  Future<SearchResults> search(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      return SearchResults(
        songs: [],
        artists: [],
        albums: [],
      );
    }

    // Normalize query for better matching
    final normalizedQuery = query.trim().toLowerCase();

    // Search songs
    final songs = await _searchSongs(normalizedQuery, limit: limit);

    // Extract unique artists and albums from results
    final artistsSet = <String>{};
    final albumsSet = <String>{};

    for (final song in songs) {
      if (song.artist != null && song.artist!.isNotEmpty) {
        artistsSet.add(song.artist!);
      }
      if (song.album != null && song.album!.isNotEmpty) {
        albumsSet.add(song.album!);
      }
    }

    // Sort and limit artists/albums
    final artists = artistsSet.toList()
      ..sort((a, b) => _sortByRelevance(a, b, normalizedQuery));
    final albums = albumsSet.toList()
      ..sort((a, b) => _sortByRelevance(a, b, normalizedQuery));

    return SearchResults(
      songs: songs.take(limit).toList(),
      artists: artists.take(10).toList(),
      albums: albums.take(10).toList(),
    );
  }

  /// Search only songs
  Future<List<SongModel>> searchSongs(
    String query, {
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final normalizedQuery = query.trim().toLowerCase();
    return _searchSongs(normalizedQuery, limit: limit);
  }

  /// Search by artist name
  Future<List<SongModel>> searchByArtist(
    String artist, {
    int limit = 100,
  }) async {
    if (artist.trim().isEmpty) {
      return [];
    }

    return await _songDAO.findByArtist(artist, limit: limit);
  }

  /// Search by album name
  Future<List<SongModel>> searchByAlbum(
    String album, {
    int limit = 100,
  }) async {
    if (album.trim().isEmpty) {
      return [];
    }

    return await _songDAO.findByAlbum(album, limit: limit);
  }

  /// Get search suggestions based on partial input
  Future<List<String>> getSuggestions(String query) async {
    if (query.trim().isEmpty || query.length < 2) {
      return [];
    }

    final results = await search(query, limit: 5);
    final suggestions = <String>[];

    // Add song titles
    suggestions.addAll(results.songs.map((s) => s.title));

    // Add artists
    suggestions.addAll(results.artists);

    // Add albums
    suggestions.addAll(results.albums);

    return suggestions.take(10).toList();
  }

  /// Private helper: Search songs with relevance scoring
  Future<List<SongModel>> _searchSongs(
    String query, {
    required int limit,
  }) async {
    // Use DAO's search method
    final results = await _songDAO.search(query, limit: limit * 2);

    // Score and sort by relevance
    final scoredResults = results.map((song) {
      final score = _calculateRelevanceScore(song, query);
      return _ScoredSong(song, score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return scoredResults.map((s) => s.song).toList();
  }

  /// Calculate relevance score for a song
  /// Higher score = more relevant
  int _calculateRelevanceScore(SongModel song, String query) {
    int score = 0;
    final lowerTitle = song.title.toLowerCase();
    final lowerArtist = song.artist?.toLowerCase() ?? '';
    final lowerAlbum = song.album?.toLowerCase() ?? '';

    // Exact matches get highest priority
    if (lowerTitle == query) score += 1000;
    if (lowerArtist == query) score += 800;
    if (lowerAlbum == query) score += 600;

    // Starts with query
    if (lowerTitle.startsWith(query)) score += 500;
    if (lowerArtist.startsWith(query)) score += 400;
    if (lowerAlbum.startsWith(query)) score += 300;

    // Contains query
    if (lowerTitle.contains(query)) score += 200;
    if (lowerArtist.contains(query)) score += 150;
    if (lowerAlbum.contains(query)) score += 100;

    // Boost favorites and frequently played
    if (song.isFavorite) score += 50;
    score += (song.playCount * 2).clamp(0, 100);

    return score;
  }

  /// Sort two strings by relevance to query
  int _sortByRelevance(String a, String b, String query) {
    final lowerA = a.toLowerCase();
    final lowerB = b.toLowerCase();

    // Exact match first
    if (lowerA == query) return -1;
    if (lowerB == query) return 1;

    // Starts with query
    final aStarts = lowerA.startsWith(query);
    final bStarts = lowerB.startsWith(query);
    if (aStarts && !bStarts) return -1;
    if (!aStarts && bStarts) return 1;

    // Alphabetical
    return a.compareTo(b);
  }
}

/// Helper class for scoring songs
class _ScoredSong {
  final SongModel song;
  final int score;

  _ScoredSong(this.song, this.score);
}
